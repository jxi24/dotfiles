return {
    {
        "jghauser/papis.nvim",
        -- Only where papis itself is installed (not on the ICER cluster). Its
        -- luarocks build fails without it and stalls the rest of the startup.
        enabled = vim.fn.executable("papis") == 1,
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
