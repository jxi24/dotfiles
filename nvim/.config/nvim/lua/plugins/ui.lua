return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        init = function()
            vim.g.lualine_laststatus = vim.o.laststatus
            if vim.fn.argc(-1) > 0 then
                -- Empty status line until lualine loads
                vim.o.statusline = " "
            else
                vim.o.laststatus = 0
            end
        end,
        opts = function()
            local lualine_require = require("lualine_require")
            lualine_require.require = require

            vim.o.laststatus = vim.g.lualine_laststatus

            local opts = {
                extensions = { "mason", "nvim-dap-ui", "trouble" },
                options = {
                    theme = "auto",
                    globalstatus = vim.o.laststatus == 3,
                    disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
                    component_separators = '',
                    section_separators = '',
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff",
                        { "diagnostics",
                            always_visible = true,
                            colored = true,
                            diagnostics_color = {
                                error = "DiagnosticError",
                                info = "DiagnosticInfo",
                                warn = "DiagnosticWarn"
                            },
                            sections = { "error", "warn", "info" },
                            sources = { "nvim_diagnostic" },
                            symbols = {
                                error = " ",
                                info = " ",
                                warn = " "
                            },
                            update_in_insert = false
                        }
                    },
                    lualine_c = { "filename" },
                    lualine_x = {
                        { "filetype", separator = "" },
                    },
                    lualine_y = {
                        { "progress", separator = " "  },
                    },
                    lualine_z = {
                        { "location" },
                    },
                },
            }

            return opts
        end,
        dependencies = { 'nvim-mini/mini.icons' },
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            cmdline = {
                enabled = true,
                view = "cmdline",
            },
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
            },
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                        },
                    },
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
            },
        },
        keys = {
            { "<leader>sn", "", desc = "+noice" },
            { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
            { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
            { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
    },
    {
        'Bekaboo/dropbar.nvim',
        dependencies = {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
        },
    },
    {
        'mrjones2014/smart-splits.nvim',
        -- Load at startup: it sets the IS_NVIM user var that wezterm uses for pane navigation
        lazy = false,
        opts = {},
        keys = {
             { "<A-h>", function() require('smart-splits').resize_left() end, desc = "Resize left" },
             { "<A-j>", function() require('smart-splits').resize_down() end, desc = "Resize down" },
             { "<A-k>", function() require('smart-splits').resize_up() end, desc = "Resize up" },
             { "<A-l>", function() require('smart-splits').resize_right() end, desc = "Resize right" },
             { "<C-h>", function() require('smart-splits').move_cursor_left() end, desc = "Move left" },
             { "<C-j>", function() require('smart-splits').move_cursor_down() end, desc = "Move down" },
             { "<C-k>", function() require('smart-splits').move_cursor_up() end, desc = "Move up" },
             { "<C-l>", function() require('smart-splits').move_cursor_right() end, desc = "Move right" },
        }
    },
    {
        'nvim-mini/mini.map',
        config = function()
            local map = require('mini.map')
            local diagnostic_integration = map.gen_integration.diagnostic({
                error = { "DiagnosticFloatingError" },
                warn = { "DiagnosticFloatingWarn" },
                info = { "DiagnosticFloatingInfo" },
                hint = { "DiagnosticFloatingHint" },
            })
            local gitsigns = map.gen_integration.gitsigns()
            require('mini.map').setup({ integrations = { diagnostic_integration, gitsigns } })
        end,
        keys = {
            { "<leader>mm", function() require('mini.map').toggle() end, desc = "Toggle map" },
            { "<leader>mM", function() require('mini.map').toggle_side() end, desc = "Toggle map side" },
        },
    },
}
