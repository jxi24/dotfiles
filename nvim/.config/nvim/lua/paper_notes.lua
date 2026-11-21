-- Link Overleaf projects opened with overleaf.nvim to their paper notes in the
-- Work vault (Papers/*.md, whose `overleaf:` field holds the project address).
--
-- On connecting to a project that no note points to, it asks once per
-- session whether to
--   create a note        gtd.py paper new TITLE --overleaf URL [--project P]
--   link an existing one gtd.py paper link NOTE --overleaf URL (notes without
--                        an Overleaf address yet)
--   not now, or never for this project (remembered in
--   ~/.local/state/nvim/overleaf-no-note).
-- M.open() (<leader>Ln) opens the current project's note, or asks again.

local M = {}

M.vault = vim.env.NOTES_VAULT or vim.fn.expand("~/Documents/Obsidian/Work")
M.never_file = vim.fn.stdpath("state") .. "/overleaf-no-note"

local asked = {} -- project ids already asked about this session
local current -- data of the last OverleafConnected event

local function project_id(url)
    return (url or ""):match("/project/(%x+)")
end

-- Every paper note: its name, path and Overleaf project id (nil if none).
function M.notes()
    local notes = {}
    for _, path in ipairs(vim.fn.globpath(M.vault, "Papers/*.md", false, true)) do
        local ok, lines = pcall(vim.fn.readfile, path, "", 40)
        local id
        if ok and lines[1] == "---" then
            for i = 2, #lines do
                if lines[i] == "---" then
                    break
                end
                local v = lines[i]:match("^overleaf:%s*(.*)$")
                if v then
                    id = project_id(v)
                end
            end
        end
        notes[#notes + 1] = { name = vim.fn.fnamemodify(path, ":t:r"), path = path, id = id }
    end
    table.sort(notes, function(a, b) return a.name < b.name end)
    return notes
end

function M.find(id)
    for _, n in ipairs(M.notes()) do
        if n.id == id then
            return n
        end
    end
end

local function never(id)
    local ok, lines = pcall(vim.fn.readfile, M.never_file)
    return ok and vim.tbl_contains(lines, id)
end

-- Run gtd.py against the vault; report its output, then call done() on success.
local function gtd(args, done)
    if vim.fn.executable("gtd.py") == 0 then
        return vim.notify("gtd.py isn't on PATH", vim.log.levels.ERROR)
    end
    vim.system(vim.list_extend({ "gtd.py", "paper" }, args), {
        text = true,
        env = { NOTES_VAULT = M.vault },
    }, function(res)
        vim.schedule(function()
            local out = vim.trim((res.stdout or "") .. "\n" .. (res.stderr or ""))
            if res.code ~= 0 then
                return vim.notify(out, vim.log.levels.ERROR)
            end
            vim.notify(out .. "\n<leader>Ln opens it")
            if done then done() end
        end)
    end)
end

local function create(p)
    vim.ui.input({ prompt = "Paper title: ", default = p.project_name }, function(title)
        if not title or vim.trim(title) == "" then
            return
        end
        local projects = { "(none)" }
        for _, f in ipairs(vim.fn.globpath(M.vault, "Projects/*.md", false, true)) do
            projects[#projects + 1] = vim.fn.fnamemodify(f, ":t:r")
        end
        vim.ui.select(projects, { prompt = "GTD project for " .. title }, function(project)
            if not project then
                return
            end
            local args = { "new", vim.trim(title), "--overleaf", p.url }
            if project ~= "(none)" then
                vim.list_extend(args, { "--project", project })
            end
            gtd(args)
        end)
    end)
end

local function link(p)
    local free = vim.tbl_filter(function(n) return not n.id end, M.notes())
    if #free == 0 then
        return vim.notify("Every paper note already has an Overleaf project.")
    end
    vim.ui.select(free, {
        prompt = "Paper note for " .. p.project_name,
        format_item = function(n) return n.name end,
    }, function(note)
        if note then
            gtd({ "link", note.name, "--overleaf", p.url })
        end
    end)
end

function M.ask(p)
    local choices = { "Create a paper note", "Link it to an existing note", "Not now", "Never ask for this project" }
    vim.ui.select(choices, {
        prompt = ("“%s” has no paper note in the vault"):format(p.project_name),
    }, function(choice)
        if choice == choices[1] then
            create(p)
        elseif choice == choices[2] then
            link(p)
        elseif choice == choices[4] then
            vim.fn.mkdir(vim.fn.fnamemodify(M.never_file, ":h"), "p")
            vim.fn.writefile({ p.project_id }, M.never_file, "a")
        end
    end)
end

function M.on_connect(p)
    current = p
    if vim.fn.isdirectory(M.vault) == 0 or asked[p.project_id] or never(p.project_id) then
        return
    end
    asked[p.project_id] = true
    if not M.find(p.project_id) then
        M.ask(p)
    end
end

-- Open the current project's paper note, or offer to make one.
function M.open()
    if not current then
        return vim.notify("Not connected to an Overleaf project")
    end
    local note = M.find(current.project_id)
    if note then
        vim.cmd.edit(vim.fn.fnameescape(note.path))
    else
        M.ask(current)
    end
end

function M.setup()
    vim.api.nvim_create_autocmd("User", {
        pattern = "OverleafConnected",
        group = vim.api.nvim_create_augroup("paper_notes", { clear = true }),
        callback = function(ev) M.on_connect(ev.data) end,
    })
end

return M
