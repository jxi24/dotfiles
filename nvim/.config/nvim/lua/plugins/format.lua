return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = "ConformInfo",
        opts = {
            formatters_by_ft = {
                c = { "clang_format" },
                cpp = { "clang_format" },
                cmake = { "cmake_format" },
                python = { "ruff_format" },
            },
            formatters = {
                -- Only format C/C++ in projects that define a style; LLVM's default
                -- would reformat whole files elsewhere.
                clang_format = {
                    require_cwd = true,
                    cwd = function(...) return require("conform.util").root_file({ ".clang-format", "_clang-format" })(...) end,
                },
                -- Same for Python: only where ruff is configured (ruff.toml or [tool.ruff])
                ruff_format = {
                    require_cwd = true,
                    cwd = function(_, ctx)
                        for dir in vim.fs.parents(ctx.filename) do
                            if vim.uv.fs_stat(dir .. "/ruff.toml") or vim.uv.fs_stat(dir .. "/.ruff.toml") then
                                return dir
                            end
                            local pyproject = dir .. "/pyproject.toml"
                            if vim.uv.fs_stat(pyproject) then
                                for line in io.lines(pyproject) do
                                    if line:match("^%[tool%.ruff") then
                                        return dir
                                    end
                                end
                            end
                        end
                    end,
                },
            },
            -- On save only the formatters above run; <leader>lf also falls back to the LSP.
            format_on_save = function(buf)
                if vim.g.autoformat == false or vim.b[buf].autoformat == false then
                    return
                end
                return { timeout_ms = 1000, lsp_format = "never" }
            end,
        },
        keys = {
            { "<leader>lf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
                mode = { "n", "v" }, desc = "Format" },
            {
                "<leader>uf",
                function()
                    vim.g.autoformat = vim.g.autoformat == false
                    vim.notify("Format on save: " .. (vim.g.autoformat and "on" or "off"))
                end,
                desc = "Toggle Format on Save",
            },
        },
    },
    {
        -- Pins the enclosing function/class/TEST_CASE to the top of the window
        "nvim-treesitter/nvim-treesitter-context",
        event = { "BufReadPost", "BufNewFile" },
        opts = { max_lines = 3, multiline_threshold = 1 },
        keys = {
            { "[x", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Go to Context" },
            { "<leader>ux", "<cmd>TSContext toggle<cr>", desc = "Toggle Treesitter Context" },
        },
    },
}
