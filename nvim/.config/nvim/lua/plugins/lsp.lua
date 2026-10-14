return {
    {
        -- Only supplies the server definitions in lsp/*.lua; servers are configured with
        -- vim.lsp.config() and enabled by mason-lspconfig through vim.lsp.enable().
        -- blink.cmp registers its completion capabilities for every server itself.
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "j-hui/fidget.nvim",
        },
        config = function()
            -- clangd writes its info-level log to stderr, which nvim records in lsp.log as errors
            vim.lsp.config('clangd', { cmd = { 'clangd', '--log=error' } })

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
            })
            vim.diagnostic.config({
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "󰅚 ",
                        [vim.diagnostic.severity.WARN] = "󰀪 ",
                        [vim.diagnostic.severity.INFO] = " ",
                        [vim.diagnostic.severity.HINT] = "󰌶 ",
                    },
                },
            })
        end,
        -- Picker-based <leader>l maps (definitions, references, ...) live in snacks.lua.
        -- Built-in equivalents also exist: K, grn, gra, grr, gri, gO, [d, ]d, <C-s>.
        keys = {
            { "<leader>l", "", desc = "Lsp" },
            { "<leader>li", "<cmd>checkhealth vim.lsp<cr>", desc = "Lsp Info" },
            { "<leader>lK", vim.lsp.buf.hover, desc = "Hover" },
            { "<C-h>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help" },
            { "<leader>lR", vim.lsp.buf.rename, desc = "Rename" },
            { "<leader>lp", function() vim.diagnostic.jump({ count = -1, float = true }) end, desc = "Prev Diagnostic" },
            { "<leader>ln", function() vim.diagnostic.jump({ count = 1, float = true }) end, desc = "Next Diagnostic" },
            { "<leader>le", vim.diagnostic.open_float, desc = "Show Error Messages" },
            { "<leader>lq", vim.lsp.buf.code_action, desc = "Code action", mode = { "n", "v" } },
            { "<leader>lh", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch to Header/Source" },
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
        dependencies = {
            "saghen/blink.lib",
            "rafamadriz/friendly-snippets",
            { 'L3MON4D3/LuaSnip', version = 'v2.*' },
        },
        build = function() require('blink.cmp').build():wait(60000) end,

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
        "mfussenegger/nvim-lint",
        ft = { "cmake" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                cmake = { "cmake_lint" },
            }
            vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
                group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
                callback = function() lint.try_lint() end,
            })
            lint.try_lint()
        end,
    },
}
