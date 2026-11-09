-- Glue that makes neotest-ctest work for CMake + Catch2 projects with several build trees.
--
--  * CTest runs in an explicitly chosen build directory (picked with `select()`, the
--    cmake-tools build directory, or <root>/build) instead of the first
--    CTestTestfile.cmake that neotest-ctest happens to find.
--  * The test executables are rebuilt before every run, so edited and newly added
--    TEST_CASEs are picked up (catch_discover_tests registers them post-build).
--    Compile errors are reported as a failed run with the build log as output.
--  * Debugging a test launches it under gdb in the test's WORKING_DIRECTORY.
--
-- Builds run inside neotest's async tasks, so everything here that runs at test time
-- sticks to vim.uv / vim.fs and neotest.lib rather than vim.fn.
local M = {}

---Rebuild the test executables before running tests.
M.build_first = true

local root_markers = { "CMakePresets.json", "compile_commands.json", ".clangd", ".git" }
local test_extensions = { cc = true, cpp = true, cxx = true }
local skipped_dirs = {
    cmake = true, doc = true, docs = true, examples = true, external = true, install = true,
    scripts = true, tools = true, venv = true, _deps = true, [".cache"] = true,
}

---@type table<string, string> project root -> build directory chosen with select()
local selected = {}
local build_locks = {}

local function has_ctest(dir)
    return dir ~= nil and vim.uv.fs_stat(vim.fs.joinpath(dir, "CTestTestfile.cmake")) ~= nil
end

local function is_build_dir_name(name)
    return name:match("^build") or name:match("^out") or name:match("^cmake%-build")
end

local function notify(msg, level)
    vim.schedule(function() vim.notify(msg, level or vim.log.levels.INFO, { title = "CTest" }) end)
end

---@param path string
---@return string?
function M.root(path)
    return vim.fs.root(path, root_markers)
end

---Neotest discovery filter: skip build trees and third-party code.
function M.filter_dir(name)
    return not (skipped_dirs[name] or is_build_dir_name(name))
end

---C++ sources under a test/ or tests/ directory, or named like vectors_test.cc.
---@param path string
function M.is_test_file(path)
    local stem, ext = vim.fs.basename(path):match("^(.*)%.(%w+)$")
    if not (ext and test_extensions[ext]) then
        return false
    end
    return stem:match("_tests?$") ~= nil or path:find("/tests?/") ~= nil
end

---Build directories under `root` that CTest can run in: build/, build_*/, out/ and
---multi-config layouts such as build/Debug/.
---@param root string
---@return string[]
function M.candidates(root)
    local dirs = {}
    for name, type in vim.fs.dir(root) do
        local dir = vim.fs.joinpath(root, name)
        if type == "directory" then
            if has_ctest(dir) then
                table.insert(dirs, dir)
            elseif is_build_dir_name(name) then
                for sub, subtype in vim.fs.dir(dir) do
                    local subdir = vim.fs.joinpath(dir, sub)
                    if subtype == "directory" and has_ctest(subdir) then
                        table.insert(dirs, subdir)
                    end
                end
            end
        end
    end
    table.sort(dirs)
    return dirs
end

local function cmake_tools_dir()
    -- Only consult cmake-tools when it is already in use; don't load it just for this.
    local cmake = package.loaded["cmake-tools"]
    local dir = cmake and cmake.get_build_directory()
    if not dir then
        return nil
    end
    return vim.fs.abspath(dir.filename or tostring(dir))
end

---@param root string
---@return string?
function M.build_dir(root)
    local preferred = { selected[root], cmake_tools_dir(), vim.fs.joinpath(root, "build") }
    for i = 1, 3 do
        local dir = preferred[i]
        if dir and vim.startswith(dir, root) and has_ctest(dir) then
            return dir
        end
    end
    return M.candidates(root)[1]
end

