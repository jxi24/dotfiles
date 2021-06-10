local dial = require('dial')

-- dial.searchlist.normal = {
--     dial.augends.number.decimal,
--     dial.augends.number.hex,
--     dial.augends.number.binary,
--     dial.augends.date["%Y/%m/%d"],
--     dial.augends.alph_small,
--     dial.augends.alph_capital,
--     dial.augends.markup.markdown_header,
-- }

-- dial.searchlist.visual = dial.searchlist.normal

vim.api.nvim_set_keymap('n', '<A-=>', '<Plug>(dial-increment)', {
    noremap = false,
    silent = true
})

vim.api.nvim_set_keymap('v', '<A-=>', '<Plug>(dial-increment-additional)', {
    noremap = false,
    silent = true
})

vim.api.nvim_set_keymap('n', '<A-->', '<Plug>(dial-decrement)', {
    noremap = false,
    silent = true
})

vim.api.nvim_set_keymap('v', '<A-->', '<Plug>(dial-decrement-additional)', {
    noremap = false,
    silent = true
})
