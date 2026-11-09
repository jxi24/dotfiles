return {
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "folke/snacks.nvim",
        },
        opts = {
            integrations = { snacks = true, diffview = true },
        },
        keys = {
            { "<leader>g", "", desc = "Git" },
            { "<leader>gn", "<cmd> Neogit<CR>", desc = "Open Neogit" },
        },
    },
    {
        "lewis6991/gitsigns.nvim",
        lazy = false,
        opts = {
            current_line_blame = true,
        },
    },
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        opts = function()
            local actions = require("diffview.actions")

            local opts = {
                merge_tool = {
                    layout = "diff3_mixed",
                    disable_diagnostics = true,
                    winbar_info = true,
                },
                keymaps = {
                    view = {
                        { "n", "[c", actions.prev_conflict, { desc = "Prev conflict" } },
                        { "n", "]c", actions.next_conflict, { desc = "Next conflict" } },
                        { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose the OURS version" } },
                        { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose the THEIRS version" } },
                        { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose the BASE version" } },
                        { "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "Choose the OURS version for a file" } },
                        { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version for a file" } },
                        { "n", "<leader>cB", actions.conflict_choose_all("base"), { desc = "Choose the BASE version for a file" } },
                    },
                },
            }
            return opts
        end,
        keys = {
            { "<leader>gd", "", desc = "Diff" },
            { "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", desc = "History" },
            { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
            { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
        },
    },
    {
        'trevorhauter/gitportal.nvim',
        opts = {},
        keys = {
            { "<leader>gp", function() require("gitportal").open_file_in_browser() end, mode = { "n", "v" }, desc = "Open in Browser" },
            { "<leader>gP", function() require("gitportal").copy_link_to_clipboard() end, mode = { "n", "v" }, desc = "Copy Link" },
        },
    }
}
