require('refactoring').setup()

local wk = require('which-key')
wk.register({
    r = {
        name = "Refactor",
        -- Remaps for the refactoring operations currently offered by the plugin
        e = { "[[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]]",
              "Extract Function", mode = "v", expr = false },
        f = { "[[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]]",
              "Extract Function to File", mode = "v", expr = false },
        v = { "[[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]]",
              "Extract Variable", mode = "v", expr = false },
        i = { "[[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]]",
              "Inline Variable", mode = "v", expr = false },

        -- Extract block doesn't need visual mode
        b = { "[[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]]",
              "Extract Block" },
        f = { "[[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]]", "Extract Block to file" },

        -- Inline variable can also pick up the identifier currently under the cursor without visual mode
        i = { "[[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]]", "Inline Variable" },
    },
}, { prefix = "<leader>" })
