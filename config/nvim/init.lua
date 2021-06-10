--         ______  
--        / /  _/    Josh Isaacson
--   __  / // /      https://github.com/jxi24
--  / /_/ // /       https://isaacson.gitlab.io
--  \____/___/    

-- Inspiration and notes taken from TJ Devries
--[[ Notes to people reading my configuration!
Much of the configuration of individual plugins you can find in either:
./after/plugin/*.vim
  This is where configuration for plugins live.
  They get auto sourced on startup. In general, the name of the file configures
  the plugin with the corresponding name.
./lua/ji/*.lua
  This is where configuration for new style plugins live.
  They don't get sourced automatically, but do get sourced by doing something like:
    require('ji.dap')
  or similar. I generally recommend that people do this so that you don't accidentally
  override any of the plugin requires with namespace clashes. So don't just put your configuration
  in "./lua/dap.lua" because then it will override the plugin version of "dap.lua"

--]]

-- if require('ji.first_load')() then
--     return
-- end

-- Leader key -> ","
--
-- In general, it's a good idea to set this early in your config, because otherwise
-- if you have any mappings you set BEFORE doing this, they will be set to the OLD
-- leader
vim.g.mapleader = ','

-- Setup globals that I expect to be always available
require('ji.globals')

-- -- Load packer.nvim files
-- require('ji.plugins')
-- 
-- -- Force loading of astronauta first
-- vim.cmd [[runtime plugin/astronauta.vim]]
-- 
-- -- Load neovim options
-- require('ji.options')
-- 
-- -- Neovim builtin LSP configuration
-- require('ji.lsp')
-- 
-- -- Telescope
-- require('ji.telescope')
-- require('ji.telescope.mappings')

local opt = vim.opt

-- Ignore compiled files and .git files
opt.wildignore = '__pycache__'
opt.wildignore = opt.wildignore + { '*.o', '*~', '*.pyc', '*pycache*', '.git', '*.a', '*.la', '*.so' }

opt.wildmode = {'longest', 'list', 'full'}

-- Cool floating window popup menu for completion on command line
opt.pumblend = 17

opt.wildoptions = 'pum'

-- General
opt.showmode = false
opt.showcmd = true
opt.showmatch = true
opt.cmdheight = 1 -- Height of the command bar
opt.incsearch = true -- Makes search act like search in modern browsers
opt.showmatch = true -- Show matching brackets when text indicator is over them
opt.relativenumber = true -- Show line numbers
opt.number = true -- But show the actual number for the line we're on
opt.ignorecase = true -- Ignore case when searching...
opt.smartcase = true -- ... unless there is a capital letter in the query
opt.hidden = true -- Current buffer can be put into background
opt.equalalways = false -- Don't resize windows always
opt.splitright = true -- Split to the right
opt.splitbelow = true -- Split to the bottom
opt.updatetime = 1000 -- Make updates happen faster
opt.hlsearch = true -- highlight search results
opt.scrolloff = 10 -- Make it so there are always 10 lines below cursor
opt.wildmenu = true -- Use enhanced mode for command completion
opt.signcolumn = 'yes'
opt.title = true
opt.background = 'dark'
opt.laststatus = 2
opt.emoji = true
opt.diffopt = opt.diffopt + {'vertical', 'iwhite', 'hiddenoff'}

-- Tabs
opt.smarttab = true
opt.autoindent = true
opt.cindent = true
opt.wrap = true

opt.smarttab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.shiftround = true

opt.breakindent = true
opt.showbreak = string.rep(' ', 3) -- Wrapping for long lines with ellipsis
opt.linebreak = true

-- Breaks
opt.foldmethod = 'syntax'
opt.foldlevel = 0
opt.modelines = 1

opt.belloff = 'all' -- Just turn the dang bell off

opt.clipboard = 'unnamedplus'
opt.backspace = {'indent', 'eol', 'start'}
opt.inccommand = 'nosplit'

opt.mouse = 'a'

-- Format options
opt.formatoptions = 'cqrnj'

-- set joinspaces
opt.joinspaces = false -- Only one space after punctuation

-- cursor
opt.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkwait175'

-- Tmux support
vim.g["&t_8f"] = "<Esc>[38;2;%lu;%lu;%lum]"
vim.g["&t_8b"] = "<Esc>[48;2;%lu;%lu;%lum]"

-- Setup key mappings
require("ji.mappings").setup()

-- Setup all the plugins
require('ji.plugins')

-- Colors
vim.cmd[[set termguicolors]]
vim.cmd('syntax on')
-- vim.g.base16colorspace = 256
-- vim.g.onedark_terminal_italics = 1
-- vim.g.deepspace_italics = 1
-- vim.g.edge_style = 'neon'
-- vim.g.edge_enable_italic = 1
-- vim.g.edge_disable_italic_comment = 1
-- vim.g.sonokai_style = 'maia'
-- vim.g.sonokai_enable_italic = 1
-- vim.g.sonokai_disable_italic_comment = 1
-- vim.cmd[[colorscheme onedark]]
-- require('colorbuddy').colorscheme('onebuddy')
-- require('colorbuddy').colorscheme('gruvbuddy')
local base16 = require'base16'
base16(base16.themes.onedark, true)
-- require('zephyr').get_zephyr_color()

-- Configure plugins
-- require('ji.setup')

-- Load plugin confs
require('ji.dap')

-- Vimwiki setup
vim.cmd[[let g:vimwiki_list = [{'path': '~/Dropbox/wiki', 'syntax': 'markdown', 'ext': '.md'}] ]]
vim.g.vimwiki_markdown_link_ext = 1
vim.g.taskwiki_markup_syntax = 'markdown'
