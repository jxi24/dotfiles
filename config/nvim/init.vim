" ensure vim-plug is installed and then load it

call functions#PlugLoad()
call plug#begin('~/.config/nvim/plugged')

" General {{{
    " Abbreviations
    abbr cosnt const

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
" }}}

" Appearance {{{
    set number " show line numbers
    set wrap " turn on line wrapping
    set wrapmargin=8 " wrap lines when coming within n characters of side
    set linebreak " set soft wrapping
    set showbreak=... " show ellipsis at breaking
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

    " Tab control
    set smarttab " tab respects 'tapstop', 'shiftwidth', and 'softtabstop'
    set tabstop=8 " the visible width of tabs
    set softtabstop=4 " edit as if the tabs are 4 characters wide
    set shiftwidth=4 " number of spaces to use for indent and unindent
    set shiftround " round indent to a multiple of 'shiftwidth'
    set expandtab " expand tabs to spaces

    " Code folding settings
    Plug 'Konfekt/FastFold'
    let g:fastfold_savehook=1
    let g:fastfold_fdmhook=0
    nmap zuz <Plug>(FastFoldUpdate)
    let g:fastfold_fold_command_suffixes=['x', 'X', 'a', 'A', 'o', 'O', 'c', 'C']
    let g:fastfold_fold_movement_commands=[']z','[z','zj','zk']
    let g:tex_fold_enabled=1
    let g:vimsyn_folding='af'
    let g:xml_syntax_folding=1
    let g:cpp_fold=1

    set foldmethod=syntax " fold based on indent
    set foldlevelstart=99
    set foldnestmax=10 " deepest fold is 10 levels
    set foldlevel=1

    set t_Co=256 " Expilicty tell vim that the terminal supports 256 colors

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

    " Load colorschemes
    Plug 'chriskempson/base16-vim'
    Plug 'joshdick/onedark.vim'

    " LightLine {{{
        Plug 'itchyny/lightline.vim'
        Plug 'nicknisi/vim-base16-lightline'
        let g:lightline = {
            \   'colorscheme': 'base16',
            \   'active': {
            \       'left': [ [ 'mode', 'paste' ],
            \               [ 'gitbranch' ],
            \               [ 'readonly', 'filetype', 'filename' ]],
            \       'right': [ [ 'percent' ], [ 'lineinfo' ],
            \               [ 'fileformat', 'fileencoding' ],
            \               [ 'gitblame', 'currentfunction',  'cocstatus', 'linter_errors', 'linter_warnings' ]]
            \   },
            \   'component_expand': {
            \   },
            \   'component_type': {
            \       'readonly': 'error',
            \       'linter_warnings': 'warning',
            \       'linter_errors': 'error'
            \   },
            \   'component_function': {
            \       'fileencoding': 'helpers#lightline#fileEncoding',
            \       'filename': 'helpers#lightline#fileName',
            \       'fileformat': 'helpers#lightline#fileFormat',
            \       'filetype': 'helpers#lightline#fileType',
            \       'gitbranch': 'helpers#lightline#gitBranch',
            \       'cocstatus': 'coc#status',
            \       'currentfunction': 'helpers#lightline#currentFunction',
            \       'gitblame': 'helpers#lightline#gitBlame'
            \   },
            \   'tabline': {
            \       'left': [ [ 'tabs' ] ],
            \       'right': [ [ 'close' ] ]
            \   },
            \   'tab': {
            \       'active': [ 'filename', 'modified' ],
            \       'inactive': [ 'filename', 'modified' ],
            \   },
            \   'separator': { 'left': '', 'right': '' },
            \   'subseparator': { 'left': '', 'right': '' }
        \ }
    " }}}

" }}}

