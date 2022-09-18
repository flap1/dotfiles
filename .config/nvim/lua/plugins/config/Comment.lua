-- https://github.com/numToStr/Comment.nvim
   
require("Comment").setup({
  ignore = '^(%s*)$'
})

vim.api.nvim_set_keymap("n", "<Leader>/", "<Cmd>lua require('Comment.api').toggle.linewise.current()<CR>", {})
vim.api.nvim_set_keymap("v", "<Leader>/", "<Esc><Cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", {})

