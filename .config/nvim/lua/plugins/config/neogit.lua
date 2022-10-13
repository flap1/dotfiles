local neogit = require("neogit")
neogit.setup {
  disable_commit_confirmation = true,
  integrations = { diffview = true },
  kind = "replace",
  sections = {
    stashes = {
      folded = false,
    },
    recent = { folded = false },
  },
}

vim.keymap.set("n", "<Leader>g", "<Cmd>Neogit<CR>", { noremap = true, silent = true })

