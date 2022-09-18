---------------------------------------------------------------------------------------------------+
-- Commands \ Modes | Normal | Insert | Command | Visual | Select | Operator | Terminal | Lang-Arg |
-- ================================================================================================+
-- map  / noremap   |    @   |   -    |    -    |   @    |   @    |    @     |    -     |    -     |
-- nmap / nnoremap  |    @   |   -    |    -    |   -    |   -    |    -     |    -     |    -     |
-- map! / noremap!  |    -   |   @    |    @    |   -    |   -    |    -     |    -     |    -     |
-- imap / inoremap  |    -   |   @    |    -    |   -    |   -    |    -     |    -     |    -     |
-- cmap / cnoremap  |    -   |   -    |    @    |   -    |   -    |    -     |    -     |    -     |
-- vmap / vnoremap  |    -   |   -    |    -    |   @    |   @    |    -     |    -     |    -     |
-- xmap / xnoremap  |    -   |   -    |    -    |   @    |   -    |    -     |    -     |    -     |
-- smap / snoremap  |    -   |   -    |    -    |   -    |   @    |    -     |    -     |    -     |
-- omap / onoremap  |    -   |   -    |    -    |   -    |   -    |    @     |    -     |    -     |
-- tmap / tnoremap  |    -   |   -    |    -    |   -    |   -    |    -     |    @     |    -     |
-- lmap / lnoremap  |    -   |   @    |    @    |   -    |   -    |    -     |    -     |    @     |
---------------------------------------------------------------------------------------------------+

local opts = { noremap = true, silent = true }
local optsexpr = { noremap = true, expr = true, silent = true}

vim.keymap.set("n", "<Leader><CR>", "<Cmd>luafile %<CR>", opts) -- reload config
vim.keymap.set("n", "<Leader><Leader><CR>", "<Cmd>luafile %<CR><Cmd>luafile ~/.config/nvim/lua/plugins/init.lua<CR><Cmd>PackerSync<CR>", opts) -- reload config

-- lsp
vim.keymap.set("n", ";", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "[lsp]", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ";", "[lsp]", {})

-- git, use
vim.keymap.set("n", "G", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "[git]", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "GG", "G", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "G", "[git]", {})

-- FuzzyFinder
vim.keymap.set({ "n", "v" }, "<Leader>f", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "[ff]", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>f", "[ff]", {})
vim.api.nvim_set_keymap("v", "<Leader>f", "[ff]", {})

-- tab
vim.keymap.set("n", "<Leader>t", "<Nop>", opts)
vim.keymap.set("n", "[tab]", "<Nop>", opts)
vim.api.nvim_set_keymap("n", "<Leader>t", "[tab]", {})

-- header -----------------------------------------
vim.keymap.set("n", "<LocalLeader>-", function()
  local linenum = 50
  local margin = vim.fn.col("$") - 1 > 0 and " " or "--"
  return "A"..margin..string.rep("-", linenum - vim.fn.col("$")).."<Esc>"
end, optsexpr)

-- Plugins ----------------------------------------
-- hop
vim.keymap.set({ "n", "x" }, "S", "<Nop>", opts)

-- iswap
vim.keymap.set("n", "<Leader>s", "<Nop>", opts)

-- lightspeed
vim.keymap.set("n", "t", "<Nop>", opts)
vim.keymap.set("n", "T", "<Nop>", opts)

-- dial
vim.keymap.set("n", "_", "<Nop>", opts)
vim.keymap.set("n", "+", "<Nop>", opts)
vim.keymap.set("n", "<C-a>", "<Nop>", opts)
vim.keymap.set("n", "<C-x>", "<Nop>", opts)

-- not used --------------------------------------
vim.keymap.set("n", "ZZ", "<Nop>", opts)
vim.keymap.set("n", "ZQ", "<Nop>", opts)
vim.keymap.set("n", "Q", "<Nop>", opts)
vim.keymap.set("n", "=", "<Nop>", opts)
vim.keymap.set('n', '<C-c>', '<Nop>', opts)

-- Change current directory
vim.keymap.set("n", "<LocalLeader>cd", "<Cmd>lcd %:p:h<CR>:pwd<CR>", { noremap = true, silent = true })

-- insert mode
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = false }) -- jk to Esc
vim.keymap.set("i", "<C-t>", '<Esc><Left>"zx"zpa', { noremap = true, silent = false }) -- 直前2つ入れ替え

