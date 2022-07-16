require("hop").setup {}

vim.keymap.set({"n", "x"}, "SS", "<cmd>lua require'hop'.hint_words({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR })<CR>", {})
vim.keymap.set({"n", "x"}, "Ss", "<cmd>lua require'hop'.hint_words({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR })<CR>", {})
