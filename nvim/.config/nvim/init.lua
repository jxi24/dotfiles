vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
vim.g.have_nerd_font = true
vim.g.zig_fmt_autosave = 0

local opt = vim.opt

-- visual options
opt.number = true
opt.relativenumber = true
opt.smartindent = true
opt.shiftwidth = 4
opt.shiftround = true
opt.pumblend = 10
opt.pumheight = 10
opt.termguicolors = true
opt.conceallevel = 2
opt.virtualedit = "block"
opt.confirm = true

-- Sync clipboard between OS and nvim
opt.clipboard = 'unnamedplus'
-- Work around slow startup with finding its own clipboard
-- vim.g.clipboard = {
--   name = 'OSC 52',
--   copy = {
--     ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
--     ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
--   },
--   paste = {
--     ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
--     ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
--   },
-- }

-- completion options
opt.completeopt = "menu,menuone,noselect"
opt.wildmode = "longest:full,full"

-- Use spaces instead of tabs
opt.expandtab = true
opt.tabstop = 4

-- Enable mouse mode
opt.mouse = 'a'

-- Don't show mode since it is in status line
opt.showmode = false

-- Save undo history
opt.undofile = true
opt.undolevels = 10000

-- Save insensitive searching unless using capitals in search
opt.ignorecase = true
opt.smartcase = true

-- Keep signcolumn on by default
opt.signcolumn = 'yes'

-- Decrease update time
opt.updatetime = 250

-- Display which-key popup sooner
opt.timeoutlen = 300

-- Configure split directions
opt.splitright = true
opt.splitbelow = true

-- View substitutions live
opt.inccommand = 'split'

opt.scrolloff = 10
opt.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkwait175'

opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

require("config.keymaps")
require("config.lazy")
require('smart-splits').setup()

vim.cmd.colorscheme "catppuccin-frappe"
