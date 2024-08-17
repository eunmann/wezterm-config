local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.color_schema = "Tokyo Night"
config.font = wezterm.font_with_fallback({ "SauceCodePro Nerd Font", "Fira Code" })

config.keys = {
	{ key = "{", models = "ALT", action = act.ActivateTabRelative(-1) },
	{ key = "}", models = "ALT", action = act.ActivateTabRelative(1) },
}

return config
