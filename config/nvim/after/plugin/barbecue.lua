require("barbecue").setup({
    attach_navic = false,
})

local wk = require('which-key')
wk.register({
    b = { ":Barbecue toggle<cr>", "Toggle winbar" },
}, { prefix = "<leader>" })
