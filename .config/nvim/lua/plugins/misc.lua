-- Miscellaneous plugins

return {
  -- possession: session management
  {
    "jedrzejboczar/possession.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "PossessionSave", "PossessionLoad", "PossessionList" },
    opts = {
      autosave = {
        current = false,
        tmp = true,
        tmp_name = "tmp",
        on_load = true,
        on_quit = true,
      },
    },
    config = function(_, opts)
      require("possession").setup(opts)
      require("telescope").load_extension("possession")
    end,
    keys = {
      { "<Leader>ss", "<Cmd>PossessionSave<CR>",  desc = "Session save" },
      { "<Leader>sl", "<Cmd>PossessionLoad<CR>",  desc = "Session load" },
      { "<Leader>sf", "<Cmd>Telescope possession list<CR>", desc = "Session list" },
    },
  },

  -- Buffer deletion via snacks.nvim (keeps window layout)
  {
    "folke/snacks.nvim",
    keys = {
      { "<Leader>bd", function() Snacks.bufdelete() end,            desc = "Delete buffer" },
      { "<Leader>bD", function() Snacks.bufdelete.all() end,        desc = "Delete all buffers" },
      { "<Leader>bo", function() Snacks.bufdelete.other() end,      desc = "Delete other buffers" },
    },
  },

  -- plenary: Lua utility library (required by many plugins)
  { "nvim-lua/plenary.nvim", lazy = true },

  -- sqlite: required by neoclip, frecency
  { "kkharji/sqlite.lua", lazy = true },

  -- nui: UI components
  { "MunifTanjim/nui.nvim", lazy = true },

  -- vim-repeat: dot-repeat support
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- cheatsheet (personal fork)
  {
    "flap1/cheatsheet.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
    },
    cmd = "Cheatsheet",
    keys = {
      { "<Leader>?", "<Cmd>Cheatsheet<CR>", desc = "Cheatsheet" },
    },
    opts = {},
  },

  -- calendar-vim (for telekasten)
  {
    "renerocksai/calendar-vim",
    cmd = "Calendar",
    keys = {
      { "<Leader>cal", "<Cmd>Calendar<CR>", desc = "Calendar" },
    },
  },

  -- Dependency libraries (lazy-loaded)
  { "nvim-lua/popup.nvim", lazy = true },
}
