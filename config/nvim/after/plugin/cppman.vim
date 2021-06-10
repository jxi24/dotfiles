function! s:JICppMan()
    let old_isk = &iskeyword
    setl iskeyword+=:
    let str = expand("<cword>")
    let &l:iskeyword = old_isk
    execute 'Man ' . str
endfunction
command! JICppMan :call s:JICppMan()

au FileType cpp nnoremap <buffer>K :JICppMan<CR>
