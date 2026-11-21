-- Search the text of every talk PDF under ~/Documents/Talks, page by page, and
-- open the chosen page in zathura. One item per page: "where did I show the
-- local Fermi gas plot?" finds the slide.
--
-- Text comes from pdftotext, cached per PDF in ~/.cache/nvim/talk-search and
-- redone only when the PDF changes. PDFs inside figs/, figures/ and notebook/
-- folders (single plots) are left out.
-- In the picker: <CR> opens the page, <c-y> copies the PDF's path.

local M = {}

M.dir = vim.fn.expand("~/Documents/Talks")
M.cache = vim.fn.stdpath("cache") .. "/talk-search"
M.skip = { figs = true, figures = true, notebook = true }

local function pdfs()
    local out = {}
    for _, f in ipairs(vim.fn.globpath(M.dir, "**/*.pdf", false, true)) do
        local parts = vim.split(f:sub(#M.dir + 2), "/")
        local keep = true
        for i = 1, #parts - 1 do
            if M.skip[parts[i]:lower()] then
                keep = false
            end
        end
        if keep then
            out[#out + 1] = f
        end
    end
    return out
end

local function cache_file(f)
    return M.cache .. "/" .. vim.fn.sha256(f) .. ".json"
end

local function stamp(f)
    local st = vim.uv.fs_stat(f)
    return st and (st.size .. ":" .. st.mtime.sec)
end

local function cached(f)
    local ok, data = pcall(function()
        return vim.json.decode(table.concat(vim.fn.readfile(cache_file(f)), "\n"))
    end)
    if ok and type(data) == "table" and data.stamp == stamp(f) then
        return data.pages
    end
end

-- {pdf path: {page texts}}, extracting the uncached PDFs in parallel.
function M.pages(files)
    local out, jobs = {}, {}
    for _, f in ipairs(files) do
        out[f] = cached(f)
        if not out[f] then
            jobs[f] = vim.system({ "pdftotext", "-layout", "-enc", "UTF-8", f, "-" }, { text = true })
        end
    end
    if next(jobs) then
        vim.fn.mkdir(M.cache, "p")
    end
    for f, job in pairs(jobs) do
        local res = job:wait(120000)
        local pages = res.code == 0 and vim.split(res.stdout or "", "\f", { plain = true }) or {}
        if pages[#pages] and vim.trim(pages[#pages]) == "" then
            pages[#pages] = nil
        end
        out[f] = pages
        if res.code == 0 then
            vim.fn.writefile({ vim.json.encode({ stamp = stamp(f), pages = pages }) }, cache_file(f))
        end
    end
    return out
end

function M.items()
    local files = pdfs()
    local new = #vim.tbl_filter(function(f) return not cached(f) end, files)
    if new > 0 then
        vim.notify(("Reading %d new talk PDF%s..."):format(new, new == 1 and "" or "s"))
        vim.cmd.redraw()
    end
    local items = {}
    for f, pages in pairs(M.pages(files)) do
        local rel = f:sub(#M.dir + 2)
        local talk = rel:match("^([^/]+)/") or rel
        for i, text in ipairs(pages) do
            local flat = vim.trim(text:gsub("%s+", " "))
            if flat ~= "" then
                local first = vim.trim((text:match("^%s*([^\n]+)") or ""):gsub("%s+", " "))
                items[#items + 1] = {
                    text = talk .. " " .. flat,
                    file = f,
                    rel = rel,
                    talk = talk,
                    page = i,
                    title = first,
                    body = text,
                    mtime = (vim.uv.fs_stat(f) or { mtime = { sec = 0 } }).mtime.sec,
                }
            end
        end
    end
    -- Newest talks first, then page order.
    table.sort(items, function(a, b)
        if a.mtime ~= b.mtime then
            return a.mtime > b.mtime
        end
        if a.file ~= b.file then
            return a.file < b.file
        end
        return a.page < b.page
    end)
    return items
end

function M.open(item)
    if vim.fn.executable("zathura") == 1 then
        vim.system({ "zathura", "--page=" .. item.page, item.file }, { detach = true })
    else
        vim.ui.open(item.file)
    end
end

function M.pick()
    if vim.fn.isdirectory(M.dir) == 0 then
        return vim.notify("No talks folder at " .. M.dir, vim.log.levels.WARN)
    end
    if vim.fn.executable("pdftotext") == 0 then
        return vim.notify("pdftotext isn't installed (poppler)", vim.log.levels.ERROR)
    end
    Snacks.picker.pick({
        title = "Talks (slide text)",
        items = M.items(),
        format = function(item)
            return {
                { ("%-24s"):format(item.talk:sub(1, 24)), "SnacksPickerLabel" },
                { ("p.%-4d "):format(item.page), "SnacksPickerComment" },
                { item.title },
            }
        end,
        preview = function(ctx)
            ctx.preview:reset()
            ctx.preview:set_title(ctx.item.rel .. "  p." .. ctx.item.page)
            ctx.preview:set_lines(vim.split(ctx.item.body, "\n"))
        end,
        confirm = function(picker, item)
            picker:close()
            if item then
                M.open(item)
            end
        end,
        actions = {
            yank_path = function(_, item)
                if item then
                    vim.fn.setreg("+", item.file)
                    vim.notify("Copied " .. item.file)
                end
            end,
        },
        win = { input = { keys = { ["<c-y>"] = { "yank_path", mode = { "n", "i" } } } } },
    })
end

return M
