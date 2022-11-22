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

local lazy = require("toggleterm.lazy")
local ui = lazy.require("toggleterm.ui")
local commandline = lazy.require("toggleterm.commandline")
local terms = require("toggleterm.terminal")
function toggle_term_open(args, count)
  local parsed = commandline.parse(args)
  vim.validate({
    size = { parsed.size, "number", true },
    dir = { parsed.dir, "string", true },
    direction = { parsed.direction, "string", true },
  })
  if parsed.size then parsed.size = tonumber(parsed.size) end
  vim.validate({ count = { count, "number", true }, size = { parsed.size, "number", true } })
  local term = terms.get_or_create_term(count, parsed.dir, parsed.direction)
  ui.update_origin_window(term.window)
  if term:is_open() then
    term:close()
    term:open(parsed.size, parsed.direction)
  else
    term:open(parsed.size, parsed.direction)
  end
end

vim.api.nvim_create_user_command(
  "ToggleTermOpen",
  function(opts) toggle_term_open(opts.args, opts.count) end, 
  { count = true, complete = commandline.toggle_term_complete, nargs = "*" }
)

vim.g.toglleterm_win_num = vim.fn.winnr()
local groupname = "vimrc_toggleterm"
vim.api.nvim_create_augroup(groupname, { clear = true })
vim.api.nvim_create_autocmd({"VimEnter", "BufEnter"}, {
  group = groupname,
  callback = function()
    -- vim.keymap.set("n", "<Leader>t", '<Cmd>execute v:count1 . "ToggleTerm"<CR>', { noremap = true, silent = true, buffer = true })
    vim.keymap.set("i", "<M-a>", "<Esc><Cmd>ToggleTermToggleAll<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" }, "<M-a>", "<Cmd>ToggleTermToggleAll<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-0>", "<Cmd>ToggleTerm<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-1>", "<Cmd>1ToggleTermOpen<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-2>", "<Cmd>2ToggleTermOpen<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-3>", "<Cmd>3ToggleTermOpen<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-4>", "<Cmd>4ToggleTermOpen<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-5>", "<Cmd>5ToggleTermOpen<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
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
    vim.keymap.set({ "t", "n" }, "<M-a>", "<Cmd>ToggleTermToggleAll<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-1>", "<Cmd>1ToggleTermOpen<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-2>", "<Cmd>2ToggleTermOpen<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-3>", "<Cmd>3ToggleTermOpen<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-4>", "<Cmd>4ToggleTermOpen<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
    vim.keymap.set({ "t", "n" } , "<M-5>", "<Cmd>5ToggleTermOpen<CR><Cmd>startinsert<CR>", { noremap = true, silent = true, buffer = true })
  end,
  once = false,
})
