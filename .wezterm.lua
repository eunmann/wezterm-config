local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"

-- ─── Font ───────────────────────────────────────────────────────────────
config.font = wezterm.font_with_fallback({
  "SauceCodePro Nerd Font",
  "Symbols Nerd Font Mono",
  "Fira Code",
})
config.freetype_load_target = "Normal"
config.freetype_render_target = "Normal"
config.adjust_window_size_when_changing_font_size = false

-- ─── Window / UX ────────────────────────────────────────────────────────
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.window_close_confirmation = "NeverPrompt"
config.window_padding = { left = 8, right = 8, top = 4, bottom = 4 }

config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 100,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 250,
  target = "BackgroundColor",
}
config.colors = { visual_bell = "#3b3052" }

config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.75 }

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.status_update_interval = 1000 -- ms

-- ─── Launcher (platform-specific) ───────────────────────────────────────
-- On Windows, register a WSL domain so new tabs/panes inherit the real WSL
-- cwd (via OSC 7) instead of always starting at ~. On macOS/Linux, leave
-- default_domain unset and WezTerm uses the user's login shell.
if wezterm.target_triple:find("windows") then
  config.wsl_domains = {
    { name = "WSL:Ubuntu", distribution = "Ubuntu" },
  }
  config.default_domain = "WSL:Ubuntu"
end

-- ─── Hyperlink rules ────────────────────────────────────────────────────
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- owner/repo#1234 → GitHub issue/PR link
table.insert(config.hyperlink_rules, {
  regex = [[\b([\w.-]+)/([\w.-]+)#(\d+)\b]],
  format = "https://github.com/$1/$2/issues/$3",
})

-- CTRL+SPACE: clean against zsh, vim built-ins (<C-A> increment, <C-B>
-- page up), and nvim's Space leader.
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1500 }

-- ─── Keybindings ────────────────────────────────────────────────────────
-- Most things use wezterm's CTRL+SHIFT defaults (tabs, jump-to-tab, palette,
-- search, copy mode, quick select). Only additions live here.
config.keys = {
  -- Font size: bind both shifted (+, _) and unshifted (=, -) forms because
  -- wezterm's matching of the + glyph through SHIFT is unreliable.
  { key = "+", mods = "CTRL",       action = act.IncreaseFontSize },
  { key = "=", mods = "CTRL",       action = act.IncreaseFontSize },
  { key = "_", mods = "CTRL",       action = act.DecreaseFontSize },
  { key = "-", mods = "CTRL",       action = act.DecreaseFontSize },
  { key = "0", mods = "CTRL",       action = act.ResetFontSize },

  -- Pane operations (after CTRL+SPACE leader)
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-",  mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "h",  mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "l",  mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "k",  mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "j",  mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "z",  mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "x",  mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "r",  mods = "LEADER", action = act.ActivateKeyTable({
      name = "resize_pane", one_shot = false, timeout_milliseconds = 2000,
    }) },
}

-- LEADER+r enters this; bare h/j/k/l resize, Escape/Enter exit.
config.key_tables = {
  resize_pane = {
    { key = "h",      action = act.AdjustPaneSize({ "Left",  3 }) },
    { key = "l",      action = act.AdjustPaneSize({ "Right", 3 }) },
    { key = "k",      action = act.AdjustPaneSize({ "Up",    3 }) },
    { key = "j",      action = act.AdjustPaneSize({ "Down",  3 }) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  },
}

-- ─── Tab titles ─────────────────────────────────────────────────────────
local function basename(path)
  return (path or ""):match("([^/\\]+)/?$") or ""
end

wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
  local pane = tab.active_pane
  -- On WSL, pane.foreground_process_name reports the Windows helper
  -- (wslhost.exe), not what's running inside the shell. zsh sends the real
  -- name as a `prog` user-var; prefer that and fall back gracefully.
  local proc = pane.user_vars and pane.user_vars.prog or ""
  if proc == "" then
    proc = basename(pane.foreground_process_name)
    if proc:match("^wsl") then proc = "shell" end
  end
  local cwd = ""
  if pane.current_working_dir then
    cwd = basename(pane.current_working_dir.file_path)
  end
  local marker = (not tab.is_active and pane.has_unseen_output) and "● " or ""
  local label = string.format(" %s%d %s — %s ", marker, tab.tab_index + 1, proc, cwd)
  return wezterm.truncate_right(label, max_width or 32)
end)

-- ─── Right status bar ───────────────────────────────────────────────────
-- set_right_status REPLACES the entire right area, so every source has to
-- render together. The git_status user-var from zsh is cached here and
-- composed with hostname + time in update-status (fires every 1000 ms).
local git_status_cache = ""
local hostname = wezterm.hostname()

local function render_right_status(window)
  local segments = {}
  if git_status_cache ~= "" then
    table.insert(segments, git_status_cache)
  end
  table.insert(segments, hostname)
  table.insert(segments, wezterm.strftime("%a %H:%M"))
  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#8aadf4" } },
    { Text = " " .. table.concat(segments, " │ ") .. " " },
  }))
end

wezterm.on("user-var-changed", function(window, pane, name, value)
  if name == "git_status" then
    git_status_cache = value or ""
    render_right_status(window) -- redraw immediately instead of waiting for the next tick
  end
end)

wezterm.on("update-status", function(window, pane)
  render_right_status(window)
end)

return config
