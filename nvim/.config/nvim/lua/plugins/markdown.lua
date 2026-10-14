return {
    {
        "OXY2DEV/markview.nvim",
        lazy = false,
        dependencies = {
            'nvim-mini/mini.icons',
            'saghen/blink.cmp',
        },
        priority = 49,
        opts = {
            preview = {
                modes = { "n", "i", "c" },
                hybrid_modes = { "i" },
                enable = true,
                icon_provider = 'mini',
            }
        },
    }
}
