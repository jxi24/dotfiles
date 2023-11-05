require("mason").setup()
require("mason-nvim-dap").setup({
    ensure_installed = { "python", "codelldb" },
    automatic_setup = true,
})
require("mason-nvim-dap").setup()

local dap = require('dap')
local ui = require('dapui')
ui.setup()

local wk = require('which-key')
wk.register({
    d = {
        name = "+Debug",
        o = { function() ui.open() end, "Open UI" },
        x = { function() ui.close() end, "Close UI" },
        t = { function() ui.toggle() end, "Toggle UI" },
        b = { function() dap.toggle_breakpoint() end, "Toggle breakpoint" },
        c = { function() dap.continue() end, "Continue" },
        s = { function() dap.step_over() end, "Step over" },
        i = { function() dap.step_into() end, "Step into" },
        r = { function() dap.repl.open() end, "Repl" },
    },
}, { prefix = "<leader>" })

