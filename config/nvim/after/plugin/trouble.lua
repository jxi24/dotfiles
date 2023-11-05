local trouble = require("trouble")
trouble.setup()

local wk = require('which-key')
wk.register({
    x = {
        name = "+Trouble",
        x = { "<cmd>TroubleToggle<cr>", "Toggle Trouble", silent = true, noremap = true },
        q = { "<cmd>TroubleToggle quickfix<cr>", "Toggle Trouble", silent = true, noremap = true },
        n = { trouble.next({skip_groups = true, jump = true}), "Next",
              silent = true, noremap = true },
        p = { trouble.previous({skip_groups = true, jump = true}), "Previous",
              silent = true, noremap = true },
    },
}, { prefix = "<leader>" })