-- w/q
vim.keymap.set("n", "<Leader>w", "<Cmd>w<CR>", opts)
vim.keymap.set("n", "<Leader>q", "<Cmd>q<CR>", opts)

-- Move up and down the line
vim.keymap.set("i", "<C-Up>", '<Esc>"zdd<Up>"zPi', opts)
vim.keymap.set("i", "<C-Down>", '<Esc>"zdd"zpi', opts)
vim.keymap.set("n", "<C-Up>", '"zdd<Up>"zP', opts)
vim.keymap.set("n", "<C-Down>", '"zdd"zp', opts)
vim.keymap.set("x", "<C-Up>", '"zx<Up>"zP`[V`]', opts)
vim.keymap.set("x", "<C-Down>", '"zx"zp`[V`]', opts)

-- buffer
vim.keymap.set("n", "[b", ":bprevious<CR>", opts)
vim.keymap.set("n", "]b", ":bnext<CR>", opts)
vim.keymap.set("n", "[B", ":bfirst<CR>", opts)
vim.keymap.set("n", "]B", ":blast<CR>", opts)
-- see also bufferline.lua

-- switch window
vim.keymap.set("n", "<Leader>h", "<C-w>h", opts)
vim.keymap.set("n", "<Leader>j", "<C-w>j", opts)
vim.keymap.set("n", "<Leader>k", "<C-w>k", opts)
vim.keymap.set("n", "<Leader>l", "<C-w>l", opts)

-- switch tab
vim.keymap.set("n", "[tab]1", "1gt", opts)
vim.keymap.set("n", "[tab]2", "2gt", opts)
vim.keymap.set("n", "[tab]3", "3gt", opts)
vim.keymap.set("n", "[tab]4", "4gt", opts)
vim.keymap.set("n", "[tab]5", "5gt", opts)
vim.keymap.set("n", "[tab]6", "6gt", opts)
vim.keymap.set("n", "[tab]7", "7gt", opts)
vim.keymap.set("n", "[tab]8", "8gt", opts)
vim.keymap.set("n", "[tab]9", "9gt", opts)
vim.keymap.set("n", "[tab]J", "<Cmd>-tabm<CR>", opts)
vim.keymap.set("n", "[tab]K", "<Cmd>+tabm<CR>", opts)
vim.keymap.set("n", "[tab]h", "<Cmd>tabfirst<CR>", opts)
vim.keymap.set("n", "[tab]l", "<Cmd>tablast<CR>", opts)
vim.keymap.set("n", "[tab]j", "<Cmd>tabprevious<CR>", opts)
vim.keymap.set("n", "[tab]k", "<Cmd>tabnext<CR>", opts)
vim.keymap.set("n", "[tab]d", "<Cmd>tabclose<CR>", opts)
vim.keymap.set("n", "[tab]n", "<Cmd>tabnew<CR>", opts)
vim.keymap.set("n", "[t", "<Cmd>tabprevious<CR>", opts)
vim.keymap.set("n", "]t", "<Cmd>tabnext<CR>", opts)
vim.keymap.set("n", "[T", "<Cmd>tabfirst<CR>", opts)
vim.keymap.set("n", "]T", "<Cmd>tablast<CR>", opts)

-- move cursor
vim.keymap.set("n", "H", "<Nop>", opts)
vim.keymap.set("n", "L", "<Nop>", opts)
vim.keymap.set("n", "J", "<Nop>", opts)
vim.keymap.set("n", "K", "<Nop>", opts)
vim.keymap.set({ "n", "x" }, "gJ", "J", opts)
vim.keymap.set({ "n", "x" }, "gj", "J", opts)
vim.keymap.set({ "n", "x" }, "H", "5h", opts)
vim.keymap.set({ "n", "x" }, "J", "5j", opts)
vim.keymap.set({ "n", "x" }, "K", "5k", opts)
vim.keymap.set({ "n", "x" }, "L", "5l", opts)
vim.keymap.set({ "n", "x" }, "j", function() return vim.v.count > 0 and "j" or "gj" end, optsexpr)
vim.keymap.set({ "n", "x" }, "k", function() return vim.v.count > 0 and "k" or "gk" end, optsexpr)
vim.keymap.set("n", "gH", "H", opts)
vim.keymap.set("n", "gM", "M", opts)
vim.keymap.set("n", "gL", "L", opts)

