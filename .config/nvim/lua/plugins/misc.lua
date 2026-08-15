-- Miscellaneous plugins
--
-- Session management lives in tmux, not here (possession removed):
-- a tmux session outlives nvim, which is the whole point of a session.

return {
  -- Buffer deletion via snacks.nvim (keeps window layout)
  {
    "folke/snacks.nvim",
    -- <Leader>b is the buffer namespace: noun then verb.
    keys = {
      { "<Leader>bd", function() Snacks.bufdelete() end,       desc = "Delete buffer" },
      { "<Leader>bD", function() Snacks.bufdelete.all() end,   desc = "Delete all buffers" },
      { "<Leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete other buffers" },
    },
  },

  -- plenary: Lua utility library (required by many plugins)
  { "nvim-lua/plenary.nvim", lazy = true },

  -- sqlite: required by frecency
  { "kkharji/sqlite.lua", lazy = true },

  -- nui: UI components
  { "MunifTanjim/nui.nvim", lazy = true },

  -- vim-repeat: dot-repeat support
  { "tpope/vim-repeat", event = "VeryLazy" },
}
