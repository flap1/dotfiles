local opts = { noremap = true, silent = true }
local optsexpr = { noremap = true, expr = true, silent = true }

-- Reload config
vim.keymap.set("n", "<LocalLeader><CR>", "<Cmd>source $MYVIMRC<CR>", opts)

-- Open browser
vim.keymap.set("n", "gx", "<Cmd>silent! !xdg-open <cWORD><CR>", opts)

-- Disable dangerous defaults
vim.keymap.set("n", "ZZ", "<Nop>", opts)
vim.keymap.set("n", "ZQ", "<Nop>", opts)
vim.keymap.set("n", "Q", "<Nop>", opts)
vim.keymap.set("n", "<C-c>", "<Nop>", opts)

-- Insert mode
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = false })
vim.keymap.set("i", "ｊｋ", "<Esc>", opts)
vim.keymap.set("i", "<C-t>", '<Esc><Left>"zx"zpa', { noremap = true, silent = false })

-- Terminal mode
vim.keymap.set("t", "jk", "<C-\\><C-n>", { noremap = true, silent = false })

-- Indent
vim.keymap.set("n", "<C-x>", ">>", opts)
vim.keymap.set("n", "<C-z>", "<<", opts)

-- Save / Quit
vim.keymap.set({ "n", "t" }, "<M-q>", "<Cmd>q<CR>", opts)
vim.keymap.set("i", "<M-q>", "<Esc><Cmd>q<CR>", opts)
vim.keymap.set({ "n", "t" }, "<M-w>", "<Cmd>w<CR>", opts)
vim.keymap.set("i", "<M-w>", "<Esc><Cmd>w<CR>", opts)
vim.keymap.set("n", "<Leader>w", "<Cmd>w<CR>", opts)
vim.keymap.set("n", "<Leader>q", "<Cmd>q<CR>", opts)
vim.keymap.set("n", "<Leader>aq", "<Cmd>qa<CR>", opts)
vim.keymap.set("n", "<Leader>aw", "<Cmd>wa<CR>", opts)

-- Buffer navigation
vim.keymap.set("n", "[b", ":bprevious<CR>", opts)
vim.keymap.set("n", "]b", ":bnext<CR>", opts)
vim.keymap.set("n", "[B", ":bfirst<CR>", opts)
vim.keymap.set("n", "]B", ":blast<CR>", opts)

-- Window switching (smart-splits handles <C-hjkl> and <M-hjkl> for resize)
vim.keymap.set("n", "<M-o>", "<C-w>o", opts)
vim.keymap.set("i", "<M-o>", "<Esc><C-w>o", opts)
vim.keymap.set("t", "<M-o>", "<C-\\><C-n><C-w>o", opts)

-- Window switching by number
for i = 1, 9 do
  vim.keymap.set("n", ";" .. i, ":" .. i .. "wincmd w<CR>", opts)
end


-- Tab navigation
for i = 1, 9 do
  vim.keymap.set("n", "<LocalLeader>" .. i, i .. "gt", opts)
end
vim.keymap.set("n", "<M-t>j", "<Cmd>tabprevious<CR>", opts)
vim.keymap.set("n", "<M-t>k", "<Cmd>tabnext<CR>", opts)
vim.keymap.set("n", "<M-t>J", "<Cmd>-tabm<CR>", opts)
vim.keymap.set("n", "<M-t>K", "<Cmd>+tabm<CR>", opts)
vim.keymap.set("n", "<M-t>q", "<Cmd>tabclose<CR>", opts)
vim.keymap.set("n", "<M-t>n", "<Cmd>tabnew<CR>", opts)
vim.keymap.set("n", "<LocalLeader>[", "<Cmd>tabprevious<CR>", opts)
vim.keymap.set("n", "<LocalLeader>]", "<Cmd>tabnext<CR>", opts)
vim.keymap.set("n", "<LocalLeader>q", "<Cmd>tabclose<CR>", opts)
vim.keymap.set("n", "<LocalLeader>n", "<Cmd>tabnew<CR>", opts)

-- Cursor movement
vim.keymap.set({ "n", "x" }, "H", "5h", opts)
vim.keymap.set({ "n", "x" }, "L", "5l", opts)
vim.keymap.set({ "n", "x" }, "gJ", "J", opts)
vim.keymap.set({ "n", "x" }, "j", function() return vim.v.count > 0 and "j" or "gj" end, optsexpr)
vim.keymap.set({ "n", "x" }, "k", function() return vim.v.count > 0 and "k" or "gk" end, optsexpr)
vim.keymap.set("n", "gH", "H", opts)
vim.keymap.set("n", "gM", "M", opts)
vim.keymap.set("n", "gL", "L", opts)