-- jump cursor
vim.keymap.set('n', '<Tab>', function() return vim.v.count > 0 and '0<Bar>' or '10l' end, optsexpr)
vim.keymap.set('n', '<CR>', function() return vim.o.buftype == 'quickfix' and "<CR>" or vim.v.count > 0 and '0jzz' or '10jzz' end, optsexpr)

-- Automatically indent with i and A
vim.keymap.set("n", "i", function() return vim.fn.len(vim.fn.getline(".")) ~= 0 and "i" or '"_cc' end, optsexpr)
vim.keymap.set("n", "A", function() return vim.fn.len(vim.fn.getline(".")) ~= 0 and "A" or '"_cc' end, optsexpr)

-- toggle 0, ^
vim.keymap.set("n", "0", function() return string.match(vim.fn.getline("."):sub(0, vim.fn.col(".") - 1), "^%s+$") and "0" or "^" end, optsexpr)   
vim.keymap.set('n', '$', function() return string.match(vim.fn.getline('.'):sub(0, vim.fn.col('.')), '^%s+$') and '$' or 'g_' end, optsexpr)

-- Emacs style
vim.keymap.set("c", "<C-a>", "<Home>", { noremap = true, silent = false })
if not vim.g.vscode then
  vim.keymap.set("c", "<C-e>", "<End>", { noremap = true, silent = false })
end
vim.keymap.set("c", "<C-f>", "<right>", { noremap = true, silent = false })
vim.keymap.set("c", "<C-b>", "<left>", { noremap = true, silent = false })
vim.keymap.set("c", "<C-d>", "<DEL>", { noremap = true, silent = false })
vim.keymap.set('c', '<C-h>', '<BS>', {noremap = true, silent = true})
vim.keymap.set("c", "<C-s>", "<BS>", { noremap = true, silent = false })
vim.keymap.set("i", "<C-d>", "<Del>", { noremap = true, silent = false })
vim.keymap.set("i", "<C-s>", "<BS>", { noremap = true, silent = false })
vim.keymap.set("i", "<C-a>", "<Home>", { noremap = true, silent = false })
vim.keymap.set("i", "<C-e>", "<End>", { noremap = true, silent = false })
vim.keymap.set("i", "<C-f>", "<right>", { noremap = true, silent = false })
vim.keymap.set("i", "<C-b>", "<left>", { noremap = true, silent = false })
vim.keymap.set("i", "<C-h>", "<left>", { noremap = true, silent = false })
vim.keymap.set("i", "<C-l>", "<right>", { noremap = true, silent = false })
vim.keymap.set("i", "<C-k>", "<up>", { noremap = true, silent = false })
vim.keymap.set("i", "<C-j>", "<down>", { noremap = true, silent = false })

-- function key
vim.keymap.set({ "i", "c", "t" }, "<F1>", "<Esc><F1>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F2>", "<Esc><F2>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F3>", "<Esc><F3>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F4>", "<Esc><F4>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F5>", "<Esc><F5>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F6>", "<Esc><F6>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F7>", "<Esc><F7>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F8>", "<Esc><F8>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F9>", "<Esc><F9>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F10>", "<Esc><F10>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F11>", "<Esc><F11>", opts)
vim.keymap.set({ "i", "c", "t" }, "<F12>", "<Esc><F12>", opts)

-- Turn off highlight when searching
vim.keymap.set("n", "gq", "<Cmd>nohlsearch<CR>", opts)
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR><C-L><Esc>", opts)

