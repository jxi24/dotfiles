local lspconfig = require('lspconfig')
local nvim_status = require('lsp-status')
local completion = require('completion')
local saga = require('lspsaga')

-- local telescope_mapper = require('ji.telescope.mappings')
local wk = require('which-key')

local status = require('ji.lsp_status')

local mapper = function(mode, key, result)
    vim.api.nvim_buf_set_keymap(0, mode, key, "<cmd>lua " .. result .. "<CR>", { noremap = true, silent = true})
end

-- Turn on status
-- status.activate()

saga.init_lsp_saga()

local custom_attach = function(client)
    if client.config.flags then
        client.config.flags.allow_incremental_sync = true
    end

    completion.on_attach(client)

    wk.register({
        l = {
            name = "+lsp",
            n = { "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>", "Next Diagnostic" },
            p = { "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>", "Prev Diagnostic" },
            I = { "<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>", "Show Line Diagnostic" },
            f = { "<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>", "Find Word Def and Reference" },
            D = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Goto Definition" },
            d = { "<cmd>lua require'lspsaga.provider'.preview_definition<CR>", "Preview Definition" },
            i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Goto Implementation" },
            R = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
            r = { "<cmd>lua require'lspsaga.rename'.rename()<CR>", "Rename" },
            h = { "<cmd>lua require'lspsaga.hover'.render_hover_doc()<CR>", "Help" },
            q = { "<cmd>lua require'lspsaga.codeaction'.code_action()<CR>", "Code Action" },
            a = { "<cmd>lua R('ji.telescope')['lsp_code_actions']()<CR>", "List Code Actions" }
        },
    }, { prefix = "<leader>" })


    -- mapper('n', '<leader>ln', 'vim.lsp.diagnostic.goto_next()')
    -- mapper('n', '<leader>lp', 'vim.lsp.diagnostic.goto_prev()')
    -- mapper('n', '<leader>lI', 'vim.lsp.diagnostic.show_line_diagnostics()')

    mapper('n', 'gh', 'require\'lspsaga.provider\'.lsp_finder()')
    mapper('n', 'gd', 'vim.lsp.buf.definition()')
    mapper('n', 'gi', 'vim.lsp.buf.implementation()')
    mapper('n', 'gs', "require('lspsaga.signaturehelp').signature_help()")
    -- mapper('n', 'K', 'vim.lsp.buf.hover()')
    mapper('n', 'K', "require('lspsaga.hover').render_hover_doc()")
    mapper('n', '<C-f>', "require('lspsaga.hover').smart_scroll_hover(1)")
    mapper('n', '<C-b>', "require('lspsaga.hover').smart_scroll_hover(-1)")

    -- mapper('n', '<leader>lf', "require'lspsaga.provider'.lsp_finder()")
    -- mapper('n', '<leader>ld', 'vim.lsp.buf.definition()')
    -- mapper('n', '<leader>li', 'vim.lsp.buf.implementation()')
    -- mapper('n', '<leader>lR', 'vim.lsp.buf.references()')
    -- mapper('n', '<leader>lr', 'vim.lsp.buf.rename()')
    -- mapper('n', '<leader>lh', 'vim.lsp.buf.hover()')
    -- mapper('n', '<leader>lq', 'vim.lsp.buf.code_action()')
    -- mapper('n', '<leader>lq', "require('lspsaga.codeaction').code_action()")
    mapper('v', '<leader>lq', "require('lspsaga.codeaction').code_action()")

    -- telescope_mapper('<leader>la', 'lsp_code_actions', nil, true)

    local filetype = vim.api.nvim_buf_get_option(0, 'filetype')
    if filetype ~= 'lua' then
        mapper('n', 'K', 'vim.lsp.buf.hover()')
    end
    if filetype == 'cpp' then
        vim.api.nvim_buf_set_keymap(0, 'n', '<leader>h', ':ClangdSwitchSourceHeader<CR>', { noremap = true, silent = true})
    end

    mapper('i', '<c-s>', 'vim.lsp.buf.signature_help()')

    vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
end

lspconfig.pyls_ms.setup {
    enable = false,
    on_attach = custom_attach,
    cmd = { "/home/isaacson/.dotnet/dotnet", "exec", "/home/isaacson/ProgramFiles/python-language-server/output/bin/Debug/Microsoft.Python.LanguageServer.dll" }
}

lspconfig.pyls.setup {
    enable = true,
    on_attach = custom_attach,
}

lspconfig.vimls.setup {
    on_attach = custom_attach,
}

-- An example of configuring for `sumneko_lua`,
--  a language server for Lua.
-- First, you must run `:LspInstall sumneko_lua` for this to work.
require('lspconfig').sumneko_lua.setup({
    -- An example of settings for an LSP server.
    --    For more options, see nvim-lspconfig
    settings = {
        Lua = {
            diagnostics = {
                enable = true,
                globals = { "vim" },
            },
        }
    },
  
    on_attach = custom_lsp_attach
})

lspconfig.clangd.setup({
    cmd = {
        "clangd",
        "--background-index",
        "--suggest-missing-includes",
        "--clang-tidy",
        "--header-insertion=iwyu",
    },
    on_attach = custom_attach,

    -- Required for lsp-status
    init_options = {
        clangdFileStatus = true
    },
    handlers = nvim_status.extensions.clangd.setup(),
    capabilities = nvim_status.capabilities,
    filetypes = {"c", "cpp", "objc", "objcpp", "cuda"},
})

lspconfig.fortls.setup({
    on_attach = custom_attach,
})

lspconfig.cmake.setup({
    on_attach = custom_attach,
})

lspconfig.texlab.setup({
    on_attach = custom_attach,
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = {
            severity_limit = "Warning",
        },
    }
)
