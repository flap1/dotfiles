require("hop").setup {}

vim.keymap.set({"n", "x"}, "<Leader>S", "<cmd>lua require'hop'.hint_words({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR })<CR>", {})
vim.keymap.set({"n", "x"}, "<Leader>s", "<cmd>lua require'hop'.hint_words({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR })<CR>", {})