-- iw to space
vim.keymap.set("n", "d<Space>", "diw", opts)
vim.keymap.set("n", "c<Space>", "ciw", opts)
vim.keymap.set("n", "y<Space>", "yiw", opts)
vim.keymap.set({ "n", "x" }, "gy", "y`>", opts)

-- yank
vim.keymap.set({ "n", "x" }, "<LocalLeader>y", '"+y', { noremap = true, silent = true })
vim.keymap.set({ "n", "x" }, "<LocalLeader>d", '"+d', { noremap = true, silent = true })
vim.keymap.set("x", "p", '"_xP', opts) -- Visual Modeペースト時にyankしない

-- paste
vim.keymap.set({ "n", "x" }, "<LocalLeader>p", '"+p', { noremap = true, silent = true })
vim.keymap.set({ "n", "x" }, "<LocalLeader>P", '"+P', { noremap = true, silent = true })

-- dot not yank
vim.keymap.set({ "n", "x" }, "<LocalLeader>x", '"_x', { noremap = true, silent = true })
vim.keymap.set({ "n", "x" }, "<LocalLeader>d", '"_d', { noremap = true, silent = true })
vim.keymap.set({ "n", "x" }, "<LocalLeader>D", '"_D', { noremap = true, silent = true })
vim.keymap.set({ "n", "x" }, "<LocalLeader>c", '"_c', { noremap = true, silent = true })
vim.keymap.set({ "n", "x" }, "<LocalLeader>C", '"_C', { noremap = true, silent = true })

-- move changes
vim.keymap.set("n", "^", "<Nop>", opts)
vim.keymap.set("n", "&", "<Nop>", opts)
vim.keymap.set("n", "^", "g;zz", opts)
vim.keymap.set("n", "&", "g,zz", opts)

-- paragraph
vim.keymap.set("n", "(", "{zz", opts)
vim.keymap.set("n", ")", "}zz", opts)
vim.keymap.set("n", "]]", "]]zz", opts)
vim.keymap.set("n", "[[", "[[zz", opts)
vim.keymap.set("n", "[]", "[]zz", opts)
vim.keymap.set("n", "][", "][zz", opts)

-- [, ]
-- error list (quickfix list)
vim.keymap.set("n", "[q", ":cprevious<CR>", opts)
vim.keymap.set("n", "]q", ":cnext<CR>", opts)
vim.keymap.set("n", "[Q", ":cfirst<CR>", opts)
vim.keymap.set("n", "]Q", ":clast<CR>", opts)
-- error list (current window list)
vim.keymap.set("n", "[l", ":lprevious<CR>", opts)
vim.keymap.set("n", "]l", ":lnext<CR>", opts)
vim.keymap.set("n", "[L", ":lfirst<CR>", opts)
vim.keymap.set("n", "]L", ":llast<CR>", opts)

-- switch quickfix/location list
vim.keymap.set("n", "<LocalLeader>q", "<Cmd>copen<CR>", opts)
vim.keymap.set("n", "<LocalLeader>l", "<Cmd>lopen<CR>", opts)

-- For search
vim.keymap.set("n", "g/", "/\\v", { noremap = true, silent = false }) -- 正規表現(very magic)
vim.keymap.set({ "n", "x" }, "g*", "*", opts)
vim.keymap.set({ "n", "x" }, "g#", "#", opts)
vim.keymap.set("n", "*", "g*N", opts)
vim.keymap.set("n", "#", "g*N", opts)
vim.keymap.set("x", "*", 'y/<C-R>"<CR>N', opts)
vim.keymap.set("x", "/", "<ESC>/\\%V", { noremap = true, silent = false }) -- \%V: Match inside the Visual area
vim.keymap.set("x", "?", "<ESC>?\\%V", { noremap = true, silent = false })

-- For replace
vim.keymap.set("n", "<LocalLeader>s", ":%s/\\<<C-r><C-w>\\>/", { noremap = true, silent = false })
vim.keymap.set("x", "<LocalLeader>s", ":s/\\%V", { noremap = true, silent = false })