" General Mappings {{{
    " set a map leader for more key combos
    let mapleader = ','

    " remap esc
    inoremap jk <esc>

    " shortcut to save
    nmap <leader>, :w<cr>

    " set paste toggle
    set pastetoggle=<leader>v

    " edit ~/.config/nvim/init.vim
    map <leader>ev :e! ~/.config/nvim/init.vim<cr>
    " edit gitconfig
    map <leader>eg :e! ~/.gitconfig<cr>

    " clear highlighted search
    noremap <space> :set hlsearch! hlsearch?<cr>

    " activate spell-checking alternatives
    nmap ;s :set invspell spelling=en<cr>

    " markdown to html
    nmap <leader>md :%!markdown --html4tags <cr>

    " remove extra whitespace
    nmap <leader><space> :%s/\s\+$<cr>
    nmap <leader><space><space> :%s/\n\{2,}/\r\r/g<cr>

    " autocomplete movement
    inoremap <expr> <C-j> pumvisible() ? "\<C-N>" : "\<C-j>"
    inoremap <expr> <C-k> pumvisible() ? "\<C-P>" : "\<C-j>"

    " switch between current and last buffer
    nmap <leader>. <c-^>

    " map <silent> <C-h> <Plug>WinMoveLeft
    " map <silent> <C-j> <Plug>WinMoveDown
    " map <silent> <C-k> <Plug>WinMoveUp
    " map <silent> <C-l> <Plug>WinMoveRight

    " Custom plugin remaps
    nmap <silent><leader>z <Plug>Zoom

    " Increment numbers and letters
    " Use = instead of + to make it easier
    set nrformats+=alpha
    nmap = <C-a>
    nmap - <C-x>
    vmap = g<C-a>
    vmap - g<C-x>

    " toggle cursor line
    nnoremap <leader>i :set cursorline!<cr>

    " scroll the viewport faster
    nnoremap <C-e> 3<C-e>
    nnoremap <C-y> 3<C-y>

    " moving up and down work as you would expect
    nnoremap <silent> j gj
    nnoremap <silent> k gk
    nnoremap <silent> ^ g^
    nnoremap <silent> $ g$

" }}}

" AutoGroups {{{
    " file type specific settings
    augroup configgroup
        autocmd!

        " save all files on focus lost, ignoring warnings about untitled buffers
        autocmd FocusLost * silent! wa

        " make quickfix windows take all the lower section of the screen
        " when there are multiple windows open
        autocmd FileType qf wincmd J
        autocmd FileType qf nmap <buffer> q :q<cr>
    augroup END
" }}}

