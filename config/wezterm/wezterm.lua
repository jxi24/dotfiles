local wezterm = require 'wezterm'
local act = wezterm.action

local function is_vim(pane)
    return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  Left = 'h',
  Down = 'j',
  Up = 'k',
  Right = 'l',
  -- reverse lookup
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}


local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

local config = wezterm.config_builder()

config.default_prog = { "/bin/bash" }

config.color_scheme = 'OneDark (base16)'
config.audible_bell = 'Disabled'
config.font_size = 10
config.font = wezterm.font 'Hack Nerd Font Mono'
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

require('utils.right-status').setup()

config.colors = {
    compose_cursor = 'orange',
    tab_bar = {
        background = '#282c34',
        active_tab = {
            bg_color = '#393e48',
            fg_color = '#979eab',
            intensity = 'Bold',
            italic = true,
        },
        inactive_tab = {
            bg_color = '#282c34',
            fg_color = '#979eab',
            intensity = 'Half',
            italic = false,
        },
        inactive_tab_hover = {
            bg_color = '#282c34',
            fg_color = '#979eab',
            intensity = 'Normal',
            italic = false,
        },
        new_tab = {
            bg_color = '#282c34',
            fg_color = '#979eab',
            intensity = 'Half',
            italic = false,
        },
        new_tab_hover = {
            bg_color = '#282c34',
            fg_color = '#979eab',
            intensity = 'Normal',
            italic = false,
        },
    }
}

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.scrollback_lines = 5000
config.launch_menu = {
    {
        label = "Wilson Cluster", args = {"ssh", "wc.fnal.gov"}, domain = {DomainName="local"},
    }
}

config.leader = { key = 'a', mods = 'CTRL' }
config.keys = {
    { key = 'v', mods = 'LEADER', action = act.ActivateCopyMode },
    { key = 'l', mods = 'CTRL|ALT', action = act.ShowLauncher },
    { key = 'F9', mods = 'CTRL', action = act.ShowTabNavigator },
    { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
    { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'h', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
    { key = 'l', mods = 'LEADER', action = act.ActivateTabRelative(1) },
    { key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection 'Left' },
    { key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection 'Up' },
    { key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection 'Down' },
    { key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },
    {
        key = 's', mods = 'LEADER', action = act.SpawnCommandInNewTab {
            args = { 'ssh', 'wc.fnal.gov' }
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
    { key = 'w', mods = 'LEADER', action = act.PromptInputLine {
        description = wezterm.format {
            { Attribute = { Intensity = 'Bold' } },
            { Foreground = { AnsiColor = 'Fuchsia' } },
            { Text = 'Enter name for workspace' },
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
    { key = 'e', mods = 'LEADER', action = act.PromptInputLine {
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
    { key = 'F5', mods = 'LEADER',
        action = act.ShowLauncherArgs {
            flags = 'FUZZY|WORKSPACES',
        },
    },

    split_nav('move', 'h'),
    split_nav('move', 'j'),
    split_nav('move', 'k'),
    split_nav('move', 'l'),
    split_nav('resize', 'h'),
    split_nav('resize', 'j'),
    split_nav('resize', 'k'),
    split_nav('resize', 'l'),
}

-- Switch between tabs using numbers
for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'LEADER',
        action = act.ActivateTab(i - 1),
    })
end

return config
