local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Theme
config.color_scheme = "Tokyo Night"

-- Font (SauceCodePro Nerd Font installed by install script)
config.font = wezterm.font_with_fallback({
  "SauceCodePro Nerd Font",
  "Symbols Nerd Font Mono",
})
-- Proportional font rendering tweaks
config.freetype_load_target = "Normal"
config.freetype_render_target = "Normal"
config.adjust_window_size_when_changing_font_size = false

-- Tab bar configuration
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.status_update_interval = 1000 -- ms

-- Start zsh as a login shell
config.default_prog = { "/usr/bin/zsh", "-l" }

-- Keybindings
local act = wezterm.action
config.keys = {
  { key = "{", mods = "ALT", action = act.ActivateTabRelative(-1) },
  { key = "}", mods = "ALT", action = act.ActivateTabRelative(1) },
}

-- Display the user var sent by zsh: "repo (branch)" on the right
wezterm.on("user-var-changed", function(window, pane, name, value)
  if name ~= "git_status" then return end
  local text = value or ""
  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#8aadf4" } },
    { Text = (text ~= "" and (" " .. text .. " ") or "") },
  }))
end)

return config
