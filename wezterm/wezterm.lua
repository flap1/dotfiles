-- https://wezfurlong.org/
local wezterm = require("wezterm")
local bindings= require("bindings")
local scheme = wezterm.get_builtin_color_schemes()["nightfox"]
require("on")

return {
  -- font
	font = wezterm.font("UDEV Gothic 35NFLG"),
  font_size = 9.0,

  -- enable ime
  use_ime = true,

  -- the maximum frame rate used when rendering easing effects for blinking cursors, blinking text and visual bell.
  animation_fps = 1,
  -- cursor blink
  cursor_blink_ease_in = 'Constant',
  cursor_blink_ease_out = 'Constant',
  cursor_blink_rate = 0,

  -- color scheme
  color_scheme = "nightfox",
  color_scheme_dirs = { os.getenv("HOME") .. "/.config/wezterm/colors/" },

  -- the boundaries of a word
  selection_word_boundary = " \t\n{}[]()\"'`,;:│=&!%",

  -- the amount of padding between the window border and the terminal cells
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
	},

  -- the tab bar is rendered using a retro aesthetic using the main terminal font
  use_fancy_tab_bar = false,

  -- Tab Bar Appearance & Colors
  colors = {
    tab_bar = {
      background = scheme.background,
      -- The new tab button that let you create new tabs
      new_tab = { bg_color = scheme.ansi[1], fg_color = scheme.ansi[8], intensity = "Bold" },
      -- moves over the new tab button
      new_tab_hover = { bg_color = scheme.ansi[1], fg_color = scheme.brights[8], intensity = "Bold" },
    },
  },

  -- Key Mappings
  -- disable all of the default key assignments 
  disable_default_key_bindings = true,
  -- set Leader Key
  leader = { key = "\\", mods = "CTRL" },
  keys = bindings.keys,
  key_tables = bindings.key_tables,
  mouse_bindings = bindings.mouse_bindings,
}
