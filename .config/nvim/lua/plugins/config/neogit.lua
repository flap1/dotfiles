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

vim.keymap.set("n", "G<Space>", "<Cmd>Neogit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "Gs", "<Cmd>Neogit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "GS", "<Cmd>Neogit<CR>", { noremap = true, silent = true })

