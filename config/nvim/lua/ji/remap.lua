local silent = { silent = true }

-- remap esc
vim.keymap.set("i", "jk", "<esc>")

-- movement
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true} )
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true} )
vim.keymap.set("n", "^", "g^", silent)
vim.keymap.set("n", "$", "g$", silent)
vim.keymap.set("v", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true} )
vim.keymap.set("v", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true} )
vim.keymap.set("v", "^", "g^", silent)
vim.keymap.set("v", "$", "g$", silent)

-- Send to the void and paste
vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<leader>D", "\"_d")
vim.keymap.set("v", "<leader>D", "\"_d")

-- Yank to the clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- Move panes
vim.keymap.set("n", "<leader>.", "<C-^>")
vim.keymap.set("n", "<leader><leader>", ":w<CR>")
vim.keymap.set("n", "<leader>\\", ":vsplit<CR>")
vim.keymap.set("n", "<leader>-", ":split<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
