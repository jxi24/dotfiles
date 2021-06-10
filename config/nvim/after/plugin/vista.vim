let g:vista_default_executive = 'nvim_lsp'
let g:vista_echo_cursor_strategy = 'floating_win'

" Search for objects within the current file with Vista
nnoremap <leader>vf <cmd>Vista finder fzf:nvim_lsp<CR>

" Toggle Vista window
nnoremap <leader>vv <cmd>Vista!!<CR>
