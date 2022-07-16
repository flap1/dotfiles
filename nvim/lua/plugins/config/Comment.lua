require("Comment").setup()

vim.api.nvim_set_keymap("n", "<Leader>/", "<Cmd>lua require('Comment.api').toggle_current_linewise()<CR>", {})
vim.api.nvim_set_keymap("v", "<Leader>/", "<Esc><Cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>", {})
