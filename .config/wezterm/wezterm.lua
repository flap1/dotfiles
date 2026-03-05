-- https://wezfurlong.org/
local wezterm = require("wezterm")
local bindings = require("bindings")
local mux = wezterm.mux

-- Always open window maximized
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return {
  -- font
  font = wezterm.font("UDEV Gothic 35NFLG"),
  font_size = 9.0,

  -- enable ime
  use_ime = true,

  -- cursor: no blink
  animation_fps = 1,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  cursor_blink_rate = 0,

  -- color scheme: tokyonight (matches nvim theme)
  color_scheme = "Tokyo Night (Gogh)",

  -- the boundaries of a word
  selection_word_boundary = " \t\n{}[]()\"'`,;:│=&!%",

  -- zen: no titlebar, no tab bar
  window_decorations = "RESIZE",
  enable_tab_bar = false,

  -- padding
  window_padding = {
    left = 4,
    right = 4,
    top = 4,
    bottom = 0,
  },

  -- Key Mappings
  disable_default_key_bindings = true,
  leader = { key = "\\", mods = "CTRL" },
  keys = bindings.keys,
  key_tables = bindings.key_tables,
  mouse_bindings = bindings.mouse_bindings,
}
