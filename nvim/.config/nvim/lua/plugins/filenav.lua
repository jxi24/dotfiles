return {
    {
        'mikavilpas/yazi.nvim',
        event = 'VeryLazy',
        dependencies = { 'folke/snacks.nvim' },
        keys = {
            {
                "<leader>yf",
                mode = { "n", "v" },
                "<cmd>Yazi<cr>",
                desc = "Open yazi at the current file"
            },
            {
                "<leader>yd",
                mode = { "n", "v" },
                "<cmd>Yazi cwd<cr>",
                desc = "Open yazi at the current working directory"
            },
            {
                "<leader>yr",
                mode = { "n", "v" },
                "<cmd>Yazi toggle<cr>",
                desc = "Resume the last yazi session"
            },
        },
        opts = {
            open_for_directories = false,
            keymaps = {
                show_help = "<f1>",
            },
        },
    },
    {
        'stevearc/oil.nvim',
        opts = {},
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
        lazy = false,
        init = function()
            require("oil").setup()
        end,
    }
}
