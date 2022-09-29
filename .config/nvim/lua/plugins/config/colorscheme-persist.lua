local persist_colorscheme = require("colorscheme-persist")

-- Setup
persist_colorscheme.setup()

-- Get stored colorscheme
local colorscheme = persist_colorscheme.get_colorscheme()

-- Set colorscheme
vim.cmd("colorscheme " .. colorscheme)

-- Keymap for telescope selection
vim.keymap.set("n", "[ff]s", require("colorscheme-persist").picker, { noremap = true, silent = true, desc = "colorscheme-persist" })

require("colorscheme-persist").setup({
  -- Absolute path to file where colorscheme should be saved
  file_path = os.getenv("HOME") .. "/.nvim.colorscheme-persist.lua",
  -- In case there's no saved colorscheme yet
  fallback = "tokyonight",
  -- List of ugly colorschemes to avoid in the selection window
  disable = {
    "darkblue",
    "default",
    "delek",
    "desert",
    "elflord",
    "evening",
    "industry",
    "koehler",
    "morning",
    "murphy",
    "pablo",
    "peachpuff",
    "ron",
    "shine",
    "slate",
    "torte",
    "zellner"
  },
  -- Options for the telescope picker
  picker_opts = require("telescope.themes").get_dropdown()
})

