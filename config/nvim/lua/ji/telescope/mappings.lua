local wk = require("which-key")

wk.register({
    e = {
        name = "+edit",
        n = { "<cmd> lua R('ji.telescope')['edit_neovim']()<CR>", "Edit Neovim Files" },
    },
    f = {
        name = "+telescope",
        t = { "<cmd> lua R('ji.telescope')['git_files']()<CR>", "Git Files" },
        g = { "<cmd> lua R('ji.telescope')['live_grep']()<CR>", "Live Grep" },
        o = { "<cmd> lua R('ji.telescope')['oldfiles']()<CR>", "Old Files" },
        d = { "<cmd> lua R('ji.telescope')['fd']()<CR>", "Find Files" },
        p = { "<cmd> lua R('ji.telescope')['project_search']()<CR>", "Project Search" },
        b = { "<cmd> lua R('ji.telescope')['buffers']()<CR>", "Buffers" },
        a = { "<cmd> lua R('ji.telescope')['installed_plugsin']()<CR>", "Installed plugins" },
        c = { "<cmd> lua R('ji.telescope')['curbuf']()<CR>", "Current Buffer Search" },
        h = { "<cmd> lua R('ji.telescope')['help_tags']()<CR>", "Help Tags" },
        T = { "<cmd> lua R('ji.telescope')['builtin']()<CR>", "Meta Telescope" },
        p = { "<cmd> lua R('ji.telescope')['grep_prompt']()<CR>", "Grep prompt" },
        v = { "<cmd> lua R('ji.telescope')['vim_options']()<CR>", "Vim options" },
    },
}, { prefix = "<leader>" })

-- local map = function(key, f, options, buffer)
--     local mode = "n"
--     local rhs = string.format(
--         "<cmd>lua R('ji.telescope')['%s'](%s)<CR>",
--         f,
--         options and vim.inspect(options, { newline = '' }) or ''
--     )
--     local options = {
--         noremap = true,
--         silent = true,
--     }
-- 
--     if not buffer then
--         vim.api.nvim_set_keymap(mode, key, rhs, options)
--     else
--         vim.api.nvim_buf_set_keymap(0, mode, key, rhs, options)
--     end
-- end

vim.api.nvim_set_keymap('c', '<c-r><c-r>', '<Plug>(TelescopeFuzzyCommandSearch)', { noremap = false, nowait = true })

-- Dotfiles
-- map('<leader>en', 'edit_neovim')

-- Files
-- map('<leader>ft', 'git_files')
-- map('<leader>fg', 'live_grep')
-- map('<leader>fo', 'oldfiles')
-- map('<leader>fd', 'fd')
-- map('<leader>fp', 'project_search')

-- Nvim
-- map('<leader>fb', 'buffers')
-- map('<leader>fa', 'installed_plugins')
-- map('<leader>fc', 'curbuf')
-- map('<leader>fh', 'help_tags')
-- map('<leader>so', 'vim_options')
-- map('<leader>gp', 'grep_prompt')

-- Telescope Meta
-- map('<leader>fT', 'builtin')

return map
