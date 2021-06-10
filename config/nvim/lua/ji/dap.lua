local dap = require('dap')

dap.adapters.cpp = {
    type = 'executable',
    command = 'lldb',
    env = {
        LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"
    },
    name = "lldb"
}

dap.configurations.cpp = {
    {
        name = "Launch",
        type = "cpp",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/')
        end,
        cwd = '${workspaceFolder}',
        env = function()
            local variables = {}
            for k, v in pairs(vim.fn.environ()) do
                table.insert(variables, string.format("%s=%s", k ,v))
            end
            return variables
        end,
        stopOnEntry = false,
        args = {}
    },
}

dap.adapters.c = dap.adapters.cpp
dap.configurations.c = dap.configurations.cpp

require('dap-python').setup('~/anaconda3/bin/python')

local wk = require('which-key')
wk.register({
    d = {
        name = '+debug',
        c = { "<cmd>lua require'dap'.continue()<CR>", "Continue" },
        b = { "<cmd>lua require'dap'.toggle_breakpoint()<CR>", "Toggle Break" },
        s = { "<cmd>lua require'dap'.step_over()<CR>", "Step" },
        r = { "<cmd>lua require'dap'.repl.open()<CR>", "Open REPL" },
    },
}, { prefix = "<leader>" })
