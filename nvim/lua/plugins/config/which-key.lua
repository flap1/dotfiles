require("which-key").setup {
  icons = {
   breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
   separator = "➜", -- symbol used between a key and it's label
   group = "+", -- symbol prepended to a group
  },
  popup_mappings = {
    scroll_down = "<C-d>", -- binding to scroll down inside the popup 
    scroll_up = "<C-u>", -- binding to scroll up inside the popup 
  },
  window = {
    border = "none", -- none, single, double, shadow
  },
  layout = {
    spacing = 3, -- spacing between columns
  },
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
  triggers = { "<Leader>" }, -- or specify a list manually
}

vim.keymap.set("n", "<Leader><CR>", "<Cmd>WhichKey <Leader><CR>", { noremap = true })
vim.keymap.set("n", "<LocalLeader><CR>", "<Cmd>WhichKey <LocalLeader><CR>", { noremap = true })
vim.keymap.set("n", "g<CR>", "<Cmd>WhichKey g<CR>", { noremap = true })
vim.keymap.set("n", "[<CR>", "<Cmd>WhichKey [<CR>", { noremap = true })
vim.keymap.set("n", "]<CR>", "<Cmd>WhichKey ]<CR>", { noremap = true })
