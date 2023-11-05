require("sidebar-nvim").setup({
    sections = { "datetime", "files", "git", "diagnostics" },
    files = {
        icon = "",
        show_hidden = false,
        ignored_paths = {"%.git$"}
    }
})

local wk = require("which-key")
wk.register({
    s = { "<cmd>SidebarNvimToggle<cr>", "Toggle sidebar" }
}, { prefix = "<leader>" })
