local wezterm = require 'wezterm'
local act = wezterm.action

-- Plugins
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
-- WezTerm half of smart-splits.nvim v3 (the nvim half is smart-splits-nvim/backend-wezterm)
local smart_splits = wezterm.plugin.require("https://github.com/smart-splits-nvim/backend-wezterm")

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local config = wezterm.config_builder()

config.enable_wayland = true
config.enable_kitty_graphics = true
config.default_prog = { "/bin/bash" }

config.color_scheme = 'Catppuccin Frappe'
config.audible_bell = 'Disabled'
config.font_size = 10
config.font = wezterm.font 'Hack Nerd Font Mono'

config.colors = {
    compose_cursor = 'orange',
}

local colors = wezterm.color.get_builtin_schemes()["Catppuccin Frappe"]

config.window_decorations = "NONE" --"INTEGRATED_BUTTONS|RESIZE"
config.scrollback_lines = 5000

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
    {
        key = 'W',
        mods = 'LEADER',
        action = wezterm.action_callback(function(win, pane)
            resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
          end),
    },
    {
        key = 'w',
        mods = 'LEADER',
        action = resurrect.window_state.save_window_action(),
    },
    {
        key = 'R',
        mods = 'LEADER',
        action = wezterm.action_callback(function(win, pane)
            resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
                local type = string.match(id, "^([^/]+)")
                id = string.match(id, "([^/]+)$")
                id = string.match(id, "(.+)%..+$")
                -- From https://github.com/MLFlexer/resurrect.wezterm/issues/70#issuecomment-2618667719
                local opts = {
                    close_open_tabs = true,
                    window = pane:window(),
                    relative = true,
                    restore_text = true,
                    on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                }
                if type == "workspace" then
                    local state = resurrect.state_manager.load_state(id, "workspace")
                    -- create new workspace with previous name
                    -- Source: https://github.com/MLFlexer/resurrect.wezterm/issues/73#issuecomment-2572924018
                    win:perform_action(
                        wezterm.action.SwitchToWorkspace({
                            name = state.workspace,
                        }),
                        pane
                    )
                    resurrect.workspace_state.restore_workspace(state, opts)
                elseif type == "window" then
                    local state = resurrect.state_manager.load_state(id, "window")
                    resurrect.window_state.restore_window(pane:window(), state, opts)
                elseif type == "tab" then
                    local state = resurrect.state_manager.load_state(id, "tab")
                    resurrect.tab_state.restore_tab(pane:tab(), state, opts)
                end
            end)
        end),
    },
    { key = 'v', mods = 'LEADER', action = act.ActivateCopyMode },
    { key = 'l', mods = 'CTRL|ALT', action = act.ShowLauncher },
    { key = 'F9', mods = 'CTRL', action = act.ShowTabNavigator },
    { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
    { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'h', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
    { key = 'l', mods = 'LEADER', action = act.ActivateTabRelative(1) },
    -- { key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection 'Left' },
    -- { key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection 'Up' },
    -- { key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection 'Down' },
    -- { key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },
    {
        key = 'j', mods = 'LEADER', action = act.SpawnCommandInNewTab {
            args = { 'nvim', '+', 'journal.md' },
            cwd = '/home/isaacson/Documents/Notes/Personal',
        }
    },
    { key = ',', mods = 'LEADER', action = act.PromptInputLine {
        description = 'Enter new name for tab',
        action = wezterm.action_callback(function(window, pane, line)
            if line then
                window:active_tab():set_title(line)
            end
        end),
    }},
    { key = 'e', mods = 'LEADER', action = act.PromptInputLine {
        description = wezterm.format {
            { Attribute = { Intensity = 'Bold' } },
            { Foreground = { AnsiColor = 'Fuchsia' } },
            { Text = 'Enter name for new workspace' },
        },
        action = wezterm.action_callback(function(window, pane, line)
            if line then
                window:perform_action(
                    act.SwitchToWorkspace {
                        name = line,
                    },
                    pane
                    )
                end
            end),
        }
    },
    { key = 'E', mods = 'LEADER', action = act.PromptInputLine {
        description = wezterm.format {
            { Attribute = { Intensity = 'Bold' } },
            { Foreground = { AnsiColor = 'Fuchsia' } },
            { Text = 'Enter new name for current workspace' },
        },
        action = wezterm.action_callback(function(window, pane, line)
            if line then
                wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
            end
        end),}
    },
    -- Switch to a monitoring workspace, which will have `top` launched into it
    { key = 'm', mods = 'CTRL|SHIFT',
        action = act.SwitchToWorkspace {
            name = 'Monitoring',
            spawn = {
                args = { 'htop' },
            },
        },
    },
    -- Show the launcher in fuzzy selection mode and have it list all workspaces
    -- and allow activating one.
    {
        key = "s",
        mods = "LEADER",
        action = workspace_switcher.switch_workspace(),
    },
    {
        key = "S",
        mods = "LEADER",
        action = workspace_switcher.switch_to_prev_workspace(),
    },

    {
        key = 'x',
        mods = 'LEADER',
        action = wezterm.action.CloseCurrentTab { confirm = true },
    },

    { key = 'a', mods = 'LEADER', action = act.SendKey { key = 'a', mods = 'CTRL' }},
}

-- Switch between tabs using numbers
for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'LEADER',
        action = act.ActivateTab(i - 1),
    })
