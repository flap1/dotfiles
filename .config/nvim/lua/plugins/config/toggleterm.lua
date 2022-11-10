require("toggleterm").setup({
  -- size can be a number or function which is passed the current terminal
  size = function(term)
    if term.direction == "horizontal" then
      return vim.fn.float2nr(vim.o.lines * 0.25)
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  hide_numbers = true, -- hide the number column in toggleterm buffers
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
  start_in_insert = false,
  insert_mappings = true, -- whether or not the open mapping applies in insert mode
  persist_size = false,
  direction = "horizontal",
  close_on_exit = false, -- close the terminal window when the process exits
  shell = vim.o.shell, -- change the default shell
  -- This field is only relevant if direction is set to 'float'
  float_opts = {
    -- The border key is *almost* the same as 'nvim_win_open'
    -- see :h nvim_win_open for details on borders however
    -- the 'curved' border is a custom border type
    -- not natively supported but implemented in this plugin.
    border = "single",
    width = math.floor(vim.o.columns * 0.9),
    height = math.floor(vim.o.lines * 0.9),
    winblend = 3,
    highlights = { border = "ColorColumn", background = "ColorColumn" },
  },
})

-- local Terminal = require('toggleterm.terminal').Terminal
-- local lazygit  = Terminal:new({
--   cmd = "lazygit",
--   dir = "git_dir",
--   count = 5,
--   direction = "float",
--   float_opts = {
--     border = "double",
--   },
--   -- function to run on opening the terminal
--   on_open = function(term)
--     vim.cmd("startinsert!")
--     -- vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })
--     vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
--     vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<C-q>", "<cmd>close<CR>", { noremap = true, silent = true })
--   end,
--   -- function to run on closing the terminal
--   on_close = function(term)
--     vim.cmd("startinsert!")
--   end,
-- })

-- function _Lazygit_toggle()
--   lazygit:toggle()
-- end

vim.g.toglleterm_win_num = vim.fn.winnr()
local groupname = "vimrc_toggleterm"
vim.api.nvim_create_augroup(groupname, { clear = true })
vim.api.nvim_create_autocmd({"VimEnter", "BufEnter"}, {
  group = groupname,
  callback = function()
    -- vim.keymap.set("n", "<leader>g", "<cmd>lua _Lazygit_toggle()<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<Leader>t", '<Cmd>execute v:count1 . "ToggleTerm"<CR>', { noremap = true, silent = true, buffer = true })
    vim.keymap.set("i", "<C-q>", "<Esc><Cmd>ToggleTermToggleAll<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" }, "<C-q>", "<Cmd>ToggleTermToggleAll<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>q", "<Cmd>ToggleTerm<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>1", "<Cmd>1ToggleTerm<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>2", "<Cmd>2ToggleTerm<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>3", "<Cmd>3ToggleTerm<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>4", "<Cmd>4ToggleTerm<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>5", "<Cmd>5ToggleTerm<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
  end,
  once = false,
})
vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "BufEnter" }, {
  group = groupname,
  pattern = "term://*/zsh;#toggleterm#*",
  callback = function()
    vim.cmd([[startinsert]])
  end,
  once = false,
})
vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter" }, {
  group = groupname,
  pattern = "term://*#toggleterm#[^9]",
  callback = function()
    vim.keymap.set("t", "<C-[>", "<C-\\><C-n>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set("t", "jk", "<C-\\><C-n>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>1", "<Cmd>1ToggleTerm<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>2", "<Cmd>2ToggleTerm<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>3", "<Cmd>3ToggleTerm<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>4", "<Cmd>4ToggleTerm<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<C-t>5", "<Cmd>5ToggleTerm<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
  end,
  once = false,
})
