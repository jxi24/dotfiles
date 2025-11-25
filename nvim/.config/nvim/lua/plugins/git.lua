---@param config {args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.input("Diffview with args: ", table.concat(args, " ")) --[[@as string]]
    return vim.split(vim.fn.expand(new_args) --[[@as string]], " ")
  end
  return config
end

return {
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = true,
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
        lazy = false,
        opts = function()
            local actions = require("diffview.actions")

            local opts = {
                merge_tool = {
                    layout = "diff3_mixed",
                    disable_diagnostics = true,
                    windbar_info = true,
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
        opts = function()
            local gitportal = require("gitportal")

            vim.keymap.set("n", "<leader>gp", gitportal.open_file_in_browser)
            vim.keymap.set("v", "<leader>gp", gitportal.open_file_in_browser)
            vim.keymap.set("n", "<leader>gP", gitportal.copy_link_to_clipboard)
            vim.keymap.set("v", "<leader>gP", gitportal.copy_link_to_clipboard)
        end,
    }
}