-- Jump cursor (Enter = 10j center)
vim.keymap.set("n", "<CR>",
  function() return vim.o.buftype == "quickfix" and "<CR>" or vim.v.count > 0 and "0jzz" or "10jzz" end, optsexpr)

-- Auto indent with i/A on empty lines
vim.keymap.set("n", "i", function()
  return vim.fn.len(vim.fn.getline(".")) ~= 0 and "i" or '"_cc'
end, optsexpr)
vim.keymap.set("n", "A", function()
  return vim.fn.len(vim.fn.getline(".")) ~= 0 and "A" or '"_cc'
end, optsexpr)

-- Toggle 0 / ^
vim.keymap.set("n", "0",
  function()
    return string.match(vim.fn.getline("."):sub(0, vim.fn.col(".") - 1), "^%s+$") and "0" or "^"
  end, optsexpr)
vim.keymap.set("n", "$",
  function()
    return string.match(vim.fn.getline("."):sub(0, vim.fn.col(".")), "^%s+$") and "$" or "g_"
  end, optsexpr)

-- Emacs-style navigation
vim.keymap.set({ "i", "c", "t" }, "<C-b>", "<Left>", { noremap = true, silent = false })
vim.keymap.set({ "i", "c", "t" }, "<C-f>", "<Right>", { noremap = true, silent = false })
vim.keymap.set({ "i", "c", "t" }, "<C-p>", "<Up>", { noremap = true, silent = false })
vim.keymap.set({ "i", "c", "t" }, "<C-n>", "<Down>", { noremap = true, silent = false })
vim.keymap.set({ "i", "c", "t" }, "<C-a>", "<Home>", { noremap = true, silent = false })
vim.keymap.set({ "i", "t" }, "<C-e>", "<End>", { noremap = true, silent = false })
vim.keymap.set({ "i", "c", "t" }, "<C-d>", "<Del>", { noremap = true, silent = false })
vim.keymap.set({ "i", "c", "t" }, "<C-h>", "<BS>", { noremap = true, silent = false })
vim.keymap.set({ "i", "t" }, "<M-b>", "<C-Left>", { noremap = true, silent = false })
vim.keymap.set("c", "<M-b>", "<S-Left>", { noremap = true, silent = false })
vim.keymap.set("c", "<Esc>b", "<S-Left>", { noremap = true, silent = false })
vim.keymap.set("c", "<Esc>f", "<S-Right>", { noremap = true, silent = false })
if not vim.g.vscode then
  vim.keymap.set("c", "<C-e>", "<End>", { noremap = true, silent = false })
end

-- Function keys: escape to normal first
for i = 1, 12 do
  vim.keymap.set({ "i", "c", "t" }, "<F" .. i .. ">", "<Esc><F" .. i .. ">", opts)
end

-- Clear search highlight
vim.keymap.set("n", "gq", "<Cmd>nohlsearch<CR>", opts)
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR><C-L><Esc>", opts)

-- Inner word shortcuts
vim.keymap.set("n", "d<Space>", "diw", opts)
vim.keymap.set("n", "c<Space>", "ciw", opts)
vim.keymap.set("n", "y<Space>", "yiw", opts)
vim.keymap.set({ "n", "x" }, "gy", "y`>", opts)