" General Functionality {{{
    " substitute, search, and abbreviate multiple variants of a word
    Plug 'tpope/vim-abolish'

    " tmux integration for vim
    Plug 'benmills/vimux'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'ryanoasis/vim-devicons'

    let g:tmux_navigator_save_on_switch = 1
    let g:tmux_navigator_disable_when_zoomed = 1
    map <leader>vp :VimuxPromptCommand<CR>
    map <leader>vl :VimuxRunLastCommand<CR>

    " Startify: Fancy startup screen for vim {{{
        Plug 'mhinz/vim-startify'

        " Don't change to directory when selecting a file
        let g:startify_files_number = 5
        let g:startify_change_to_dir = 0
        let g:startify_custom_header = [ ]
        let g:startify_relative_path = 1
        let g:startify_use_env = 1

        " Custom startup list, only show MRU from current directory/project
        let g:startify_lists = [
        \  { 'type': 'dir',       'header': [ 'Files '. getcwd() ] },
        \  { 'type': function('helpers#startify#listcommits'), 'header': [ 'Recent Commits' ] },
        \  { 'type': 'sessions',  'header': [ 'Sessions' ]       },
        \  { 'type': 'bookmarks', 'header': [ 'Bookmarks' ]      },
        \  { 'type': 'commands',  'header': [ 'Commands' ]       },
        \ ]

        let g:startify_commands = [
        \   { 'ui': [ 'Install Plugins', ':PlugInstall' ] },
        \   { 'up': [ 'Update Plugins', ':PlugUpdate' ] },
        \   { 'ug': [ 'Upgrade Plugin Manager', ':PlugUpgrade' ] },
        \ ]

        let g:startify_bookmarks = [
            \ { 'c': '~/.config/nvim/init.vim' },
            \ { 'g': '~/.gitconfig' },
            \ { 'b': '~/.bashrc' }
        \ ]

        autocmd User Startified setlocal cursorline
        nmap <leader>st :Startify<cr>
    " }}}

    " add end, endif, etc. automatically
    Plug 'tpope/vim-endwise'

    " context-aware pasting
    Plug 'sickill/vim-pasta'

    " NERDTree {{{
        Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
        Plug 'Xuyuanp/nerdtree-git-plugin'
        Plug 'ryanoasis/vim-devicons'
        let g:WebDevIconsUnicodeDecorateFolderNodes = 1
        let g:DevIconsEnableFoldersOpenClose = 1
        let g:DevIconsEnableFolderExtensionPatternMatching = 1
        let NERDTreeDirArrowExpandable = "\u00a0" " make arrows invisible
        let NERDTreeDirArrowCollapsible = "\u00a0" " make arrows invisible
        let NERDTreeNodeDelimiter = "\u263a" " smiley face

        augroup nerdtree
            autocmd!
            autocmd FileType nerdtree setlocal nolist " turn off whitespace characters
            autocmd FileType nerdtree setlocal nocursorline " turn off line highlighting for performace
        augroup END

        " Toggle NERDTree
        function! ToggleNerdTree()
            if @% != "" && @% !~ "Startify" && (!exists("g:NERDTree") || (g:NERDTree.ExistsForTab() && !g:NERDTree.IsOpen()))
                :NERDTreeFind
            else
                :NERDTreeToggle
            endif
        endfunction
	" Close vim when NERDTree is the only thing open
	autocmd WinEnter * call s:CloseIfOnlyNerdTreeLeft()
	function! s:CloseIfOnlyNerdTreeLeft()
	    if exists("t:NERDTreeBufName")
		if bufwinnr(t:NERDTreeBufName) != -1
		    if winnr("$") == 1
			q
		    endif
		endif
	    endif
	endfunction

        " Toggle NERDTree
        nmap <silent> <leader>k :call ToggleNerdTree()<CR>
        " find the current file in nerdtree without needing to reload the drawer
        nmap <silent> <leader>y <Plug>NERDTreeFind<CR>

        let NERDTreeShowHidden=1
        let g:NERDTreeIndicatorMapCustom = {
        \ "Modified"  : "✹",
        \ "Staged"    : "✚",
        \ "Untracked" : "✭",
        \ "Renamed"   : "➜",
        \ "Unmerged"  : "═",
        \ "Deleted"   : "✖",
        \ "Dirty"     : "✗",
        \ "Clean"     : "✔︎",
        \ 'Ignored'   : '☒',
        \ "Unknown"   : "?"
        \ }
    " }}}

    " FZF {{{
	Plug 'junegunn/fzf', {'dir': '~/.fzf'}
	Plug 'junegunn/fzf.vim'
        let g:fzf_layout = { 'down': '~25%' }

        if isdirectory('.git')
            " if in a git project, use :GFiles
            nmap <silent> <leader>t :GitFiles --cached --others --exclude-standard<cr>
        else
            " otherwise, use :FZF
            nmap <silent> <leader>t :FZF<cr>
        endif

        nmap <silent><leader>s :GFiles?<cr>

        nmap <silent><leader>r :Buffers<cr>
        nmap <silent><leader>e :FZF<cr>
        nmap <leader><tab> <plug>(fzf-maps-n)
        xmap <leader><tab> <plug>(fzf-maps-x)
        omap <leader><tab> <plug>(fzf-maps-o)

        " Insert mode completion
        imap <c-x><c-k> <plug>(fzf-complete-word)
        imap <c-x><c-f> <plug>(fzf-complete-path)
        imap <c-x><c-j> <plug>(fzf-complete-file-ag)
        imap <c-x><c-l> <plug>(fzf-complete-line)
    " }}}

    " vim-fugitive {{{
        Plug 'tpope/vim-fugitive'

        nmap <silent> <leader>gs :Gstatus<cr>
        nmap <leader>ge :Gedit<cr>
        nmap <leader>gP :! git push<CR>
        nmap <leader>gG :! git pull<CR>
    " }}}

    " UltiSnips {{{
        Plug 'SirVer/ultisnips' " Snippets plugin
        Plug 'honza/vim-snippets'
        let g:UltiSnipsExpandTrigger="<C-l>"
        let g:UltiSnipsJumpForwardTrigger="<C-j>"
        let g:UltiSnipsJumpBackwardTrigger="<C-k>"
        let g:ultisnips_python_style="google"
    " }}}

    " coc {{{
        Plug 'neoclide/coc.nvim', {'branch': 'release'}

        let g:coc_global_extensions = [
        \ 'coc-git',
        \ 'coc-sh',
        \ 'coc-emmet',
        \ 'coc-yaml',
        \ 'coc-python',
        \ 'coc-texlab',
        \]

        " autocmd CursorHold * silent call CocActionAsync('highlight')

        " coc-git
        nmap [g <Plug>(coc-git-prevchunk)
        nmap ]g <Plug>(coc-git-nextchunk)
        nmap gs <Plug>(coc-git-chunkinfo)
        nmap gu :CocCommand git.chunkUndo<cr>

        " remap keys for gotos
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-defintion)
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)
        nmap <silent> gh <Plug>(coc-doHover)

        " diagnostics navigation
        nmap <silent> [c <plug>(coc-diagnostic-prev)
        nmap <silent> ]c <plug>(coc-diagnostic-next)

        " rename
        nmap <silent> <leader>rn <plug>(coc-rename)

        " Remap for format selected region
        xmap <leader>f <plug>(coc-format-selected)
        nmap <leader>f <plug>(coc-format-selected)

        " Use K to show documentation in preview window
        nnoremap <silent> K :call <SID>show_documentation()<cr>

        function! s:show_documentation()
            if (index(['vim', 'help'], &filetype) >= 0)
                execute 'h '.expand('<cword>')
            else
                call CocAction('doHover')
            endif
        endfunction

        " tab completion
        inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

        function! s:check_back_space() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1] =~# '\s'
        endfunction

	" Buffergator {{{
	    Plug 'jeetsukumaran/vim-buffergator'
	    " Use the right side of the screen
	    let g:buffergator_viewport_split_policy = 'R'

	    " I want my own keymappings
	    let g:buffergator_suppress_keymaps = 1

	    " Go to the previous buffer open
	    nmap <leader>h :BuffergatorMruCyclePrev<CR>

	    " Go to the next buffer open
	    nmap <leader>l :BuffergatorMruCycleNext<CR>

	    " List all open buffer open
	    nmap <leader>bl :BuffergatorToggle<CR>
	" }}}

    " }}}

    " Language-Specific Configuration {{{
        " cpp {{{
            Plug 'bfrg/vim-cpp-modern'
            let g:cpp_simple_highlight = 1
        " }}}

        " markdown {{{
            Plug 'tpope/vim-markdown', { 'for': 'markdown' }
        " }}}

        " python {{{
        " }}}
    " }}}
" }}}

call plug#end()

" Colorscheme and final setup {{{
    " This call must happen after the plug#end() call to ensure
    " that the colorschemes have been loaded
    if filereadable(expand("~/.vimrc_background"))
        let base16colorspace=256
        source ~/.vimrc_background
    else
        let g:onedark_termcolors=16
        let g:onedark_terminal_italics=1
        colorscheme onedark
    endif
    syntax on
    filetype plugin indent on
    " make the highlighting of tabs and other non-text less annoying
    highlight SpecialKey ctermfg=19 guifg=#333333
    highlight NonText ctermfg=19 guifg=#333333

    " make comments and HTML attributes italic
    highlight Comment cterm=italic term=italic gui=italic
    highlight htmlArg cterm=italic term=italic gui=italic
    highlight xmlAttrib cterm=italic term=italic gui=italic
    " highlight Type cterm=italic term=italic gui=italic
    highlight Normal ctermbg=none
" }}}

" vim:set foldmethod=marker foldlevel=0