-- Change encoding
vim.keymap.set("n", "<LocalLeader>eu", "<Cmd>e ++enc=utf-8<CR>", opts)
vim.keymap.set("n", "<LocalLeader>es", "<Cmd>e ++enc=cp932<CR>", opts)
vim.keymap.set("n", "<LocalLeader>ee", "<Cmd>e ++enc=euc-jp<CR>", opts)
vim.keymap.set("n", "<LocalLeader>ej", "<Cmd>e ++enc=iso-2022-jp<CR>", opts)

-- split
vim.keymap.set("n", "-", "<Cmd>split<CR>", opts)
vim.keymap.set("n", "\\", "<Cmd>vsplit<CR>", opts)

-- useful search
vim.keymap.set("n", "n", "'Nn'[v:searchforward]", { noremap = true, silent = true, expr = true })
vim.keymap.set("n", "N", "'nN'[v:searchforward]", { noremap = true, silent = true, expr = true })
vim.keymap.set("c", "<C-s>", "<HOME><Bslash><lt><END><Bslash>>", { noremap = true, silent = false })
vim.keymap.set("c", "<C-d>", "<HOME><Del><Del><END><BS><BS>", { noremap = true, silent = false })

-- command mode
vim.keymap.set("c", "<C-x>", "<C-r>=expand('%:p:h')<CR>/", { noremap = true, silent = false }) -- expand path
vim.keymap.set("c", "<C-z>", "<C-r>=expand('%:p:r')<CR>", { noremap = true, silent = false }) -- expand file (not ext)
vim.keymap.set("c", "<C-p>", "<Up>", { noremap = true, silent = false }) -- previous
vim.keymap.set("c", "<C-n>", "<Down>", { noremap = true, silent = false }) -- next
vim.keymap.set("c", "<Up>", "<C-p>", { noremap = true, silent = false })
vim.keymap.set("c", "<Down>", "<C-n>", { noremap = true, silent = false })
vim.o.cedit = "<C-c>" -- command window @ command mode

-- operator
vim.keymap.set("o", "<Space>", "iw", opts)
vim.keymap.set("o", 'a"', '2i"', opts)
vim.keymap.set("o", "a'", "2i'", opts)
vim.keymap.set("o", "a`", "2i`", opts)

