" Ensure the correct python is used
let g:python3_host_prog = '~/anaconda3/bin/python'

" Abbreviations
abbr const const

set autoread " detect when a file is changed

set history=1000 " change history to 1000
set textwidth=120

set backupdir=~/.vim/backup
set directory=~/.vim/tmp

if(has('nvim'))
    " show results of a substition as they're happening
    " but don't open a split
    set inccommand=nosplit
endif

set backspace=indent,eol,start " make backspace behave in a sane manner
set clipboard=unnamed

if has('mouse')
    set mouse=a
endif

" Searching
set ignorecase " case insensitive searching
set smartcase " case-sensitive if expression contains a capital letter
set hlsearch " highligh search results
set incsearch " set incremental search, like modern browsers
set nolazyredraw " don't redraw while executing macros

set magic " Set magic on, for regex

" error bells
set noerrorbells
set visualbell
set t_vb=
set tm=500

" Appearance
set number " show line numbers
set wrap " turn on line wrapping
set wrapmargin=8 " wrap lines when coming within n characters of side
set linebreak " set soft wrapping
set showbreak=… " show ellipsis at breaking
set autoindent " automatically set indent of new line
set ttyfast " faster redrawing
set diffopt+=vertical,iwhite,algorithm:patience,hiddenoff
set laststatus=2 " show the status line all the time
set so=7 " set 7 lines to the cursors - when moving vertical
set wildmenu " enhanced command line completion
set hidden " current buffer can be put into background
set showcmd " show incomplete commands
set noshowmode " don't show which mode, disabled for Powerline
set wildmode=list:longest " complete files like a shell
set shell=$SHELL
set cmdheight=1 " command bar height
set title " set terminal title
set showmatch " show matching braces
set mat=2 " how many tenths of a second to blink
set updatetime=300
set signcolumn=yes
set shortmess+=c
set background=dark
set wildignore=.git,*.o,*.a,*.exe,*.la,*.so,*.obj,*.jpg,*.png

" Split right and below
set splitbelow
set splitright

" Tab control
set smarttab " tab respects 'tapstop', 'shiftwidth', and 'softtabstop'
set tabstop=8 " the visible width of tabs
set softtabstop=4 " edit as if the tabs are 4 characters wide
set shiftwidth=4 " number of spaces to use for indent and unindent
set shiftround " round indent to a multiple of 'shiftwidth'
set expandtab " expand tabs to spaces

" Folding
set foldmethod=syntax " fold based on indent
set foldlevelstart=99
set foldnestmax=10 " deepest fold is 10 levels
set nofoldenable " don't fold by default
set foldlevel=1

set t_Co=256 " Expilicty tell vim that the terminal supports 256 colors
" switch cursor to line when in insert mode, and block when not
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
            \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
            \,sm:block-blinkwait175-blinkoff150-blinkon175

if &term =~ '256color'
    " disable background color erase
    set t_ut=
endif

" enable 24 bit color support if supported
if (has("termguicolors"))
    if (!(has("nvim")))
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
    set termguicolors
endif

" highlight conflicts
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" set paste toggle
set pastetoggle=<leader>v

" Increment numbers and letters
set nrformats+=alpha

" Switch windows
fun GotoWindow(id)
    call win_gotoid(a:id)
    MaximizerToggle
endfun
