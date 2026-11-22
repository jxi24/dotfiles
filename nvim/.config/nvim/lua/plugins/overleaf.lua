-- Edit Overleaf projects live from Neovim (unofficial; uses Overleaf's
-- real-time protocol). On trial: `:Overleaf` to log in and pick a project.
--
-- From jxi24's fork, branch personal: upstream plus two fixes not merged yet,
--   fix/keys-option      keys = false works (#20); upstream always sets its
--                        <leader>o keys, over obsidian.nvim's
--   fix/download-safety  the cookie isn't sent on redirects or URLs outside
--                        Overleaf, and download names can't leave pdf_dir
--   feat/connected-event a User OverleafConnected event, which paper_notes.lua
--                        uses to offer a vault paper note for the project
--
-- Login: the overleaf_session2 cookie from the browser (Zen: devtools,
-- Storage, Cookies, www.overleaf.com), in ~/.config/overleaf/env as
--   OVERLEAF_COOKIE=s%3A...
-- That file is outside the dotfiles and readable only by you; the cookie is
-- full access to the Overleaf account and lasts a few days.
return {
    {
        "jxi24/overleaf.nvim",
        branch = "personal",
        cmd = "Overleaf",
        -- The bridge is a Node.js program; skip it where there's no Node (the cluster).
        -- It needs Overleaf's socket.io fork from GitHub, and npm 12 refuses git
        -- packages unless allowed; root allows only the ones package.json names.
        build = function(plugin)
            if vim.fn.executable("npm") == 0 then
                return
            end
            local res = vim.system({ "npm", "install", "--silent", "--allow-git=root" },
                { cwd = plugin.dir .. "/node", text = true }):wait()
            if res.code ~= 0 then
                error("npm install failed: " .. (res.stderr or ""))
            end
        end,
        opts = {
            keys = false,
            env_file = vim.fn.expand("~/.config/overleaf/env"),
            -- Compiled PDFs and previewed files: a private folder rather than
            -- fixed names in the shared /tmp.
            pdf_dir = vim.fn.expand("~/.cache/overleaf"),
            -- sync_dir stays unset: it mirrors every document to disk.
        },
        config = function(_, opts)
            require("overleaf").setup(opts)
            require("paper_notes").setup()
        end,
        init = function()
            vim.fn.mkdir(vim.fn.expand("~/.cache/overleaf"), "p", tonumber("700", 8))
        end,
        keys = {
            { "<leader>L", "", desc = "Overleaf" },
            { "<leader>Lc", function() require("overleaf").connect() end, desc = "Connect" },
            { "<leader>Ld", function() require("overleaf").disconnect() end, desc = "Disconnect" },
            { "<leader>Lb", function() require("overleaf").compile() end, desc = "Build (compile on Overleaf)" },
            { "<leader>Lt", function() require("overleaf").toggle_tree() end, desc = "File tree" },
            { "<leader>Lo", function() require("overleaf").select_document() end, desc = "Open document" },
            { "<leader>Lp", function() require("overleaf").preview_file() end, desc = "Preview file" },
            { "<leader>Lr", function() require("overleaf").show_comment() end, desc = "Read comment" },
            { "<leader>LR", function() require("overleaf").reply_comment() end, desc = "Reply to comment" },
            { "<leader>Lx", function() require("overleaf").resolve_comment() end, desc = "Resolve/reopen comment" },
            { "<leader>Lf", function() require("overleaf").search() end, desc = "Find in project" },
            { "<leader>Lh", "<cmd>Overleaf history<cr>", desc = "History" },
            { "<leader>Ls", "<cmd>Overleaf status<cr>", desc = "Status" },
            { "<leader>Ln", function() require("paper_notes").open() end, desc = "Paper/grant note (vault)" },
        },
    },
}
