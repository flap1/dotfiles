local M = {}
local wezterm = require("wezterm")
local act = wezterm.action

M.keys = {
  -- Toggle FullScreen
  { key = "Enter", mods= "ALT", action= "ToggleFullScreen" },

  -- Reload Configuration
  { key = "r", mods = "CTRL|SHIFT", action = "ReloadConfiguration" },

  -- Font Size
  { key = "=", mods = "CTRL|SHIFT", action = "ResetFontSize" },
  { key = "=", mods = "CTRL", action = "ResetFontSize" },
  { key = "+", mods = "CTRL|SHIFT", action = "IncreaseFontSize" },
  { key = "+", mods = "CTRL", action = "IncreaseFontSize" },
  { key = "-", mods = "CTRL", action = "DecreaseFontSize" },

  -- Tab
  { key = "1", mods = "ALT", action = act { ActivateTab = 0 }},
  { key = "2", mods = "ALT", action = act { ActivateTab = 1 }},
  { key = "3", mods = "ALT", action = act { ActivateTab = 2 }},
  { key = "4", mods = "ALT", action = act { ActivateTab = 3 }},
  { key = "5", mods = "ALT", action = act { ActivateTab = 4 }},
  { key = "6", mods = "ALT", action = act { ActivateTab = 5 }},
  { key = "7", mods = "ALT", action = act { ActivateTab = 6 }},
  { key = "8", mods = "ALT", action = act { ActivateTab = 7 }},
  { key = "9", mods = "ALT", action = act { ActivateTab = 8 }},
  { key = "Tab", mods= "CTRL", action= act { ActivateTabRelative = 1 }},
  { key = "Tab", mods= "CTRL|SHIFT", action= act {ActivateTabRelative = -1 }},
  { key = "h", mods = "ALT|CTRL", action = act { MoveTabRelative = -1 }},
  { key = "l", mods = "ALT|CTRL", action = act { MoveTabRelative = 1 }},
  { key = "t", mods = "ALT", action = act { SpawnTab = "DefaultDomain" }},
  { key = "q", mods = "ALT", action = act { CloseCurrentTab = { confirm = true }}},

  -- Pane
  { key = "-", mods = "ALT", action = act { SplitVertical = { domain = "CurrentPaneDomain" }}},
  { key = "\\", mods = "ALT", action = act { SplitHorizontal = { domain = "CurrentPaneDomain" }}},
  { key = "h", mods = "ALT", action = act { ActivatePaneDirection = "Left" }},
  { key = "l", mods = "ALT", action = act { ActivatePaneDirection = "Right" }},
  { key = "k", mods = "ALT", action = act { ActivatePaneDirection = "Up" }},
  { key = "j", mods = "ALT", action = act { ActivatePaneDirection = "Down" }},
  { key = "r", mods = "ALT", action = act { ActivateKeyTable = {
      name = "resize_pane",
      one_shot = false,
      timeout_milliseconds = 1000,
      replace_current = false,
  }}},
  { key = "s", mods = "ALT", action = act { PaneSelect = { alphabet = "1234567890" }}},
  { key = "b", mods = "ALT", action = act { RotatePanes = "CounterClockwise" }},
  { key = "f", mods = "ALT", action = act { RotatePanes = "Clockwise" }},

  -- Clipboard
  { key = "c", mods = "CTRL|SHIFT", action = act { CopyTo = "Clipboard" }},
  { key = "v", mods = "CTRL|SHIFT", action = act { PasteFrom = "Clipboard" }},

  -- CopyMode
  { key = "c", mods = "ALT", action = act.ActivateCopyMode },

  -- Close
  { key = "q", mods = "ALT", action = act { CloseCurrentPane = { confirm = false }}},
  { key = "x", mods = "ALT", action = act { CloseCurrentPane = { confirm = false }}},
}

