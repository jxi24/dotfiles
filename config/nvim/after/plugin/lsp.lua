vim.opt.signcolumn = 'yes'

local lsp = require('lsp-zero')
local navic = require('nvim-navic')

lsp.preset('recommended')
lsp.ensure_installed({
	'clangd',
	'fortls',
	'rust_analyzer',
})
lsp.on_attach(function(client, bufnr)
    navic.attach(client, bufnr)
	local opts = {buffer = bufnr, remap = false}
    local wk = require('which-key')
    wk.register({
        l = {
            name = "+LSP",
            d = { function() vim.lsp.buf.definition() end, "Definition", opts },
            w = { function() vim.lsp.buf.workspace_symbol() end, "Symbols", opts },
            d = { function() vim.diagnostic.open_float() end, "Open Diagnostic Float", opts },
            n = { function() vim.diagnostic.goto_next() end, "Goto Next Diagnostic", opts }, 
            p = { function() vim.diagnostic.goto_prev() end, "Goto Prev Diagnostic", opts },
            q = { function() vim.lsp.buf.code_action() end, "Code Action", opts },
            r = { function() vim.lsp.buf.referenes() end, "References", opts },
            R = { function() vim.lsp.buf.rename() end, "Rename", opts },
        },
    }, { prefix = "<leader>" })
	vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)
end)
lsp.setup()
