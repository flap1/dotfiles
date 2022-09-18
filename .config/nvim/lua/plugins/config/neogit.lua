local neogit = require("neogit")
neogit.setup {
  disable_commit_confirmation = true,
  integrations = { diffview = true },
  sections = {
    stashes = {
      folded = false,
    },
    recent = { folded = false },
  },
}

vim.keymap.set("n", "[git]<Space>", "<Cmd>Neogit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "[git]s", "<Cmd>Neogit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "[git]S", "<Cmd>Neogit<CR>", { noremap = true, silent = true })

