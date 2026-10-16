return {
    "lervag/vimtex",
    lazy = false,
    init = function()
        vim.g.vimtex_compiler_method = "latexmk"
        vim.g.vimtex_compiler_latexmk_engines = {
            _ = "-lualatex"
        }
        -- "zathura" relies on xdotool to find the window, which fails on Wayland
        vim.g.vimtex_view_method = "zathura_simple"
    end,
}
