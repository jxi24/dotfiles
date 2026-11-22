-- Link Overleaf projects opened with overleaf.nvim to their notes in the Work
-- vault: a paper (Papers/*.md) or a grant (Grants/*.md with type: grant),
-- whichever holds the project's address in its `overleaf:` field.
--
-- On connecting, it asks the vault which note the project is:
--   gtd.py overleaf which URL --name NAME --files F... --json
--   → {kind = "paper"|"grant"|nil, note, path, guess, why}
-- (offline; the guess comes from the project's name and .tex file names). If
-- no note holds it, it asks once per session, the guessed kind first:
--   new grant note   gtd.py grant new NAME --funder F --due D --overleaf URL
--   new paper note   gtd.py paper new TITLE --overleaf URL [--project P]
--   link to a grant  gtd.py grant link NOTE --overleaf URL
--   link to a paper  gtd.py paper link NOTE --overleaf URL
--   not now, or never for this project (remembered in
--   ~/.local/state/nvim/overleaf-no-note).
-- The link pickers list only notes without an Overleaf address, never
-- Papers/Pipeline.md or the Grants/Grants.md hub.
-- M.open() (<leader>Ln) opens the current project's note, or asks again.
--
-- With a gtd.py that has no `overleaf which` yet, it falls back to looking
-- for the project id in Papers/ and Grants/ itself, guessing a paper.

local M = {}

M.vault = vim.env.NOTES_VAULT or vim.fn.expand("~/Documents/Obsidian/Work")
M.never_file = vim.fn.stdpath("state") .. "/overleaf-no-note"
M.funders = { "doe", "doe-ecrp", "nsf", "foundation" } -- if grant-docs.json can't be read

local asked = {} -- project ids already asked about this session
local current -- data of the last OverleafConnected event
local found = {} -- project id → {kind, note, path} from `overleaf which`

local function project_id(url)
    return (url or ""):match("/project/(%x+)")
end

-- Frontmatter fields of a note (the first 60 lines): {key = value}.
local function front(path)
    local ok, lines = pcall(vim.fn.readfile, path, "", 60)
    local f = {}
    if ok and lines[1] == "---" then
        for i = 2, #lines do
            if lines[i] == "---" then
                break
            end
            local k, v = lines[i]:match("^([%w_-]+):%s*(.-)%s*$")
            if k then
                f[k] = v
            end
        end
    end
    return f
end

-- Every paper note (kind "paper") or grant note (kind "grant"): its name, path
-- and Overleaf project id (nil if none). Papers need a status:, grants
-- type: grant; Papers/Pipeline.md and the Grants/Grants.md hub are never listed.
function M.notes(kind)
    kind = kind or "paper"
    local folder, hub = kind == "grant" and "Grants" or "Papers", kind == "grant" and "Grants" or "Pipeline"
    local notes = {}
    for _, path in ipairs(vim.fn.globpath(M.vault, folder .. "/*.md", false, true)) do
        local name = vim.fn.fnamemodify(path, ":t:r")
        local f = front(path)
        local real = kind == "grant" and f.type == "grant" or kind ~= "grant" and (f.status or "") ~= ""
        if name ~= hub and real then
            notes[#notes + 1] = { name = name, path = path, id = project_id(f.overleaf), kind = kind }
        end
    end
    table.sort(notes, function(a, b) return a.name < b.name end)
    return notes
end

-- The note (paper or grant) holding this project id, looked up here.
function M.find(id)
    for _, kind in ipairs({ "paper", "grant" }) do
        for _, n in ipairs(M.notes(kind)) do
            if n.id == id then
                return n
            end
        end
    end
end

local function never(id)
    local ok, lines = pcall(vim.fn.readfile, M.never_file)
    return ok and vim.tbl_contains(lines, id)
end

-- The project's file paths from overleaf.nvim (its tree is parsed before
-- OverleafConnected fires); {} if it isn't loaded.
local function project_files()
    local ok, project = pcall(require, "overleaf.project")
    local files = {}
    for _, e in ipairs(ok and project._project_tree or {}) do
        if e.type == "doc" and e.path:match("%.tex$") then
            files[#files + 1] = e.path
        end
    end
    return files
end

local function have_gtd()
    if vim.fn.executable("gtd.py") == 1 then
        return true
    end
    vim.notify("gtd.py isn't on PATH", vim.log.levels.ERROR)
end

-- Ask the vault which note project p is; cb({kind, note, path, guess, why}).
function M.which(p, cb)
    local cmd = { "gtd.py", "overleaf", "which", p.url, "--name", p.project_name or "", "--json" }
    local files = project_files()
    if #files > 0 then
        vim.list_extend(cmd, { "--files", unpack(files) })
    end
    local function local_lookup()
        local n = M.find(p.project_id)
        return n and { kind = n.kind, note = n.name, path = n.path, guess = n.kind }
            or { guess = "paper", why = "gtd.py has no `overleaf which`" }
    end
    if vim.fn.executable("gtd.py") == 0 then
        return cb(local_lookup())
    end
    vim.system(cmd, { text = true, env = { NOTES_VAULT = M.vault } }, function(res)
        vim.schedule(function()
            local ok, w = pcall(vim.json.decode, res.stdout or "")
            if res.code ~= 0 or not ok or type(w) ~= "table" then
                return cb(local_lookup())
            end
            for k, v in pairs(w) do
                if v == vim.NIL then
                    w[k] = nil
                end
            end
            if w.path and not w.path:match("^/") then
                w.path = M.vault .. "/" .. w.path
            end
            cb(w)
        end)
    end)
end

-- Run gtd.py KIND ARGS... against the vault (KIND is paper or grant); report
-- its output, and on success forget the project's lookup so <leader>Ln asks again.
local function gtd(kind, args, id)
    if not have_gtd() then
        return
    end
    vim.system(vim.list_extend({ "gtd.py", kind }, args), {
        text = true,
        env = { NOTES_VAULT = M.vault },
    }, function(res)
        vim.schedule(function()
            local out = vim.trim((res.stdout or "") .. "\n" .. (res.stderr or ""))
            if res.code ~= 0 then
                return vim.notify(out, vim.log.levels.ERROR)
            end
            found[id] = nil
            vim.notify(out .. "\n<leader>Ln opens it")
        end)
    end)
end

local function projects()
    local list = { "(none)" }
    for _, f in ipairs(vim.fn.globpath(M.vault, "Projects/*.md", false, true)) do
        list[#list + 1] = vim.fn.fnamemodify(f, ":t:r")
    end
    return list
end

function M.funder_keys()
    local ok, data = pcall(function()
        return vim.json.decode(table.concat(vim.fn.readfile(M.vault .. "/Utility/Scripts/grant-docs.json"), "\n"))
    end)
    local keys = {}
    for k in pairs(ok and type(data) == "table" and data or {}) do
        if not k:match("^_") then
            keys[#keys + 1] = k
        end
    end
    table.sort(keys)
    return #keys > 0 and keys or M.funders
end

local function new_paper(p)
    vim.ui.input({ prompt = "Paper title: ", default = p.project_name }, function(title)
        if not title or vim.trim(title) == "" then
            return
        end
        vim.ui.select(projects(), { prompt = "GTD project for " .. title }, function(project)
            if not project then
                return
            end
            local args = { "new", vim.trim(title), "--overleaf", p.url }
            if project ~= "(none)" then
                vim.list_extend(args, { "--project", project })
            end
            gtd("paper", args, p.project_id)
        end)
    end)
end

local function new_grant(p)
    vim.ui.input({ prompt = "Grant name: ", default = p.project_name }, function(name)
        if not name or vim.trim(name) == "" then
            return
        end
        vim.ui.select(M.funder_keys(), { prompt = "Funder for " .. name }, function(funder)
            if not funder then
                return
            end
            vim.ui.input({ prompt = "Deadline (YYYY-MM-DD): " }, function(due)
                due = due and vim.trim(due)
                if not due or due == "" then
                    return
                end
                if not due:match("^%d%d%d%d%-%d%d%-%d%d$") then
                    return vim.notify("The deadline is YYYY-MM-DD, not " .. due, vim.log.levels.ERROR)
                end
                gtd("grant", { "new", vim.trim(name), "--funder", funder, "--due", due, "--overleaf", p.url }, p.project_id)
            end)
        end)
    end)
end

local function link(kind, p)
    local free = vim.tbl_filter(function(n) return not n.id end, M.notes(kind))
    if #free == 0 then
        return vim.notify(("Every %s note already has an Overleaf project."):format(kind))
    end
    vim.ui.select(free, {
        prompt = ("%s note for %s"):format(kind == "grant" and "Grant" or "Paper", p.project_name),
        format_item = function(n) return n.name end,
    }, function(note)
        if note then
            gtd(kind, { "link", note.name, "--overleaf", p.url }, p.project_id)
        end
    end)
end

-- The question for a project with no note, the guessed kind first.
function M.ask(p, w)
    local guess = w and w.guess == "grant" and "grant" or "paper"
    local other = guess == "grant" and "paper" or "grant"
    local acts = {
        { "New " .. guess .. " note", function() (guess == "grant" and new_grant or new_paper)(p) end },
        { "New " .. other .. " note", function() (other == "grant" and new_grant or new_paper)(p) end },
        { "Link to a " .. guess, function() link(guess, p) end },
        { "Link to a " .. other, function() link(other, p) end },
        { "Not now", function() end },
        {
            "Never for this project",
            function()
                vim.fn.mkdir(vim.fn.fnamemodify(M.never_file, ":h"), "p")
                vim.fn.writefile({ p.project_id }, M.never_file, "a")
            end,
        },
    }
    local why = w and w.why and (" (a %s? %s)"):format(guess, w.why) or ""
    vim.ui.select(acts, {
        prompt = ("“%s” has no note in the vault%s"):format(p.project_name, why),
        format_item = function(a) return a[1] end,
    }, function(a)
        if a then
            a[2]()
        end
    end)
end

-- Remember the note, or ask (unless asked already or never) about one.
local function settle(p, w, force)
    if w.kind and w.path then
        found[p.project_id] = { kind = w.kind, note = w.note, path = w.path }
        return true
    end
    if force or not (asked[p.project_id] or never(p.project_id)) then
        asked[p.project_id] = true
        M.ask(p, w)
    end
end

function M.on_connect(p)
    current = p
    if vim.fn.isdirectory(M.vault) == 0 then
        return
    end
    M.which(p, function(w) settle(p, w) end)
end

-- Open the current project's paper or grant note, or offer to make one.
function M.open()
    if not current then
        return vim.notify("Not connected to an Overleaf project")
    end
    local function edit(n) vim.cmd.edit(vim.fn.fnameescape(n.path)) end
    local n = found[current.project_id]
    if n and vim.fn.filereadable(n.path) == 1 then
        return edit(n)
    end
    local p = current
    M.which(p, function(w)
        if settle(p, w, true) then
            edit(found[p.project_id])
        end
    end)
end

function M.setup()
    vim.api.nvim_create_autocmd("User", {
        pattern = "OverleafConnected",
        group = vim.api.nvim_create_augroup("paper_notes", { clear = true }),
        callback = function(ev) M.on_connect(ev.data) end,
    })
end

return M
