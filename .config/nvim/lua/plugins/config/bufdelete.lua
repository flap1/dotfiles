-- vim.keymap.set("n", "<C-x>", "<Cmd>lua require('bufdelete').bufwipeout(0, true)<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>x", "<Cmd>lua require('bufdelete').bufwipeout(0, true)<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<M-x>", "<Cmd>lua require('bufdelete').bufwipeout(0, true)<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<M-x>", "<Esc><Cmd>lua require('bufdelete').bufwipeout(0, true)<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<M-x>", "<C-\\><C-n><Cmd>lua require('bufdelete').bufwipeout(0, true)<CR>", { noremap = true, silent = true })