M.key_tables = {
  resize_pane = {
    -- Resize Pane
    { key = "h", action = act { AdjustPaneSize = { "Left", 2 }}},
    { key = "l", action = act { AdjustPaneSize = { "Right", 2 }}},
    { key = "k", action = act { AdjustPaneSize = { "Up", 2 }}},
    { key = "j", action = act { AdjustPaneSize = { "Down", 2 }}},
    { key = "LeftArrow", action = act { AdjustPaneSize = { "Left", 2 }}},
    { key = "RightArrow", action = act { AdjustPaneSize = { "Right", 2 }}},
    { key = "UpArrow", action = act { AdjustPaneSize = { "Up", 2 }}},
    { key = "DownArrow", action = act { AdjustPaneSize = { "Down", 2 }}},

    -- Cancel the mode
    { key = "Escape", action = "PopKeyTable" },
  },
  copy_mode = {
    -- Close CopyMode
    { key = "Escape", mods = "NONE", action = act { CopyMode = "Close" }},
    { key = "q", mods = "NONE", action = act { CopyMode = "Close" }},

    -- move cursor
    { key = "h", mods = "NONE", action = act { CopyMode = "MoveLeft" }},
    { key = "j", mods = "NONE", action = act { CopyMode = "MoveDown" }},
    { key = "k", mods = "NONE", action = act { CopyMode = "MoveUp" }},
    { key = "l", mods = "NONE", action = act { CopyMode = "MoveRight" }},
    { key = "LeftArrow", mods = "NONE", action = act { CopyMode = "MoveLeft" }},
    { key = "DownArrow", mods = "NONE", action = act { CopyMode = "MoveDown" }},
    { key = "UpArrow", mods = "NONE", action = act { CopyMode = "MoveUp" }},
    { key = "RightArrow", mods = "NONE", action = act { CopyMode = "MoveRight" }},

    -- move word
    { key = "RightArrow", mods = "ALT", action = act { CopyMode = "MoveForwardWord" }},
    { key = "LeftArrow", mods = "ALT", action = act { CopyMode = "MoveBackwardWord" }},
    { key = "\t", mods = "NONE", action = act { CopyMode = "MoveForwardWord" }},
    { key = "\t", mods = "SHIFT", action = act { CopyMode = "MoveBackwardWord" }},
    { key = "w", mods = "NONE", action = act { CopyMode = "MoveForwardWord" }},
    { key = "b", mods = "NONE", action = act { CopyMode = "MoveBackwardWord" }},
    { key = "e", mods = "NONE", action = act { Multiple = {
        act { CopyMode = "MoveRight" },
        act { CopyMode = "MoveForwardWord" },
        act { CopyMode = "MoveLeft" },
    }}},

    -- move start/end
    { key = "0", mods = "NONE", action = act { CopyMode = "MoveToStartOfLine" }},
    { key = "^", mods = "SHIFT", action = act { CopyMode = "MoveToStartOfLineContent" }},
    { key = "^", mods = "NONE", action = act { CopyMode = "MoveToStartOfLineContent" }},
    { key = "$", mods = "SHIFT", action = act { CopyMode = "MoveToEndOfLineContent" }},
    { key = "$", mods = "NONE", action = act { CopyMode = "MoveToEndOfLineContent" }},

    -- select
    { key = "v", mods = "NONE", action = act { CopyMode = { SetSelectionMode = "Cell" }}},
    { key = "v", mods = "SHIFT", action = act { Multiple = {
        act { CopyMode = "MoveToStartOfLineContent" },
        act { CopyMode = { SetSelectionMode = "Cell" }},
        act { CopyMode = "MoveToEndOfLineContent" },
    }}},

    -- copy
    { key = "y", mods = "NONE", action = act { Multiple = {
        act { CopyTo = "ClipboardAndPrimarySelection" },
        act { CopyMode = "Close" },
    }}},
    { key = "y", mods = "SHIFT", action = act { Multiple = {
        act { CopyMode = { SetSelectionMode = "Cell" }},
        act { CopyMode = "MoveToEndOfLineContent" },
        act { CopyTo = "ClipboardAndPrimarySelection" },
        act { CopyMode = "Close" },
    }}},

    -- scroll
    { key = "G", mods = "SHIFT", action = act { CopyMode = "MoveToScrollbackBottom" }},
    { key = "G", mods = "NONE", action = act { CopyMode = "MoveToScrollbackBottom" }},
    { key = "g", mods = "NONE", action = act { CopyMode = "MoveToScrollbackTop" }},
    { key = "H", mods = "NONE", action = act { CopyMode = "MoveToViewportTop" }},
    { key = "H", mods = "SHIFT", action = act { CopyMode = "MoveToViewportTop" }},
    { key = "M", mods = "NONE", action = act { CopyMode = "MoveToViewportMiddle" }},
    { key = "M", mods = "SHIFT", action = act { CopyMode = "MoveToViewportMiddle" }},
    { key = "L", mods = "NONE", action = act { CopyMode = "MoveToViewportBottom" }},
    { key = "L", mods = "SHIFT", action = act { CopyMode = "MoveToViewportBottom" }},
    { key = "o", mods = "NONE", action = act { CopyMode = "MoveToSelectionOtherEnd" }},
    { key = "O", mods = "NONE", action = act { CopyMode = "MoveToSelectionOtherEndHoriz" }},
    { key = "O", mods = "SHIFT", action = act { CopyMode = "MoveToSelectionOtherEndHoriz" }},
    { key = "PageUp", mods = "NONE", action = act { CopyMode = "PageUp" }},
    { key = "PageDown", mods = "NONE", action = act { CopyMode = "PageDown" }},
    { key = "b", mods = "CTRL", action = act { CopyMode = "PageUp" }},
    { key = "f", mods = "CTRL", action = act { CopyMode = "PageDown" }},
    { key = "Enter", mods = "NONE", action = act { CopyMode = "ClearSelectionMode" }},

    -- search
    { key = "/", mods = "NONE", action = act { Search = { CaseSensitiveString = "" }}},
    { key = "n", mods = "NONE", action = act { Multiple = {
        act { CopyMode = "NextMatch" },
        act { CopyMode = "ClearSelectionMode" },
    }}},
    { key = "N", mods = "SHIFT", action = act { Multiple = {
        act { CopyMode = "PriorMatch" },
        act { CopyMode = "ClearSelectionMode" },
    }}},
  },

  search_mode = {
    { key = "Escape", mods = "NONE", action = act { CopyMode = "Close" }},
    { key = "Enter", mods = "NONE", action = act { Multiple = {
        act.ActivateCopyMode,
        act { CopyMode = "ClearSelectionMode" },
    }}},
    { key = "p", mods = "CTRL", action = act { CopyMode = "PriorMatch" }},
    { key = "n", mods = "CTRL", action = act { CopyMode = "NextMatch" }},
    { key = "r", mods = "CTRL", action = act { CopyMode = "CycleMatchType" }},
    { key = "u", mods = "CTRL", action = act { CopyMode = "ClearPattern" }},
  },
}

M.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" }},
    mods = "NONE",
    action = act { CompleteSelection = "PrimarySelection" },
  },
  {
    event = { Up = { streak = 1, button = "Right" }},
    mods = "NONE",
    action = act { CompleteSelection = "Clipboard" },
  },
  {
    event = { Up = { streak = 1, button = "Left" }},
    mods = "CTRL",
    action = "OpenLinkAtMouseCursor",
  },
}

return M