-- [ts]
-- vim.keymap.set("n", "[ts]", "<Nop>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "'", "[ts]", {})
-- vim.keymap.set("n", "M", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "?", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-s>", "<Nop>", { noremap = true, silent = true })
--
-- sandwich & <spector>
-- vim.keymap.set({ "n", "x" }, "s", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set({ "n", "x" }, "S", "<Nop>", { noremap = true, silent = true })
--
-- [make]
-- vim.keymap.set("n", "m", "<Nop>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "m", "[make]", {})
--
-- [FuzzyFinder]
-- vim.keymap.set({ "n", "x" }, "z", "<Nop>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "[FuzzyFinder]", "<Nop>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "[FuzzyFinder]", "<Nop>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "z", "[FuzzyFinder]", {})
-- vim.api.nvim_set_keymap("v", "z", "[FuzzyFinder]", {})
-- vim.keymap.set("n", "Z", "<Nop>", { noremap = true, silent = true })
--
-- columnmove. use gJ
-- vim.keymap.set("n", "J", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "K", "<Nop>", { noremap = true, silent = true })

-- git, use :10 or gG or GG
-- vim.keymap.set("n", "G", "<Nop>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "G", "[git]", {})

-- not use, use RR
-- vim.keymap.set("n", "R", "<Nop>", { noremap = true, silent = true })

-- close
-- vim.keymap.set("n", "X", "<Nop>", { noremap = true, silent = true })

-- operator-replace
-- vim.keymap.set("n", "U", "<Nop>", { noremap = true, silent = true })

-- use 0, toggle statusline
-- vim.keymap.set("n", "!", "<Nop>", { noremap = true, silent = true })

-- barbar
-- vim.keymap.set("n", "@", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "#", "<Nop>", { noremap = true, silent = true })

-- milfeulle
-- vim.keymap.set("n", "<C-a>", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-g>", "<Nop>", { noremap = true, silent = true })

-- floaterm
-- vim.keymap.set("n", "<C-z>", "<Nop>", { noremap = true, silent = true })

-- treesitter
-- vim.keymap.set("n", "'", "<Nop>", { noremap = true, silent = true })

-- vim-operator-convert-case
-- vim.keymap.set("n", "~", "<Nop>", { noremap = true, silent = true })

-- nnoremap <C-m> <Nop> " = <CR>
-- noremap <CR> <Nop> " use quickfix

-- vim.keymap.set("n", "qq", function()
-- 	return vim.fn.reg_recording() == "" and "qq" or "q"
-- end, { noremap = true, expr = true })
-- vim.keymap.set("n", "q", "<Nop>", { noremap = true, silent = true })

-- vim.keymap.set("n", "gh", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gj", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gk", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gl", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gn", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gm", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "go", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gq", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gr", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gs", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gw", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "g^", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "g?", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gQ", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gR", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gT", "<Nop>", { noremap = true, silent = true })

---- remap
-- vim.keymap.set("n", "gK", "K", { noremap = true, silent = true })
-- vim.keymap.set("n", "g~", "~", { noremap = true, silent = true })
-- vim.keymap.set("n", "G@", "@", { noremap = true, silent = true })
-- vim.keymap.set("n", "g=", "=", { noremap = true, silent = true })
-- vim.keymap.set("n", "gzz", "zz", { noremap = true, silent = true })
-- vim.keymap.set("n", "g?", "?", { noremap = true, silent = true })
-- vim.keymap.set("n", "gG", "G", { noremap = true, silent = true })
-- vim.keymap.set("n", "GG", "G", { noremap = true, silent = true })
-- vim.keymap.set({ "n", "x" }, "gJ", "J", { noremap = true, silent = true })
-- vim.keymap.set("n", "q", "<Cmd>close<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "RR", "R", { noremap = true, silent = true })
-- vim.keymap.set("n", "CC", '"_C', { noremap = true, silent = true })
-- vim.keymap.set("n", "DD", "D", { noremap = true, silent = true })
-- vim.keymap.set("n", "YY", "y$", { noremap = true, silent = true })
-- vim.keymap.set("n", "X", "<Cmd>tabclose<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "gj", "j", { noremap = true, silent = true })
-- vim.keymap.set("n", "gk", "k", { noremap = true, silent = true })

-- move cursor
-- vim.keymap.set("n", "<C-s>", "<C-w>p", { noremap = true, silent = true })

-- Focus floating window with <C-w><C-w>
-- vim.keymap.set("n", "<C-w><C-w>", function()
-- 	if vim.api.nvim_win_get_config(vim.fn.win_getid()).relative ~= "" then
-- 		vim.cmd([[ wincmd p ]])
-- 		return
-- 	end
-- 	for _, winnr in ipairs(vim.fn.range(1, vim.fn.winnr("$"))) do
-- 		local winid = vim.fn.win_getid(winnr)
-- 		local conf = vim.api.nvim_win_get_config(winid)
-- 		if conf.focusable and conf.relative ~= "" then
-- 			vim.fn.win_gotoid(winid)
-- 			return
-- 		end
-- 	end
-- end, { noremap = true, silent = false })

-- nnoremap <silent> <expr> <CR>  &buftype ==# 'quickfix' ? "\<CR>" : v:count ? '0jzz' : '10jzz'

-- high-functioning undo
-- nnoremap u g-
-- nnoremap <C-r> g+

-- lambdalisue's yank for slack
-- vim.keymap.set("x", "[SubLeader]y", function()
-- 	vim.cmd([[ normal! y ]])
-- 	local content = vim.fn.getreg(vim.v.register, 1, true)
-- 	local spaces = {}
-- 	for _, v in ipairs(content) do
-- 		table.insert(spaces, string.match(v, "%s*"):len())
-- 	end
-- 	table.sort(spaces)
-- 	local leading = spaces[1]
-- 	local content_new = {}
-- 	for _, v in ipairs(content) do
-- 		table.insert(content_new, string.sub(v, leading + 1))
-- 	end
-- 	vim.fn.setreg(vim.v.register, content_new, vim.fn.getregtype(vim.v.register))
-- end, { noremap = true, silent = true })

-- local function is_normal_buffer()
-- 	if
-- 		vim.o.ft == "qf"
-- 		or vim.o.ft == "Vista"
-- 		or vim.o.ft == "NvimTree"
-- 		or vim.o.ft == "coc-explorer"
-- 		or vim.o.ft == "diff"
-- 	then
-- 		return false
-- 	end
-- 	if vim.fn.empty(vim.o.buftype) or vim.o.buftype == "terminal" then
-- 		return true
-- 	end
-- 	return true
-- end

-- tags jump
-- vim.keymap.set("n", "<C-]>", "g<C-]>", { noremap = true, silent = true })

-- goto
-- vim.keymap.set("n", "gf", "gF", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-w>f", "<C-w>F", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-w>gf", "<C-w>F", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-w><C-f>", "<C-w>F", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-w>g<C-f>", "<C-w>F", { noremap = true, silent = true })

-- split goto
-- vim.keymap.set("n", "-gf", "<Cmd>split<CR>gF", { noremap = true, silent = true })
-- vim.keymap.set("n", "<Bar>gf", "<Cmd>vsplit<CR>gF", { noremap = true, silent = true })
-- vim.keymap.set("n", "-<C-]>", "<Cmd>split<CR>g<C-]>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<Bar><C-]>", "<Cmd>vsplit<CR>g<C-]>", { noremap = true, silent = true })

-- terminal mode
-- vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = false })

-- completion
-- nvim-cmp
-- vim.keymap.set('i', '<CR>', function() return vim.fn.pumvisible() and "<C-y>" or "<CR>" end,
--                {noremap = true, silent = true, expr = true})
-- vim.keymap.set('i', '<Down>', function() return vim.fn.pumvisible() and "<C-n>" or "<Down>" end,
--                {noremap = true, silent = true, expr = true})
-- vim.keymap.set('i', '<Up>', function() return vim.fn.pumvisible() and "<C-p>" or "<Up>" end,
--                {noremap = true, silent = true, expr = true})
-- vim.keymap.set('i', '<PageDown>', function()
--   return vim.fn.pumvisible() and "<PageDown><C-p><C-n>" or "<PageDown>"
-- end, {noremap = true, silent = true, expr = true})
-- vim.keymap.set('i', '<PageUp>',
--                function() return vim.fn.pumvisible() and "<PageUp><C-p><C-n>" or "<PageUp>" end,
--                {noremap = true, silent = true, expr = true})
-- vim.keymap.set('i', '<Tab>', function() return vim.fn.pumvisible() and "<C-n>" or "<Tab>" end,
--                {noremap = true, silent = true, expr = true})
-- vim.keymap.set('i', '<S-Tab>', function() return vim.fn.pumvisible() and "<C-p>" or "<S-Tab>" end,
--                {noremap = true, silent = true, expr = true})

-- fold
-- nnoremap Zo zo " -> use l
-- vim.keymap.set("n", "gzO", "zO", { noremap = true, silent = true })
-- vim.keymap.set("n", "gzc", "zc", { noremap = true, silent = true })
-- vim.keymap.set("n", "gzC", "zC", { noremap = true, silent = true })
-- vim.keymap.set("n", "gzR", "zR", { noremap = true, silent = true })
-- vim.keymap.set("n", "gzM", "zM", { noremap = true, silent = true })
-- vim.keymap.set("n", "gza", "za", { noremap = true, silent = true })
-- vim.keymap.set("n", "gzA", "zA", { noremap = true, silent = true })
-- vim.keymap.set("n", "gz<Space>", "zMzvzz", { noremap = true, silent = true })

-- control code
-- vim.keymap.set("i", "<C-q>", "<C-r>=nr2char(0x)<Left>", { noremap = true, silent = true })
-- vim.keymap.set("x", ".", ":normal! .<CR>", { noremap = true, silent = true })
-- vim.keymap.set(
-- 	"x",
-- 	"@",
-- 	":<C-u>execute \":'<,'>normal! @\" . nr2char(getchar())<CR>",
-- 	{ noremap = true, silent = true }
-- )