-- Yank / paste with register 0
vim.keymap.set({ "n", "x" }, "<LocalLeader>y", '"0y', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>p", '"0p', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>P", '"0P', opts)
vim.keymap.set("x", "p", '"_xP', opts)

-- Void register ops
vim.keymap.set({ "n", "x" }, "<LocalLeader>x", '"_x', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>d", '"_d', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>D", '"_D', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>c", '"_c', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>C", '"_C', opts)

-- Move through changes
vim.keymap.set("n", "^", "g;zz", opts)
vim.keymap.set("n", "&", "g,zz", opts)

-- Paragraph / section jumps (center)
vim.keymap.set("n", "(", "{zz", opts)
vim.keymap.set("n", ")", "}zz", opts)
vim.keymap.set("n", "]]", "]]zz", opts)
vim.keymap.set("n", "[[", "[[zz", opts)

-- Quickfix / location list
vim.keymap.set("n", "[q", ":cprevious<CR>", opts)
vim.keymap.set("n", "]q", ":cnext<CR>", opts)
vim.keymap.set("n", "[Q", ":cfirst<CR>", opts)
vim.keymap.set("n", "]Q", ":clast<CR>", opts)
vim.keymap.set("n", "[l", ":lprevious<CR>", opts)
vim.keymap.set("n", "]l", ":lnext<CR>", opts)
vim.keymap.set("n", "[L", ":lfirst<CR>", opts)
vim.keymap.set("n", "]L", ":llast<CR>", opts)
vim.keymap.set("n", ";q", "<Cmd>ToggleQF<CR>", { noremap = true, silent = false })

-- Search
vim.keymap.set("n", "n", "'Nn'[v:searchforward]", optsexpr)
vim.keymap.set("n", "N", "'nN'[v:searchforward]", optsexpr)
vim.keymap.set({ "n", "x" }, "g*", "*", opts)
vim.keymap.set({ "n", "x" }, "g#", "#", opts)
vim.keymap.set("n", "*", "g*N", opts)
vim.keymap.set("n", "#", "g*N", opts)
vim.keymap.set("x", "*", 'y/<C-R>"<CR>N', opts)
vim.keymap.set("n", "/", "/\\v", opts)
vim.keymap.set("n", "g/", "/\\v", { noremap = true, silent = false })
vim.keymap.set("x", "/", "<ESC>/\\%V", { noremap = true, silent = false })
vim.keymap.set("x", "?", "<ESC>?\\%V", { noremap = true, silent = false })

-- Replace
vim.keymap.set("n", "<LocalLeader>s", ":%s/\\<<C-r><C-w>\\>/", { noremap = true, silent = false })
vim.keymap.set("x", "<LocalLeader>s", ":s/\\%V", { noremap = true, silent = false })
vim.keymap.set("n", ";s",
  function()
    return vim.o.buftype == "quickfix" and ":QfReplacer<CR>:%s/\\v" or ":%s/\\v"
  end, { noremap = true, silent = false, expr = true })

-- Change directory
vim.keymap.set("n", "<LocalLeader>cd", "<Cmd>lcd %:p:h<CR>:pwd<CR>", opts)

-- Splits
vim.keymap.set("n", "-", "<Cmd>split<CR>", opts)
vim.keymap.set("n", "\\", "<Cmd>vsplit<CR>", opts)

-- Encoding
vim.keymap.set("n", "<LocalLeader>eu", "<Cmd>e ++enc=utf-8<CR>", opts)
vim.keymap.set("n", "<LocalLeader>es", "<Cmd>e ++enc=cp932<CR>", opts)
vim.keymap.set("n", "<LocalLeader>ee", "<Cmd>e ++enc=euc-jp<CR>", opts)
vim.keymap.set("n", "<LocalLeader>ej", "<Cmd>e ++enc=iso-2022-jp<CR>", opts)

-- Header line fill
vim.keymap.set("n", "<LocalLeader>-", function()
  local linenum = 50
  local margin = vim.fn.col("$") - 1 > 0 and " " or "--"
  return "A" .. margin .. string.rep("-", linenum - vim.fn.col("$")) .. "<Esc>"
end, optsexpr)

-- Command mode
vim.keymap.set("c", "<C-x>", "<C-r>=expand('%:p:h')<CR>/", { noremap = true, silent = false })
vim.keymap.set("c", "<C-z>", "<C-r>=expand('%:p:r')<CR>", { noremap = true, silent = false })
vim.keymap.set("c", "<C-p>", "<Up>", { noremap = true, silent = false })
vim.keymap.set("c", "<C-n>", "<Down>", { noremap = true, silent = false })
vim.keymap.set("c", "<Up>", "<C-p>", { noremap = true, silent = false })
vim.keymap.set("c", "<Down>", "<C-n>", { noremap = true, silent = false })
vim.o.cedit = "<C-c>"

-- Operator
vim.keymap.set("o", "<Space>", "iw", opts)
vim.keymap.set("o", 'a"', '2i"', opts)
vim.keymap.set("o", "a'", "2i'", opts)
vim.keymap.set("o", "a`", "2i`", opts)

-- Japanese input mode keys
vim.keymap.set("n", "あ", "a", opts)
vim.keymap.set("n", "い", "i", opts)
vim.keymap.set("n", "う", "u", opts)
vim.keymap.set("n", "お", "o", opts)
