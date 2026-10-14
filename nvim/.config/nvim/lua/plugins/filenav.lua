-- Oil as a sidebar on the left. The window is tagged with w:oil_sidebar so that
-- <CR> opens files in the window to its right instead of replacing the sidebar.
local function toggle_sidebar()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.w[win].oil_sidebar then
            pcall(vim.api.nvim_win_close, win, false)
            return
        end
    end
    vim.cmd("topleft vsplit")
    vim.api.nvim_win_set_width(0, 40)
    vim.w.oil_sidebar = true
    vim.wo.winfixwidth = true
    require("oil").open() -- parent directory of the current file
end

local function sidebar_select()
    local oil = require("oil")
    local entry = oil.get_cursor_entry()
    local dir = oil.get_current_dir()
    if not vim.w.oil_sidebar or not entry or not dir or entry.type == "directory" then
        return oil.select()
    end
    local prev = vim.fn.win_getid(vim.fn.winnr("#"))
    if prev ~= 0 and prev ~= vim.api.nvim_get_current_win() then
        vim.api.nvim_set_current_win(prev)
    else
        vim.cmd.wincmd("l")
    end
    vim.cmd.edit(vim.fn.fnameescape(dir .. entry.name))
end

return {
    {
        'stevearc/oil.nvim',
        dependencies = { { "nvim-mini/mini.icons", opts = {} } },
        lazy = false,
        opts = {
            keymaps = {
                ["<CR>"] = { callback = sidebar_select, desc = "Open entry (in the right window from the sidebar)" },
                -- Free <C-h>/<C-l> for smart-splits pane navigation
                ["<C-h>"] = false,
                ["<C-l>"] = false,
                ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
                ["R"] = "actions.refresh",
                -- Copy paths (clipboard=unnamedplus, so straight to the system clipboard)
                ["gy"] = { "actions.yank_entry", desc = "Yank full path" },
                ["gY"] = { "actions.yank_entry", opts = { modify = ":." }, desc = "Yank path relative to cwd" },
            },
        },
        keys = {
            { "<leader>E", toggle_sidebar, desc = "File Sidebar (oil, left)" },
        },
    }
}
