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
                template = "~/Documents/Obsidian/Work/templates/daily",
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
                folder = "~/Documents/Obsidian/Work/templates",
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
            { "<leader>oc", function()
                                return require("obsidian").util.toggle_checkbox()
                            end,
                    desc = "Toggle checkbox", { buffer = true }},
            { "gf", function() return require("obsidian").util.gf_passthrough() end,
                desc = "gf Passthrough", { buffer = true, noremap = false, expr = true} },
            { "<cr>",
                function()
                    return require("obsidian").util.smart_action()
                end,
                desc = "Obsidian smart action", { buffer = true, expr = true }},
        },
    }
}
