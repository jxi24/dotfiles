local map = vim.keymap.set
local silent = { silent = true }

-- remap esc
map('i', 'jk', '<Esc>', { desc = "Exit insert mode" })

-- movement
map('v', '<', '<gv')
map('v', '>', '>gv')
map('v', 'J', ":m '>+1<CR>gv=gv'")
map('v', 'K', ":m '<-2<CR>gv=gv'")
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true} )
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true} )
map('n', '^', 'g^', silent)
map('n', '$', 'g$', silent)
map('v', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true} )
map('v', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true} )
map('v', '^', 'g^', silent)
map('v', '$', 'g$', silent)

map('n', '<leader>.', '<C-^>', { desc = "Last edited buffer" })
map('n', '<leader><leader>', ':w<CR>')
map('n', '<leader>\\', ':vsplit<CR>')
map('n', '<leader>-', ':split<CR>')
map('n', '<leader>q', ':q<CR>')
