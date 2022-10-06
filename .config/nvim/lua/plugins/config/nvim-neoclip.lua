require("neoclip").setup({
  history = 1000,
  enable_persistent_history = true,
  db_path = vim.fn.stdpath("state") .. "/databases/neoclip.sqlite3",
  continuous_sync = true,
  default_register = { '"', '+', '*' },
  keys = {
    telescope = {
      i = { select = "<cr>", paste = "<c-l>", paste_behind = "<c-k>", replay = "<c-q>", custom = {} },
      n = { select = "<cr>", paste = "p", paste_behind = "P", replay = "q", custom = {} },
    },
  },
})

require("telescope").load_extension("neoclip")

