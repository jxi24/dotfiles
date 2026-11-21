-- Cite papers from the Work vault's paper notes, or from an INSPIRE search.
-- Replaces papis.nvim: nothing is stored here. The vault's arXiv notes
-- (arxiv-tui/**, which carry texkey, title, authors and summary) and our own
-- papers (Papers/*.md) are read when the picker opens; INSPIRE is asked over
-- its public API. After citing, `gtd.py paper bib PAPER` fills the .bib.
--
-- Inserts, at the cursor:
--   .tex       the INSPIRE texkey (else the arXiv number), inside \cite{...} if
--              the cursor is in one, else as \cite{key}. Tab selects several.
--   markdown   a [[note]] link for vault papers, an INSPIRE link otherwise
--   other      the key
-- In the picker: <c-o> opens the vault note, <c-b> the arXiv or INSPIRE page,
-- <c-y> copies the key. Search a texkey with a space for the colon
-- ("Sahin 2026ssq"): snacks reads "word:" as a filter on a field named word.

local M = {}

M.vault = vim.env.NOTES_VAULT or vim.fn.expand("~/Documents/Obsidian/Work")

local function unquote(v)
    return (v:gsub("^%s+", ""):gsub("%s+$", ""):gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1"))
end

-- Top-level `key: value` lines of a note's frontmatter.
local function frontmatter(path)
    local ok, lines = pcall(vim.fn.readfile, path, "", 40)
    if not ok or lines[1] ~= "---" then
        return nil
    end
    local fm = {}
    for i = 2, #lines do
        if lines[i] == "---" then
            return fm
        end
        local k, v = lines[i]:match("^([%w_-]+):%s*(.*)$")
        if k then
            fm[k] = unquote(v)
        end
    end
    return fm
end

local function first_author(authors)
    local first = (authors or ""):gsub("%[%[[^|%]]*|", ""):gsub("[%[%]\"]", ""):match("^%s*([^,]+)") or ""
    return first:match("(%S+)%s*$") or first
end

-- One item per vault paper note with an arXiv number, newest first.
local function vault_items()
    local items = {}
    local files = vim.fn.globpath(M.vault, "arxiv-tui/**/*.md", false, true)
    vim.list_extend(files, vim.fn.globpath(M.vault, "Papers/*.md", false, true))
    for _, path in ipairs(files) do
        local fm = frontmatter(path)
        local id = fm and fm.arxiv_id
        if id and id ~= "" then
            local title = fm.title or vim.fn.fnamemodify(path, ":t:r")
            local key = (fm.texkey and fm.texkey ~= "") and fm.texkey or id
            local projects = (fm["related-projects"] or ""):gsub("[%[%]\"]", "")
            items[#items + 1] = {
                text = table.concat({ key, id, title, fm.authors or "", projects, fm.summary or "" }, " "),
                file = path,
                key = key,
                arxiv = id,
                title = title,
                author = first_author(fm.authors),
                date = fm.imported or fm.posted or "",
                stem = vim.fn.fnamemodify(path, ":t:r"),
            }
        end
    end
    table.sort(items, function(a, b) return a.date > b.date end)
    return items
end

-- Is the text before the cursor inside \cite{...} (or \citep[..][..]{...})?
local function in_cite(before)
    local open = before:match(".*(){[^}]*$")
    if not open then
        return false
    end
    local s = before:sub(1, open - 1)
    while s:match("%b[]%s*$") do
        s = s:gsub("%b[]%s*$", "")
    end
    return s:match("\\%a*cite%a*%*?%s*$") ~= nil
end

local function citation(items, ft, before)
    local keys = vim.tbl_map(function(it) return it.key end, items)
    if ft == "tex" or ft == "plaintex" or ft == "bib" then
        if in_cite(before) then
            local sep = before:match("[{,]%s*$") and "" or ","
            return sep .. table.concat(keys, ",")
        end
        return "\\cite{" .. table.concat(keys, ",") .. "}"
    elseif ft == "markdown" then
        return table.concat(vim.tbl_map(function(it)
            if it.stem then
                return "[[" .. it.stem .. "]]"
            end
            return ("[%s](https://inspirehep.net/literature?q=texkeys:%s)"):format(it.key, it.key)
        end, items), ", ")
    end
    return table.concat(keys, ",")
end

-- Put the cursor back at byte `col` of `row`, in insert mode if it started there.
-- At the end of the line, insert mode has to append (startinsert!).
local function resume(o, row, col)
    local len = #(vim.api.nvim_buf_get_lines(o.buf, row - 1, row, false)[1] or "")
    if o.insert and col >= len then
        vim.api.nvim_win_set_cursor(o.win, { row, math.max(len - 1, 0) })
        vim.cmd("startinsert!")
    else
        vim.api.nvim_win_set_cursor(o.win, { row, o.insert and col or math.max(col - 1, 0) })
        if o.insert then vim.cmd.startinsert() end
    end
end

local function pick(title, items, origin)
    Snacks.picker.pick({
        title = title,
        items = items,
        preview = function(ctx)
            if ctx.item.file then
                return Snacks.picker.preview.file(ctx)
            end
            ctx.preview:reset()
            ctx.preview:set_lines(vim.split(ctx.item.abstract or "", "\n"))
            ctx.preview:highlight({ ft = "markdown" })
        end,
        format = function(item)
            return {
                { ("%-22s"):format(item.key), "SnacksPickerLabel" },
                { (" %-14s "):format(item.author or ""), "SnacksPickerComment" },
                { item.title },
            }
        end,
        confirm = function(picker)
            local chosen = picker:selected({ fallback = true })
            picker:close()
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(origin.buf) or not vim.api.nvim_win_is_valid(origin.win) then
                    return
                end
                vim.api.nvim_set_current_win(origin.win)
                if #chosen == 0 then
                    return resume(origin, origin.row, origin.col)
                end
                local row, col = origin.row, origin.col
                local line = vim.api.nvim_buf_get_lines(origin.buf, row - 1, row, false)[1] or ""
                local text = citation(chosen, vim.bo[origin.buf].filetype, line:sub(1, col))
                vim.api.nvim_buf_set_text(origin.buf, row - 1, col, row - 1, col, { text })
                resume(origin, row, col + #text)
            end)
        end,
        actions = {
            open_note = function(picker, item)
                if item and item.file then
                    picker:close()
                    vim.schedule(function() vim.cmd.edit(vim.fn.fnameescape(item.file)) end)
                end
            end,
            browse = function(_, item)
                if item then
                    vim.ui.open(item.arxiv and item.arxiv ~= "" and ("https://arxiv.org/abs/" .. item.arxiv)
                        or ("https://inspirehep.net/literature?q=texkeys:" .. item.key))
                end
            end,
            yank_key = function(_, item)
                if item then
                    vim.fn.setreg("+", item.key)
                    vim.notify("Copied " .. item.key)
                end
            end,
        },
        win = {
            input = {
                keys = {
                    ["<c-o>"] = { "open_note", mode = { "n", "i" } },
                    ["<c-b>"] = { "browse", mode = { "n", "i" } },
                    ["<c-y>"] = { "yank_key", mode = { "n", "i" } },
                },
            },
        },
    })
end

-- Where the citation goes: after the cursor in normal mode, at it in insert mode.
local function origin()
    local win = vim.api.nvim_get_current_win()
    local row, col = unpack(vim.api.nvim_win_get_cursor(win))
    local insert = vim.fn.mode():sub(1, 1) == "i"
    local line = vim.api.nvim_get_current_line()
    if not insert and #line > 0 then
        col = math.min(col + 1, #line)
    end
    return { win = win, buf = vim.api.nvim_get_current_buf(), row = row, col = col, insert = insert }
end

function M.vault_pick()
    if vim.fn.isdirectory(M.vault) == 0 then
        return vim.notify("No notes vault at " .. M.vault, vim.log.levels.WARN)
    end
    pick("Cite (vault papers)", vault_items(), origin())
end

function M.inspire_pick()
    local o = origin()
    vim.ui.input({ prompt = "INSPIRE search: " }, function(query)
        if not query or query == "" then
            return
        end
        local url = "https://inspirehep.net/api/literature?size=25&fields="
            .. "titles,authors.full_name,texkeys,arxiv_eprints,abstracts,earliest_date&q=" .. vim.uri_encode(query)
        vim.system({ "curl", "-sf", "--max-time", "20", url }, { text = true }, function(res)
            vim.schedule(function()
                local ok, data = pcall(vim.json.decode, res.stdout or "")
                if res.code ~= 0 or not ok then
                    return vim.notify("INSPIRE search failed", vim.log.levels.ERROR)
                end
                local in_vault = {}
                if vim.fn.isdirectory(M.vault) == 1 then
                    for _, it in ipairs(vault_items()) do in_vault[it.arxiv] = it end
                end
                local items = {}
                for _, hit in ipairs(data.hits and data.hits.hits or {}) do
                    local md = hit.metadata or {}
                    local key = md.texkeys and md.texkeys[1]
                    if key then
                        local arxiv = md.arxiv_eprints and md.arxiv_eprints[1] and md.arxiv_eprints[1].value or ""
                        local title = md.titles and md.titles[1] and md.titles[1].title or "?"
                        local author = md.authors and md.authors[1] and md.authors[1].full_name or ""
                        local abstract = md.abstracts and md.abstracts[1] and md.abstracts[1].value or ""
                        local note = in_vault[arxiv]
                        items[#items + 1] = {
                            text = key .. " " .. title .. " " .. author,
                            key = key,
                            arxiv = arxiv,
                            title = (note and "● " or "") .. title,
                            author = author:match("^([^,]+)") or author,
                            file = note and note.file,
                            stem = note and note.stem,
                            abstract = ("# %s\n\n%s · %s · arXiv:%s\n\n%s"):format(
                                title, author, md.earliest_date or "", arxiv, abstract),
                        }
                    end
                end
                if #items == 0 then
                    return vim.notify("INSPIRE found nothing for: " .. query)
                end
                pick("Cite (INSPIRE: " .. query .. ")", items, o)
            end)
        end)
    end)
end

-- Exposed for checking from a headless nvim.
M.internal = { vault_items = vault_items, in_cite = in_cite, citation = citation }

return M
