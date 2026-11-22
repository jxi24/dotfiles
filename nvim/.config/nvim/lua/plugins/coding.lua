local function get_args()
    local args = {}
    return vim.split(vim.fn.input("CMake args: ", table.concat(args, " ")), " ")
end

return {
    {
        "Civitasv/cmake-tools.nvim",
        -- With CMake[User]Presets.json (cmake-presets adds Debug / Release / RelWithDebInfo)
        -- the build folder is the preset's, build/<Type>; without, the same layout here.
        opts = {
            cmake_build_directory = function()
                return "build/${variant:buildType}"
            end,
            -- Link <root>/compile_commands.json to the build just generated (clangd and
            -- neotest follow it). cmake-tools won't replace an existing link to another
            -- build (fs_symlink fails with EEXIST), so drop it first; this runs only after
            -- a successful generate.
            cmake_compile_commands_options = {
                action = "soft_link",
                target = function()
                    local cwd = vim.uv.cwd()
                    local link = cwd .. "/compile_commands.json"
                    local dir = require("cmake-tools").get_build_directory()
                    local fresh = dir and vim.uv.fs_stat(tostring(dir) .. "/compile_commands.json")
                    local st = vim.uv.fs_lstat(link)
                    if fresh and st and st.type == "link" then
                        os.remove(link)
                    end
                    return cwd
                end,
            },
        },
        keys = {
            { "<leader>c", "", desc = "CMake" },
            { "<leader>cg", "<cmd>CMakeGenerate<cr>", desc = "Generate" },
            { "<leader>cb", "<cmd>CMakeBuild -j8<cr>", desc = "Build" },
            { "<leader>cr", "<cmd>CMakeRun<cr>", desc = "Run" },
            { "<leader>ci", "<cmd>CMakeInstall<cr>", desc = "Install" },
            {
                "<leader>ct",
                function()
                    -- A build preset also sets its configure preset, then regenerates
                    -- and links compile_commands.json to that build (the active one).
                    local presets = require("cmake-tools").has_cmake_preset()
                    vim.cmd(presets and "CMakeSelectBuildPreset" or "CMakeSelectBuildType")
                end,
                desc = "Select Build Type (preset)",
            },
            { "<leader>cT", "<cmd>CMakeSelectTarget<cr>", desc = "Select Build Target" },
            {
                "<leader>cG",
                function()
                    require("cmake-tools").generate({fargs = get_args()}, function() end) end,
                desc = "Generate with Args"
            },
            {
                "<leader>cB",
                function()
                    require("cmake-tools").build({fargs = get_args()}, function() end) end,
                desc = "Build with Args"
            },
        },
    },
    {
        "nvim-neotest/neotest",
        cmd = "Neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "orjangj/neotest-ctest",
            "nvim-neotest/neotest-python",
        },
        config = function()
            local neotest_ns = vim.api.nvim_create_namespace("neotest")
            vim.diagnostic.config({
                virtual_text = {
                    format = function(diagnostic)
                        local message = diagnostic.message:gsub("[\r\n\t%s]+", " ")
                        return message
                    end,
                },
            }, neotest_ns)

            require("neotest").setup({
                adapters = {
                    require("neotest-python")({}),
                    -- Catch2 (and gtest/doctest) through CTest; see lua/util/ctest.lua
                    require("util.ctest").adapter(),
                },
            })
        end,
        keys = {
            { "<leader>t", "", desc = "Testing" },
            { "<leader>tt", function() require("neotest").run.run() end, desc = "Run Nearest" },
            { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File" },
            { "<leader>tw", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run workspace" },
            { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last" },
            { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest" },
            { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop" },
            { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Summary" },
            { "<leader>to", function() require("neotest").output_panel.toggle() end, desc = "Output Panel" },
            { "<leader>tr", function() require("neotest").output.open({ short = true, auto_close = true }) end, desc = "Results (short)" },
            { "<leader>tR", function() require("neotest").output.open({ enter = true }) end, desc = "Results (full)" },
            { "]T", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next Failed Test" },
            { "[T", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Previous Failed Test" },
            { "<leader>tc", function() require("util.ctest").select() end, desc = "CTest Build Directory" },
            { "<leader>tB", function() require("util.ctest").toggle_build() end, desc = "Toggle Build Before Run" },
            { "<leader>tF", function() require("util.ctest").run_label("fortran") end, desc = "Fortran Suite (CTest label)" },
        },
    }
}
