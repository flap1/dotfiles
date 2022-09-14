require("telescope").setup {
  extensions = {
    frecency = {
      db_root = vim.fn.stdpath("state"),
      ignore_patterns = { "*.git/*", "*/tmp/*", "*/node_modules/*" },
      db_safe_mode = false,
      auto_validate = true,
    },
  },
}

local opts = { noremap = true, silent = true }

-- find ------------------------------------------
vim.keymap.set("n", "<Leader>ff", "<Cmd>Telescope find_files<CR>", opts )
vim.keymap.set("n", "<Leader>fa", "<Cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", opts )
vim.keymap.set("n", "<Leader>fw", "<Cmd>Telescope live_grep<CR>", opts )
vim.keymap.set("n", "<Leader>fb", "<Cmd>Telescope buffers<CR>", opts )
vim.keymap.set("n", "<Leader>fh", "<Cmd>Telescope help_tags<CR>", opts )
vim.keymap.set("n", "<Leader>fo", "<Cmd>Telescope oldfiles<CR>", opts )
vim.keymap.set("n", "<Leader>fk", "<Cmd>Telescope keymaps<CR>", opts )
vim.keymap.set("n", "<Leader>fm", "<Cmd>Telescope marks<CR>", opts )
vim.keymap.set("n", "<Leader>fs", "<Cmd>Telescope search_history<CR>", opts )
vim.keymap.set("n", "<Leader>fr", "<Cmd>Telescope registers<CR>", opts )
-- git -------------------------------------------
vim.keymap.set("n", "<Leader>cm", "<Cmd>Telescope git_commits<CR>", opts )
vim.keymap.set("n", "<Leader>gt", "<Cmd>Telescope git_status<CR>", opts )

