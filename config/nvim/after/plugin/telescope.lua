local builtin = require('telescope.builtin')

pcall(require('telescope').load_extension, 'fzf')

local wk = require('which-key')
wk.register({
    f = {
        name = "+Telescope",
        f = { builtin.find_files, "Find Files" },
        t = { builtin.git_files, "Git Files" },
        g = { builtin.live_grep, "Live Grep" },
        b = { builtin.buffers, "Buffers" },
        h = { builtin.help_tags, "Help tags" },
        s = { function()
            builtin.grep_string({ search = vim.fn.input('Grep > ') });
        end, "Grep" },
    },
}, { prefix = "<leader>" })

