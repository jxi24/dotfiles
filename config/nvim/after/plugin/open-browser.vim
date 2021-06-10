let g:openbrowser_commands = [{"name": "google-chrome",
            \"args": ["start", "{browser}", "{uri}"]}]
let g:openbrowser_search_engies = extend(
            \get(g:, 'openbrowser_search_engines', {}),
            \{
            \   'cppreference': 'https://en.cppreference.com/mwiki/index.php?title=Special%3ASearch&search={query}',
            \},
            \ 'keep'
            \)

nnoremap <silent> <leader>osx :call openbrowser#smart_search(expand('<cword>'), "cppreference")<CR>
