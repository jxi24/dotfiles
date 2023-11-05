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
opt.updatetime = 50 -- Make updates happen faster
opt.hlsearch = false -- highlight search results
opt.incsearch = true -- highlight search results as typing
opt.scrolloff = 10 -- Make it so there are always 10 lines below cursor
opt.wildmenu = true -- Use enhanced mode for command completion
opt.signcolumn = 'yes'
opt.title = true
opt.background = 'dark'
opt.laststatus = 2
opt.emoji = true
opt.diffopt = opt.diffopt + {'vertical', 'iwhite', 'hiddenoff'}
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.termguicolors = true

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

vim.g.mapleader = ' '
