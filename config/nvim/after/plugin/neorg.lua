require('neorg').setup {
    load = {
        ["core.defaults"] = {},
        ["core.dirman"] = {
            config = {
                workspaces = {
                    work = "~/Documents/Notes/Neorg",
                }
            }
        },
        ["core.concealer"] = {},
        ["core.integrations.telescope"] = {},
    }
}

-- local neorg_callbacks = require("neorg.callbacks")

-- neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
--     keybinds.map_event_to_mode("norg", {
--         n = {
--             { "<leader>fl", "core.integrations.telescope.find_linkable" },
--         },
-- 
--         i = {
--             { "<C-l>", "core.integrations.telescope.insert_link" },
--         },
--     }, {
--         silent = true,
--         noremap = true,
--     })
-- end)

local wk = require('which-key')
wk.register({
    n = {
        name = "+Neorg",
        w = { "<cmd>Neorg workspace work<cr>", "Work Notes" },
        i = { "<cmd>Neorg inject-metadata<cr>", "Inject metadata" },
        u = { "<cmd>Neorg update-metadata<cr>", "Update metadata" },
    },
}, { prefix = "<leader>" })
