let g:nvim_tree_auto_close = 1
let g:nvim_tree_quit_on_open = 1
let g:nvim_tree_bindings = {
    \ 'edit':            ['<CR>', 'o'],
    \ 'edit_vsplit':     '<c-v>',
    \ 'edit_split':      '<c-s>',
    \ 'edit_tab':        '<c-t>',
    \ 'close_node':      ['<S-CR>', '<BS>'],
    \ 'refresh':         'R',
    \ 'preview':         '<Tab>',
    \ 'create':          'a',
    \ 'remove':          'd',
    \ 'rename':          'r',
    \ 'cut':             'x',
    \ 'paste':           'p',
    \ 'copy':            'c',
    \}

nnoremap <leader>k :NvimTreeToggle<CR>
