let g:fzf_layout = { 'down': '~25%' }
let g:fzf_tags_command = 'ctags -R'

function! s:Git_Files()
    if isdirectory('.git')
        " If in a git project, use :GFiles
        :GitFiles --cached --others --exclude-standard<cr>
    else
        " otherwise, use :FZF
        :FZF<cr>
    endif
endfunction

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)
