let mapleader = ','
let maplocalleader = '<'

" remap esc
inoremap jk <esc>

" clear highlighted search
noremap <space> :set hlsearch! hlsearch?<cr>

" activate spell-checking alternatives
nmap ;s :set invspell spelling=en_us<cr>

" autocomplete movement
inoremap <expr> <C-j> pumvisible() ? "\<C-N>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-P>" : "\<C-j>"

" keep visual selection when indenting/outdenting
vmap < <gv
vmap > >gv

" enable . command in visual mode
vnoremap . :normal .<cr>

" Increment numbers and letters
" Use = instead of + to make it easier
nmap = <C-a>
nmap - <C-x>
vmap = g<C-a>
vmap - g<C-x>

" scroll the viewport faster
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" moving up and down work as you would expect
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> ^ g^
nnoremap <silent> $ g$
vnoremap <silent> j gj
vnoremap <silent> k gk
vnoremap <silent> ^ g^
vnoremap <silent> $ g$

" inner-line
xnoremap <silent> il :<c-u>normal! g_v^<cr>
onoremap <silent> il :<c-u>normal! g_v^<cr>

" around line
xnoremap <silent> al :<c-u>normal! $v0<cr>
onoremap <silent> al :<c-u>normal! $v0<cr>

" Remove whitespace at end of lines
nnoremap <leader><space> :%s/\s\+$<cr>
