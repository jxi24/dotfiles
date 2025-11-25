return {
    {
        "jghauser/papis.nvim",
        dependencies = {
            "kkharji/sqlite.lua",
            "MunifTanjim/nui.nvim",
            -- If not already installed, you may also want one of:
            -- "hrsh7th/nvim-cmp",
            -- "saghen/blink.cmp",

            -- Choose one of the following two if not already installed:
            -- "nvim-telescope/telescope.nvim",
            -- "folke/snacks.nvim",

        },
        config = function()
            require("papis").setup({
                init_filetypes = { "markdown", "norg", "yaml", "typst", "tex", "latex", "pandoc" },
                ["search"] = {
                    enable = true,
                    provider = "snacks",
                },
                ["debug"] = {
                    enable = true,
                },
            })
        end,
    }
}
