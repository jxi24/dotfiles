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
            { "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Toggle checkbox" },
            -- <CR> smart action, ]o/[o link navigation and gf (via includeexpr)
            -- are set up by obsidian.nvim itself in vault buffers.
        },
    }
}
