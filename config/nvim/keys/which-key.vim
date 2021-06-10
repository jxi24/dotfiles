" Map leader to which_key
nnoremap <silent> <leader> :silent <c-u> :silent WhichKey ','<CR>
vnoremap <silent> <leader> :silent <c-u> :silent WhickKeyVisual ','<CR>

" Create map to add keys to
let g:which_key_map = {}
" Define a separator
let g:which_key_sep = '→'

" Not a fan of floating window for this
let g:which_key_use_floating_win = 0

" Hide status line
autocmd! FileType which_key
autocmd FileType which_key set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

" Single mappings
let g:which_key_map['.'] = ['<c-^>',                        'last-buffer']
let g:which_key_map['m'] = ['<Plug>MarkdownPreviewToggle',  'Toggle Markdown Preview']
let g:which_key_map[','] = [':w',                           'Write']
let g:which_key_map['z'] = [':MaximizerToggle!',            'Zoom']
let g:which_key_map['c'] = [':wincmd q',                    'Close Window']
let g:which_key_map['i'] = [':set cursorline!',             'cursor line']
let g:which_key_map['\'] = [':vsplit',                      'vertical split']
let g:which_key_map['-'] = [':split',                       'horizontal split']
let g:which_key_map['s'] = [':Startify',                    'start screen']
let g:which_key_map['k'] = [':CocCommand explorer',         'explorer']
let g:which_key_map['h'] = [':CocCommand clangd.switchSourceHeader', 'Switch to Header/Source']

" Group mappings

" a is for actions
let g:which_key_map.a = {
            \ 'name' : '+actions',
            \ 'e' : [':CocCommand explorer',                   'explorer'],
            \ 'f' : [':CocCommand explorer --preset floating', 'floating explorer'],
            \ 't' : [':FloatermToggle',                        'terminal'],
            \}

" b is for buffer
let g:which_key_map.b = {
            \ 'name' : '+buffer',
            \ 'd' : [':Bdelete',   'delete buffer'],
            \ 'f' : [':bfirst',    'first-buffer'],
            \ 'h' : [':Startify',  'home-buffer'],
            \ 'l' : ['<c-^>',      'last-buffer'],
            \ 'n' : [':bnext',     'next-buffer'],
            \ 'p' : [':bprevious', 'previous-buffer'],
            \ '?' : [':Buffers',   'fzf-buffer'],
            \}

" e is for edit
let g:which_key_map.e = {
            \ 'name' : '+edit',
            \ 'c' : [':CocConfig',       'coc config'],
            \ 'g' : [':e! ~/.gitconfig', 'git config'],
            \ 'o' : [':e! ~/org/',       'org file'],
            \ 'v' : [':e! $MYVIMRC',     'Nvim config'],
            \}

" s is for search
let g:which_key_map.s = {
            \ 'name' : '+search',
            \ '/' : [':History/',         'history'],
            \ ';' : [':Commands',         'commands'],
            \ 'b' : [':BLines',           'current buffer'],
            \ 'B' : [':Buffers',          'open buffers'],
            \ 'c' : [':Commits',          'commits'],
            \ 'C' : [':BCommits',         'buffer commits'],
            \ 'f' : [':Git_Files',            'files'],
            \ 'g' : [':GFiles',           'git files'],
            \ 'G' : [':GFiles?',          'modified git files'],
            \ 'l' : [':Lines',            'lines'] ,
            \ 'm' : [':Marks',            'marks'] ,
            \ 'M' : [':Maps',             'normal maps'] ,
            \ 'p' : [':Helptags',         'help tags'] ,
            \ 'P' : [':Tags',             'project tags'],
            \ 's' : [':CocList snippets', 'snippets'],
            \ 'S' : [':Colors',           'color schemes'],
            \ 't' : [':Rg',               'text Rg'],
            \ 'T' : [':BTags',            'buffer tags'],
            \ 'w' : [':Windows',          'search windows'],
            \ 'y' : [':Filetypes',        'file types'],
            \ 'z' : [':FZF',              'FZF'], 
            \}

" g is for git
let g:which_key_map.g = {
            \ 'name' : '+git',
            \ '[' : ['<Plug>(coc-git-prevchunk)', 'previous chunk'],
            \ ']' : ['<Plug>(coc-git-prevchunk)', 'next chunk'],
            \ 'a' : [':Git add .',                'add all'],
            \ 'A' : [':Git add %',                'add current'],
            \ 'b' : [':Git blame',                'blame'],
            \ 'c' : [':Git commit',               'commit'],
            \ 'd' : [':Git diff',                 'diff'],
            \ 'D' : [':Gdiffsplit',               'diff split'],
            \ 'g' : [':Magit',                    'magit'],
            \ 'i' : ['<Plug>(coc-git-chunkinfo)', 'chunk info'],
            \ 'l' : [':Git log',                  'log'],
            \ 'p' : [':Git push',                 'push'],
            \ 'P' : [':Git pull',                 'pull'],
            \ 'r' : [':GRemove',                  'remove'],
            \ 's' : [':Gstatus',                  'status'],
            \ 'u' : [':CocCommad git.chunkUndo',  'undo chunk'],
            \}

" l is for language server protocol
let g:which_key_map.l = {
            \ 'name' : '+lsp',
            \ '.' : [':CocConfig',                            'config'],
            \ ';' : ['<Plug>(coc-refactor)',                  'refactor'],
            \ 'a' : ['<Plug>(coc-codeaction)',                'line action'],
            \ 'A' : ['<Plug>(coc-codeaction-selected)',       'selected action'],
            \ 'b' : [':CocNext',                              'next action'],
            \ 'B' : [':CocPrev',                              'prev action'],
            \ 'c' : [':CocList commands',                     'commands'],
            \ 'd' : ['<Plug>(coc-definition)',                'definition'],
            \ 'D' : ['<Plug>(coc-declaration)',               'declaration'],
            \ 'e' : [':CocList extensions',                   'extensions'],
            \ 'f' : ['<Plug>(coc-format-selected)',           'format selected'],
            \ 'F' : ['<Plug>(coc-format)',                    'format'],
            \ 'h' : ['<Plug>(coc-float-hide)',                'hide'],
            \ 'H' : [':CocCommand clangd.switchSourceHeader', 'Switch to Header/Source'],
            \ 'i' : ['<Plug>(coc-implementation)',            'implementation'],
            \ 'I' : [':CocList diagnostics',                  'diagnostics'],
            \ 'j' : ['<Plug>(coc-float-jump)',                'float jump'],
            \ 'l' : ['<Plug>(coc-codelens-action)',           'code lens'],
            \ 'n' : ['<Plug>(coc-diagnostic-next)',           'next diagnostic'],
            \ 'N' : ['<Plug>(coc-diagnostic-next-error)',     'next error'],
            \ 'o' : ['<Plug>(coc-openlink)',                  'open link'],
            \ 'O' : [':CocList outline',                      'outline'],
            \ 'p' : ['<Plug>(coc-diagnostic-prev)',           'prev diagnostic'],
            \ 'P' : ['<Plug>(coc-diagnostic-prev-error)',     'prev error'],
            \ 'q' : ['<Plug>(coc-fix-current)',               'quickfix'],
            \ 'r' : ['<Plug>(coc-rename)',                    'rename'],
            \ 'R' : ['<Plug>(coc-references)',                'references'],
            \ 's' : [':CocList -I symbols',                   'references'],
            \ 'S' : [':CocList snippets',                     'snippets'],
            \ 't' : ['<Plug>(coc-type-definition)',           'type definition'],
            \ 'u' : [':CocListResume',                        'resume list'],
            \ 'U' : [':CocUpdate',                            'update CoC'],
            \ 'z' : [':CocDisable',                           'disable CoC'],
            \ 'Z' : [':CocEnable',                            'enable CoC'],
            \}

" t is for terminal
let g:which_key_map.t = {
            \ 'name' : '+terminal',
            \ ';' : [':FloatermNew --wintype=popup --height=6', 'terminal'],
            \ 'f' : [':FloatermNew fzf',                        'fzf'],
            \ 'g' : [':FloatermNew lazygit',                    'git'],
            \ 'n' : [':FloatermNew node',                       'node'],
            \ 'p' : [':FloatermNew python',                     'python'],
            \ 'r' : [':FloatermNew vifm',                       'vifm'],
            \ 't' : [':FloatermToggle',                         'toggle'],
            \ 'h' : [':FloatermNew htop',                       'htop'],
            \ }

" d is for debug
let g:which_key_map.d = {
            \ 'name' : '+debug',
            \ 'r' : [':call vimspector#Launch()', 'launch'],
            \ 'R' : [':call vimspector#Reset()', 'reset'],
            \ 'c' : [':call vimspector#Continue()', 'continue'],
            \ 'l' : ['<Plug>VimspectorStepInto', 'step into'],
            \ 'j' : ['<Plug>VimspectorStepOver', 'step over'],
            \ 'k' : ['<Plug>VimspectorStepOut', 'step out'],
            \ 'q' : ['<Plug>VimspectorRestart', 'restart'],
            \ 'h' : ['<Plug>VimspectorRunToCursor', 'run to cursor'],
            \ 'b' : ['<Plug>VimspectorToggleBreakpoint', 'toggle breakpoint'],
            \ 'B' : ['<Plug>VimspectorToggleConditionalBreakpoint', 'toggle conditional breakpoint'],
            \ 'C' : [':call GotoWindow(g:vimspector_session_windows.code)', 'code window'],
            \ 'T' : [':call GotoWindow(g:vimspector_session_windows.tagpage)', 'tag window'],
            \ 'V' : [':call GotoWindow(g:vimspector_session_windows.variables)', 'variables window'],
            \ 'W' : [':call GotoWindow(g:vimspector_session_windows.watches)', 'watches window'],
            \ 'S' : [':call GotoWindow(g:vimspector_session_windows.stack_trace)', 'stack trace'],
            \ 'O' : [':call GotoWindow(g:vimspector_session_windows.output)', 'output window'],
            \ }

" f is for find
let g:which_key_map.f = {
            \ 'name' : '+find',
            \ 'f' : [':Telescope find_files', 'files'],
            \ 'g' : [':Telescope live_grep',  'grep'],
            \ 'b' : [':Telescope buffers',    'buffers'],
            \ 'h' : [':Telescope help_tags',  'tags'],
            \ }

call which_key#register(',', 'g:which_key_map')