end

-- CTRL+hjkl move / META+hjkl resize between panes, forwarded into nvim when it sets IS_NVIM.
-- Appends to config.keys, so it must come after config.keys is assigned.
smart_splits.apply_to_config(config)

-- Resurrect
resurrect.state_manager.periodic_save({
	interval_seconds = 15 * 60,
	save_workspaces = true,
	save_windows = true,
	save_tabs = true,
})
wezterm.on("resurrect.error", function(err)
	wezterm.log_error("ERROR!")
	wezterm.gui.gui_windows()[1]:toast_notification("resurrect", err, nil, 3000)
end)


-- Tabline
tabline.setup({
    options = {
        component_separators = {
            left = "",
            right = "",
        },
        section_separators = {
            left = "",
            right = "",
        },
        tab_separators = {
            left = wezterm.nerdfonts.ple_right_half_circle_thick,
            right = wezterm.nerdfonts.ple_left_half_circle_thick,
        },
    },
    sections = {
        tab_inactive = { 'index', { 'tab', padding = { left = 0, right = 1 } } },
    },
    extensions = {
        "resurrect",
    },
})
tabline.apply_to_config(config)
config.window_decorations="NONE"
config.window_padding = {
    top = 4,
    bottom = 0,
    left = 0,
    right = 0,
}

-- Workspace switcher
workspace_switcher.apply_to_config({})

workspace_switcher.workspace_formatter = function(label)
	return wezterm.format({
		{ Attribute = { Italic = true } },
		{ Foreground = { Color = colors.ansi[3] } },
		{ Background = { Color = colors.background } },
		{ Text = "󱂬 : " .. label },
	})
end

wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
	window:gui_window():set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { Color = colors.ansi[5] } },
		{ Text = basename(path) .. "  " },
	}))
	local workspace_state = resurrect.workspace_state

	-- Only restore if a saved state exists; a missing state file must not break switching.
	local ok, err = pcall(function()
		local state = resurrect.state_manager.load_state(label, "workspace")
		if state and state.window_states then
			workspace_state.restore_workspace(state, {
				window = window,
				relative = true,
				restore_text = true,

				resize_window = false,
				on_pane_restore = resurrect.tab_state.default_on_pane_restore,
			})
		end
	end)
	if not ok then
		wezterm.log_warn("resurrect restore skipped for " .. label .. ": " .. tostring(err))
	end
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(window, path, label)
	wezterm.log_info(window)
	window:gui_window():set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		-- { Foreground = { Color = colors.colors.ansi[5] } },
		{ Text = basename(path) .. "  " },
	}))
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
	wezterm.log_info(window)
	-- Saving can fail on some pane layouts (resurrect pane_tree bug); never let that
	-- abort the switch, since this handler runs before the switch happens.
	local ok, err = pcall(function()
		local workspace_state = resurrect.workspace_state
		resurrect.state_manager.save_state(workspace_state.get_workspace_state())
		resurrect.state_manager.write_current_state(label, "workspace")
	end)
	if not ok then
		wezterm.log_warn("resurrect save failed before workspace switch: " .. tostring(err))
	end
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.start", function(window, _)
	wezterm.log_info(window)
end)
wezterm.on("smart_workspace_switcher.workspace_switcher.canceled", function(window, _)
	wezterm.log_info(window)
end)

wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

return config
