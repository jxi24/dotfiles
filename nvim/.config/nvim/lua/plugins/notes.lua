-- Set the checkbox on the current line to the state returned by `next_state`
-- (called with the current state, or nil if there is no checkbox yet).
-- Adds a checkbox to list items and plain lines that don't have one.
local function set_checkbox(next_state)
    local line = vim.api.nvim_get_current_line()
    local indent, rest = line:match("^(%s*)(.*)$")
    local marker = rest:match("^[-*+]%s+") or rest:match("^%d+[.)]%s+")
    local body = marker and rest:sub(#marker + 1) or rest
    local state, text = body:match("^%[(.)%]%s?(.*)$")
    local new_state = next_state(state)
    vim.api.nvim_set_current_line(
        indent .. (marker or "- ") .. "[" .. new_state .. "] " .. (state and text or body)
    )
end

return {
    {
        "obsidian-nvim/obsidian.nvim",
        version = "*",
        lazy = true,
        ft = "markdown",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
            workspaces = {
                {
                    name = "Work",
                    path = "~/Documents/Obsidian/Work/",
                },
                {
                    name = "Personal",
                    path = "~/Documents/Obsidian/Personal/",
                },
            },
            daily_notes = {
                date_format = "%Y-%m-%d",
                template = "daily.md", -- relative to templates.folder
                folder = "Daily Notes"
            },
            completion = {
                nvim_cmp = false,
                blink = true,
                min_chars = 2,
            },
            legacy_commands = false,
            follow_url_func = function(url)
                vim.fn.jobstart({"xdg-open", url})
            end,
            templates = {
                folder = "Templates", -- relative to the vault root; a "~/" path here is joined onto the vault and creates <vault>/~/...
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
                substitutions = {
                    name_date = function()
                        return os.date("%b %d, %Y", os.time())
                    end,
                }
            },
        },
        keys = {
            { "<leader>o", "", desc = "Obsidian" },
            { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Today's note" },
            { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday's note" },
            { "<leader>od", "<cmd>Obsidian dailies<cr>", desc = "Open daily note selector" },
            { "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Cycle checkbox" },
            {
                "<leader>ox",
                function() set_checkbox(function() return "x" end) end,
                desc = "Mark checkbox done",
            },
            {
                "<leader>oX",
                function() set_checkbox(function(s) return s == "x" and " " or "x" end) end,
                desc = "Toggle checkbox done/undone",
            },
            -- <CR> smart action, ]o/[o link navigation and gf (via includeexpr)
            -- are set up by obsidian.nvim itself in vault buffers.
        },
    }
}
