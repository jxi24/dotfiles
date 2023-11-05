local mark = require'harpoon.mark'
local ui = require'harpoon.ui'

local wk = require('which-key')
wk.register({
    h = {
        name = "+Harpoon",
        a = { mark.add_file, "Add File" },
        m = { ui.toggle_quick_menu, "Toggle Quick Menu" },
        h = { function() ui.nave_file(1) end, "File 1" },
        j = { function() ui.nave_file(2) end, "File 2" },
        k = { function() ui.nave_file(3) end, "File 3" },
        l = { function() ui.nave_file(4) end, "File 4" },
    },
}, { prefix = "<leader>" })

