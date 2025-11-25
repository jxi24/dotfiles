return {
    {
        "nvim-telescope/telescope.nvim",
        event = 'VimEnter',
        version = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
            { "nvim-telescope/telescope-ui-select.nvim" },
            { 'echasnovski/mini.icons' },
            { "nvim-telescope/telescope-github.nvim" },
        },
        config = function()
            require('telescope').setup({
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown(),
                    },
                },
            })
            -- Enable extensions if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')
            pcall(require('telescope').load_extension, 'gh')

            local builtin = require('telescope.builtin')
            local extensions = require('telescope').extensions
            -- Search
            vim.keymap.set('n', '<leader>f', "", { desc = "Find" })
            vim.keymap.set('n', '<leader>s', "", { desc = "Search" })
            vim.keymap.set('n', '<leader>fb', function()
                builtin.buffers { sort_mru = true, sort_lastused = true, }
            end, { desc = "Switch buffers", })
            vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = "Search Help" })
            vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = "Search Keymaps" })
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find Files" })
            vim.keymap.set('n', '<leader>ft', builtin.git_files, { desc = "Find git files" })
            vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = "Search Telescope" })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Find word" })
            vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = "Find current word" })
            vim.keymap.set('n', '<leader>fG', function()
                builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files', }
            end, { desc = 'Find word in open files' })

            -- Git
            vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = "Git commits" })
            vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = "Git status" })
            vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = "Git branches" })
            vim.keymap.set('n', '<leader>gS', builtin.git_stash, { desc = "Git stashes" })
            vim.keymap.set('n', '<leader>ghi', extensions.gh.issues, { desc = "Github issues" })
            vim.keymap.set('n', '<leader>ghp', extensions.gh.pull_request, { desc = "Github pull requests" })
            vim.keymap.set('n', '<leader>ghw', extensions.gh.run, { desc = "Github workflows" })

            -- Telescope
            vim.keymap.set('n', '<leader>la', builtin.diagnostics, { desc = "Diagnostics" })
        end,
    }
}
