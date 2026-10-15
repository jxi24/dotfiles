return {
    {
        -- Points basedpyright/ruff, the debugger and :terminal ($VIRTUAL_ENV) at a venv,
        -- remembered per project. Finds uv/.venv, conda, pixi, pyenv, ... environments.
        "linux-cultist/venv-selector.nvim",
        ft = "python",
        cmd = "VenvSelect",
        opts = {},
        keys = {
            { "<leader>p", "", desc = "Python" },
            { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "Select venv" },
        },
    },
}
