function! SetServerName()
    let nvim_server_file = "/tmp/curnvimserver.txt"
    let cmd = printf("echo %s > %s", v:servername, nvim_server_file)
    call system(cmd)
endfunction

augroup vimtex_common
    autocmd!
    autocmd FileType tex call SetServerName()
augroup END
