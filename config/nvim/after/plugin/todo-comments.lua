require("todo-comments").setup {}

local wk = require('which-key')
wk.register({
    f = {
        name = "+Telescope",
        c = { "<cmd>TodoTelescope<cr>", "Todo Comments" },
    },
}, { prefix = "<leader>" })
wk.register({
    x = {
        name = "+Trouble",
        t = { "<cmd>TodoTrouble<cr>", "Todo Comments" },
    },
}, { prefix = "<leader>" })
