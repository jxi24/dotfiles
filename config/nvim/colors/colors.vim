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
