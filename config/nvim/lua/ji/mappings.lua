local mappings = {}

local n, i, v, esc = "n", "i", "v", "<esc>"
local silent = { silent = true }

local maps = {
    -- remap esc
    {i, "jk", esc},
    {i, "JK", esc},
    {i, "Jk", esc},
    {i, "jK", esc},

    -- clear highlighted search
    {n, " ", ":set hlsearch! hlsearch?<CR>"},

    -- activate spell-checking alternatives
    {n, ";s", ":set invspell spelling=en_us<CR>"},

    -- autocomplete movement
    {i, "<Tab>", "pumvisible() ? '<C-n>' : '<Tab>'", { expr = true }},
    {i, "<S-Tab>", "pumvisible() ? '<C-p>' : '<S-Tab>'", { expr = true }},

    -- keep visual selection when indenting / outdenting
    {v, "<", "<gv"},
    {v, ">", ">gv"},

    -- enable . command in visual mode
    {v, ".", ":normal .<CR>"},

    -- moving up and down work as you would expect
    {n, "j", "gj", silent},
    {n, "k", "gk", silent},
    {n, "^", "g^", silent},
    {n, "$", "g$", silent},
    {v, "j", "gj", silent},
    {v, "k", "gk", silent},
    {v, "^", "g^", silent},
    {v, "$", "g$", silent},

    -- remove whitespace
    {n, "<leader><space>", ":%s/\\s\\+$<CR>"},

    -- helpful mappings
    {n, "<leader>.", "<C-^>"},
    {n, "<leader>,", ":w<CR>"},
    {n, "<leader>\\", ":vsplit<CR>"},
    {n, "<leader>-", ":split<CR>"},
    {n, "<leader>q", ":q<CR>"},
}

-- Mappings
mappings.setup = function()
    -- Apply the keymaps
    require"ji.utils".keymaps(maps)
end

return mappings