---Pick the build directory tests run in for the current project.
function M.select()
    local root = M.root(vim.api.nvim_buf_get_name(0)) or vim.uv.cwd()
    local dirs = M.candidates(root)
    if #dirs == 0 then
        return notify("No configured CTest build directory under " .. root, vim.log.levels.WARN)
    end
    local current = M.build_dir(root)
    vim.ui.select(dirs, {
        prompt = "CTest build directory",
        format_item = function(dir)
            local rel = dir:sub(#root + 2)
            return dir == current and rel .. " (current)" or rel
        end,
    }, function(choice)
        if choice then
            selected[root] = choice
            notify("Running tests in " .. choice:sub(#root + 2))
        end
    end)
end

function M.toggle_build()
    M.build_first = not M.build_first
    notify("Build before running tests: " .. (M.build_first and "on" or "off"))
end

---Build and run every CTest test carrying `label` (e.g. the Fortran suite) in a terminal
---split. For suites neotest can't map to source positions.
---@param label string
function M.run_label(label)
    local root = M.root(vim.api.nvim_buf_get_name(0)) or vim.uv.cwd()
    local dir = M.build_dir(root)
    if not dir then
        return notify("No configured CTest build directory under " .. root, vim.log.levels.WARN)
    end
    local result = vim.system({ "ctest", "--test-dir", dir, "-L", label, "--show-only=json-v1" }, { text = true }):wait()
    local ok, decoded = pcall(vim.json.decode, result.stdout or "")
    local targets = {}
    for _, test in ipairs(ok and decoded.tests or {}) do
        if test.command and test.command[1] then
            targets[vim.fs.basename(test.command[1])] = true
        end
    end
    if vim.tbl_isempty(targets) then
        return notify("No CTest tests labelled '" .. label .. "' in " .. dir, vim.log.levels.WARN)
    end
    local build = { "cmake", "--build", dir, "--parallel", tostring(vim.uv.available_parallelism()), "--target" }
    vim.list_extend(build, vim.tbl_keys(targets))
    local run = { "ctest", "--test-dir", dir, "-L", label, "--output-on-failure" }
    local cmd = table.concat(vim.tbl_map(vim.fn.shellescape, build), " ") .. " && "
        .. table.concat(vim.tbl_map(vim.fn.shellescape, run), " ")
    vim.cmd("botright 15split")
    vim.cmd.terminal(cmd)
end

---Tests registered with CTest in `dir`, keyed by name.
---@return table<string, { executable: string, args: string[], cwd?: string }>
local function ctest_tests(dir)
    local lib = require("neotest.lib")
    local _, result = lib.process.run({ "ctest", "--test-dir", dir, "--show-only=json-v1" }, { stdout = true })
    local ok, decoded = pcall(vim.json.decode, result.stdout or "")
    local tests = {}
    for _, test in ipairs(ok and decoded.tests or {}) do
        local cwd
        for _, prop in ipairs(test.properties or {}) do
            if prop.name == "WORKING_DIRECTORY" then
                cwd = prop.value
            end
        end
        local cmd = test.command or {}
        tests[test.name] = { executable = cmd[1], args = vim.list_slice(cmd, 2), cwd = cwd }
    end
    return tests
end

---Rebuild the executables holding the tests in `tree` (everything if none are known yet,
---e.g. a brand new test file).
---@return boolean ok, string output
local function build(dir, tree)
    local lib = require("neotest.lib")
    local tests = ctest_tests(dir)
    local targets = {}
    for _, pos in tree:iter() do
        local test = pos.type == "test" and tests[pos.name]
        if test and test.executable then
            targets[vim.fs.basename(test.executable)] = true
        end
    end
    targets = vim.tbl_keys(targets)

    local cmd = { "cmake", "--build", dir, "--parallel", tostring(vim.uv.available_parallelism()) }
    if #targets > 0 then
        vim.list_extend(cmd, { "--target", unpack(targets) })
    end
    notify("Building " .. (#targets > 0 and table.concat(targets, ", ") or "all targets") .. "…")

    -- Merge stderr into stdout: neotest's process.run drains the pipes one after another,
    -- which can deadlock on a large amount of compiler output on stderr.
    build_locks[dir] = build_locks[dir] or require("nio").control.semaphore(1)
    local code, result
    build_locks[dir].with(function()
        code, result = lib.process.run({ "sh", "-c", 'exec "$@" 2>&1', "sh", unpack(cmd) }, { stdout = true })
    end)
    return code == 0, result.stdout or ""
end

---Compiler diagnostics from `log` that point into `path`, in neotest's error format.
local function compile_errors(log, path)
    local errors, seen = {}, {}
    for file, line, msg in log:gmatch("([^\n:]+):(%d+):%d+: error: ([^\n]*)") do
        local key = line .. msg
        if not seen[key] and (vim.endswith(path, file) or vim.endswith(file, path)) then
            seen[key] = true
            table.insert(errors, { line = tonumber(line) - 1, message = msg })
        end
    end
    return errors
end

---Wrap neotest-ctest and return the configured adapter.
---@param opts? table extra neotest-ctest options
function M.adapter(opts)
    local adapter = require("neotest-ctest").setup(vim.tbl_extend("force", {
        root = M.root,
        is_test_file = M.is_test_file,
        filter_dir = M.filter_dir,
        frameworks = { "catch2", "gtest", "doctest" },
        dap_adapter = "gdb",
    }, opts or {}))

    -- Run CTest in our build directory. This mirrors neotest-ctest's ctest:new() minus the
    -- directory scan, so it depends on that module's field names (pinned in lazy-lock.json).
    local ctest = require("neotest-ctest.ctest")
    local ctest_new = ctest.new
    function ctest:new(root)
        local dir = M.build_dir(root)
        if not dir then
            return ctest_new(self, root)
        end
        local nio = require("nio")
        self.__index = self
        return setmetatable({
            _test_dir = dir,
            _output_junit_path = nio.fn.tempname(),
            _output_log_path = nio.fn.tempname(),
        }, self)
    end

    local build_spec, results = adapter.build_spec, adapter.results

    function adapter.build_spec(args)
        local tree = args.tree
        local pos = tree and tree:data()
        local root = pos and M.root(pos.path)
        local dir = root and M.build_dir(root)

        if dir and M.build_first then
            local ok, log = build(dir, tree)
            if not ok then
                local lib = require("neotest.lib")
                local log_path = require("nio").fn.tempname()
                lib.files.write(log_path, log)
                notify("Build failed, see the test output for the log", vim.log.levels.ERROR)
                return {
                    command = { "sh", "-c", 'cat "$0"; exit 1', log_path },
                    context = { build_failed = true, build_log = log_path, errors = compile_errors(log, pos.path) },
                }
            end
        end

        local spec = build_spec(args)
        -- Debug in the directory CTest would run the test in (catch_discover_tests'
        -- WORKING_DIRECTORY) rather than the project root.
        if spec and type(spec.strategy) == "table" and dir then
            local tests = ctest_tests(dir)
            for _, node in tree:iter() do
                local test = node.type == "test" and tests[node.name]
                if test then
                    spec.strategy.program = test.executable
                    spec.strategy.args = test.args
                    spec.strategy.cwd = test.cwd or dir
                    break
                end
            end
        end
        return spec
    end

    function adapter.results(spec, result, tree)
        local context = spec.context or {}
        if context.build_failed then
            local out = {}
            for _, pos in tree:iter() do
                out[pos.id] = { status = "failed", short = "Build failed", output = context.build_log }
            end
            -- Compile errors in this file show up as diagnostics on the node that was run
            out[tree:data().id].errors = context.errors
            return out
        end
        -- No JUnit report when CTest never ran (e.g. after a debug session)
        local junit = context.ctest and vim.uv.fs_stat(context.ctest._output_junit_path)
        if context.ctest and not (junit and junit.size > 0) then
            return {}
        end
        return results(spec, result, tree)
    end

    return adapter
end

return M
