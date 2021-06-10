-- Load lsp config
local ok, msg = pcall(function() require('ji.lsp_config') end)
if not ok then
    print(msg)
end

RELOAD = require('plenary.reload').reload_module

R = function(name)
    RELOAD(name)
    return require(name)
end

P = function(v)
    print(vim.inspect(v))
    return v
end

require('ji.completion')
require('ji.treesitter')
require('ji.statusline')
require('ji.snippets')
require('ji.telescope')
require('ji.telescope.mappings')

require('terminal').setup()

for _, mod in ipairs(vim.api.nvim_get_runtime_file('lua/auto/**/*.lua', true)) do
    ok, msg = pcall(loadfile(mod))

    if not ok then
        print("Failed to load: ", mod)
        print("\t", msg)
    end
end
