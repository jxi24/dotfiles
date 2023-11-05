require('neogen').setup({
    snippet_engine = "luasnip",
    languages = {
        cpp = {
            template = {
                annotation_convention = "doxygen",
            },
        },
        python = {
            template = {
                annotation_convention = "numpydoc",
            },
        },
    },
})

local wk = require('which-key')
wk.register({
    lD = { ":lua require('neogen').generate()<cr>", "Generate documentation" },
}, { prefix = "<leader>" })
