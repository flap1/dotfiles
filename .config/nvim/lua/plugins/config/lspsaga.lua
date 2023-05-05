local lspsaga = require("lspsaga")
lspsaga.init_lsp_saga({ -- defaults ...
  -- use emoji lightbulb in default
  code_action_icon = " ",
  -- custom finder title winbar function type
  -- param is current word with symbol icon string type
  -- return a winbar format string like `%#CustomFinder#Test%*`
  finder_action_keys = {
    open = "o",
    vsplit = "s",
    split = "i",
    tabe = "t",
    quit = "q",
    scroll_down = "<C-f>",
    scroll_up = "<C-b>", -- quit can be a table
  },
})

vim.keymap.set("n", "M", "<cmd>Lspsaga code_action<cr>", { silent = true, noremap = true })
vim.keymap.set("x", "M", ":<c-u>Lspsaga range_code_action<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "?", "<cmd>Lspsaga hover_doc<cr>", { silent = true, noremap = true })
vim.keymap.set("n", ";r", "<cmd>Lspsaga rename<cr>", { silent = true, noremap = true })
vim.keymap.set("n", ";o", "<cmd>Lspsaga show_line_diagnostics<cr>", { silent = true, noremap = true })
vim.keymap.set("n", ";j", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, noremap = true })
vim.keymap.set("n", ";k", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", ";f", "<cmd>Lspsaga lsp_finder<CR>", { silent = true, noremap = true })
vim.keymap.set("n", ";s", "<Cmd>Lspsaga signature_help<CR>", { silent = true, noremap = true })
vim.keymap.set("n", ";d", "<cmd>Lspsaga preview_definition<CR>", { silent = true })
-- vim.keymap.set("n", ";o", "<cmd>LSoutlineToggle<CR>", { silent = true })
