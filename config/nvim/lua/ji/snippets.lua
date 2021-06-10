require('plenary.reload').reload_module("nlua")
require('plenary.reload').reload_module("snippets")

-- TODO: We should check out the UX stuff here. Norcalli made something sweet.
-- require'snippets'.set_ux(require'snippets.inserters.vim_input')

local snip_plug = require('snippets')
local indent = require('snippets.utils').match_indentation

local snips = {}

snips._global = {
  ["todo"] = "TODO: ",
  ["date"] = [[${=os.date("%Y-%m-%d")}]],
  ["rs"] = [[${=RandomString(25)}]],
}

snips.cpp = {}
snips.cpp.main = [[int main() {
    $0
    return 0;
}]];

snips.cpp.once = [[
#ifndef ${1:header name|S.v:upper():gsub("%s+", "_")}_HH
#define $1_HH

#endif // ${|S[1]:gsub("%s+", "_")}_HH
]];

snips.cuda = {}
snips.cuda.hostdevice = [[
__host__ __device__
]];

snip_plug.snippets = snips
snip_plug.use_suggested_mappings()

-- TODO: Investigate this again.
require'snippets'.set_ux(require'snippets.inserters.floaty')

-- Shortcuts for me to edit the snippet files
--  Could possibly use fzf or something for this, but this seemds good for now.
vim.cmd [[nnoremap ,se :e ~/.config/nvim/lua/ji/snippets.lua<CR>]]
