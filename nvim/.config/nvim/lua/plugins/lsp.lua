return {
    {
        "neovim/nvim-lspconfig",
        -- event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        lazy = false,
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "j-hui/fidget.nvim",
            'saghen/blink.cmp',
        },
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend('force', capabilities,
                require('blink.cmp').get_lsp_capabilities({}, false))

            capabilities = vim.tbl_deep_extend('force', capabilities, {
                textDocument = {
                    foldingRange = {
                        dynamicRegistration = false,
                        lineFoldingOnly = true
                    }
                }
            })

            require('fidget').setup({})
            require('mason').setup()
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'clangd',
                    'fortls',
                    'neocmake',
                    'lua_ls',
                    'rust_analyzer',
                },
                handlers = {
                    function(server_name)
                        require('lspconfig')[server_name].setup {
                            capabilities = capabilities
                        }
                    end,
                },
            })
            vim.diagnostic.config({
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "󰅚 ",
                        [vim.diagnostic.severity.WARN] = "󰀪 ",
                        [vim.diagnostic.severity.INFO] = " ",
                        [vim.diagnostic.severity.HINT] = "󰌶 ",
                    },
                    numhl = {
                        [vim.diagnostic.severity.ERROR] = "",
                        [vim.diagnostic.severity.WARN] = "",
                        [vim.diagnostic.severity.INFO] = "",
                        [vim.diagnostic.severity.HINT] = "",
                    },
                }
            })
        end,
        keys = {
            { "<leader>l", "", desc = "Lsp" },
            { "<leader>li", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
            { "<leader>ld", function() require('telescope.builtin').lsp_definitions({ reuse_win = true }) end, desc = "Goto Definition" },
            { "<leader>lr", function() require('telescope.builtin').lsp_references() end, desc = "References" },
            { "<leader>lI", function() require('telescope.builtin').lsp_implementations({ reuse_win = true }) end, desc = "Goto Implementation" },
            { "<leader>ly", function() require('telescope.builtin').lsp_type_definitions({ reuse_win = true }) end, desc = "Goto Type Definition" },
            { "<leader>lD", vim.lsp.buf.declaration(), desc = "Goto Declaration" },
            -- { "K", vim.lsp.buf.hover, desc = "Hover" },
            { "<leader>lK", vim.lsp.buf.hover, desc = "Hover" },
            { "<C-h>", vim.lsp.buf.signature_help, mode="i", desc = "Signature Help" },
            { "<leader>lR", vim.lsp.buf.rename, desc = "Rename" },
            { "<leader>lp", vim.diagnostic.goto_prev, desc = "Prev Diagnostic" },
            { "<leader>ln", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
            { "<leader>le", vim.diagnostic.open_float, desc = "Show Error Messages" },
            { "<leader>lq", vim.lsp.buf.code_action, desc = "Code action", mode = { "n", "v" }},
            { "<leader>lh", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch to Header/Source" },
        },
    },
    {
        "L3MON4D3/LuaSnip",
        version = 'v2.*',
        build = "make install_jsregexp",
        dependencies = { 'rafamadriz/friendly-snippets' },
        config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
            local ls = require("luasnip")

            vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
            vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump(1) end, {silent = true})
            vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})
            vim.keymap.set({"i", "s"}, "<C-E>", function()
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end, {silent = true})
        end
    },
    {
        "saghen/blink.cmp",
        build = 'cargo build --release',
        dependencies = {
            "rafamadriz/friendly-snippets",
            { 'L3MON4D3/LuaSnip', version = 'v2.*' },
        },

        opts = {
            keymap = { preset = 'default',
                       ['<C-l>'] = { 'accept', 'fallback' },
                       ['<C-j>'] = { 'select_next', 'fallback' },
                       ['<C-k>'] = { 'select_prev', 'fallback' },
                       ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
            },
            appearance = { nerd_font_variant = 'mono' },
            completion = { documentation = { auto_show = false } },
            snippets = { preset = 'luasnip' },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
            fuzzy = { implementation = "prefer_rust_with_warning" }
        },
        opts_extend = { "sources.default" }
    },
    {
        "nvimtools/none-ls.nvim",
        opts = function(_, opts)
            local nls = require("null-ls")
            opts.sources = vim.list_extend(opts.sources or {}, {
                nls.builtins.diagnostics.cmake_lint,
            })
        end,
    },
    {
        "mfussenegger/nvim-lint",
        opts = {
            linters_bt_ft = {
                cmake = { "cmakelint" },
            },
        },
        config = function() end,
    },
}

