if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')

    " Test vim-bibtex
    Plug 'jxi24/vim-bibtex', { 'do': ':UpdateRemotePlugins' }

    " Test neocmake
    Plug '~/Documents/Tools/neocmake', { 'do': ':UpdateRemotePlugins' }

    " Test What I have done
    Plug '~/Documents/Tools/lua-plugin'

    " Load colorschemes
    Plug 'chriskempson/base16-vim'
    Plug 'joshdick/onedark.vim'

    " LightLine
    Plug 'itchyny/lightline.vim'
    Plug 'nicknisi/vim-base16-lightline'

    " substitute, search, and abbreviate multiple variants of a word
    Plug 'tpope/vim-abolish'

    " Easy commenting motions
    Plug 'tpope/vim-commentary'

    " mappings which are simply short normal mode aliases for commonly used ex commands
    Plug 'tpope/vim-unimpaired'

    " mappings to easily delete, change and add such surroundings in paris, such as quotes, parens, etc.
    Plug 'tpope/vim-surround'

    " tmux integration for vim
    Plug 'benmills/vimux'
    Plug 'christoomey/vim-tmux-navigator'

    " enables repeating other supported plugins with the . command
    Plug 'tpope/vim-repeat'

    " add end, endif, etc. automatically
    Plug 'tpope/vim-endwise'

    " add floating terminal
    Plug 'voldikss/vim-floaterm'

    " Startify: Fancy startup screen for vim
    Plug 'mhinz/vim-startify'

    " Close buffers but keep splits
    Plug 'moll/vim-bbye'

    " context-aware pasting
    Plug 'sickill/vim-pasta'

    " DevIcons
    Plug 'ryanoasis/vim-devicons'

    " FZF
    Plug 'junegunn/fzf', {'dir': '~/.fzf'}
    Plug 'junegunn/fzf.vim'

    " vim-fugitive
    Plug 'tpope/vim-fugitive'

    " vimagit
    Plug 'jreybert/vimagit'

    " Snippets
    Plug 'honza/vim-snippets'

    " coc
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    " Language-Specific Plugins {{{
        " cpp
        Plug 'jackguo380/vim-lsp-cxx-highlight'

        " markdown
        Plug 'tpope/vim-markdown', { 'for': 'markdown' }

        " Mathematica
        Plug 'voldikss/vim-mma'
    " }}}
    
    " OrgMode
    Plug 'jceb/vim-orgmode'

    " Calendar
    Plug 'itchyny/calendar.vim'

    " VimWiki
    Plug 'vimwiki/vimwiki'

    " Which Key
    Plug 'liuchengxu/vim-which-key'

call plug#end()

" Automatically install missing plugins on startup
autocmd VimEnter *
    \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \|     PlugInstall --sync | q
    \| endif
