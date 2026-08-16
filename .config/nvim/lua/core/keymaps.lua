-- Keymaps, rebuilt from zero.
--
-- Rules this file obeys. If a binding cannot be justified by one of them,
-- it does not belong here.
--
--   1. Frequency buys keys. Many times a minute → unprefixed or one modifier.
--      Many times an hour → <Leader> + 1-2 keys. Rarer than that → no binding;
--      type the `:command`.
--   2. One noun per namespace, named by its initial letter. Nothing else may
--      squat there.
--        <Leader>b buffer   <Leader>f find    <Leader>g git
--        <Leader>c code     <Leader>a ai
--      <LocalLeader> has exactly one job: register operations.
--   3. [ and ] are "previous/next of a kind". Every navigable kind uses them.
--   4. g is goto. LSP *navigation* lives there; LSP *actions* live in <Leader>c.
--   5. <C-…> is windows. <M-…> is for things that must also work from insert
--      or terminal mode.
--   6. A vim default is only overridden when the replacement is strictly
--      better. "Slightly more convenient for me in 2019" is not strictly better.
--   7. Zero bindings referencing a plugin or command that no longer exists.
--
-- Deliberately NOT bound (was bound before, removed on purpose):
--   H/L→5h/5l, 0/$ toggling, <CR>→10jzz, i/A auto-indent on empty lines,
--   ^/& change-list jumps, (/) and [[/]] recentering, gq, gx, gH/gM/gL,
--   <C-x>/<C-z> indent, tab navigation (tmux windows replace tabs),
--   ;1-;9 window numbers, F-key escapes, encoding shortcuts.
--   Config reload: use :restart (Neovim 0.12).

local opts = { noremap = true, silent = true }
local expr = { noremap = true, expr = true, silent = true }
local loud = { noremap = true, silent = false }

-- ─────────────────────────────────────────────────────────── safety ──

-- Defaults that only ever fire by accident.
vim.keymap.set("n", "ZZ", "<Nop>", opts)
vim.keymap.set("n", "ZQ", "<Nop>", opts)
vim.keymap.set("n", "Q", "<Nop>", opts)
vim.keymap.set("n", "<C-c>", "<Nop>", opts)
vim.o.cedit = "<C-c>" -- <C-c> opens the cmdline window instead

-- ──────────────────────────────────────────────────────────── modes ──

vim.keymap.set("i", "jk", "<Esc>", loud)
vim.keymap.set("i", "ｊｋ", "<Esc>", opts) -- same, with the IME still on
vim.keymap.set("t", "jk", "<C-\\><C-n>", loud)

-- Normal-mode commands that fire while the IME is still in Japanese mode.
for kana, latin in pairs({ ["あ"] = "a", ["い"] = "i", ["う"] = "u", ["お"] = "o" }) do
  vim.keymap.set("n", kana, latin, opts)
end

-- ─────────────────────────────────────────────────────── navigation ──

-- Move by screen line, unless a count was given (5j should still be 5 real lines).
vim.keymap.set({ "n", "x" }, "j", function() return vim.v.count > 0 and "j" or "gj" end, expr)
vim.keymap.set({ "n", "x" }, "k", function() return vim.v.count > 0 and "k" or "gk" end, expr)

-- Windows. tmux owns pane navigation (Alt+hjkl); these are nvim's own splits.
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)
vim.keymap.set("n", "\\", "<Cmd>vsplit<CR>", opts) -- `-` belongs to oil
vim.keymap.set({ "n", "t" }, "<M-o>", "<C-w>o", opts)

-- Previous / next of a kind. Plugins add to this same family:
--   ]h hunk (gitsigns)   ]d diagnostic (lsp)
vim.keymap.set("n", "[b", "<Cmd>bprevious<CR>", opts)
vim.keymap.set("n", "]b", "<Cmd>bnext<CR>", opts)
vim.keymap.set("n", "[q", "<Cmd>cprevious<CR>", opts)
vim.keymap.set("n", "]q", "<Cmd>cnext<CR>", opts)

-- ─────────────────────────────────────────────────────────── search ──

-- n/N always mean forward/backward, whichever direction the search started in.
vim.keymap.set("n", "n", "'Nn'[v:searchforward]", expr)
vim.keymap.set("n", "N", "'nN'[v:searchforward]", expr)

-- Very magic by default: one less backslash in every regex.
vim.keymap.set("n", "/", "/\\v", loud)

-- Search the word under the cursor without jumping off it.
vim.keymap.set("n", "*", "g*N", opts)
vim.keymap.set("n", "#", "g#N", opts)
vim.keymap.set("x", "*", 'y/<C-R>"<CR>N', opts)

vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR><C-L><Esc>", opts)

-- ──────────────────────────────────────────────────────── text ops ──

-- <Space> as a text object means d<Space>, c<Space>, y<Space> all mean "…iw".
vim.keymap.set("o", "<Space>", "iw", opts)
-- a" normally leaves the trailing space; 2i" does not.
vim.keymap.set("o", 'a"', '2i"', opts)
vim.keymap.set("o", "a'", "2i'", opts)
vim.keymap.set("o", "a`", "2i`", opts)

-- Pasting over a selection should not clobber the register.
vim.keymap.set("x", "p", '"_xP', opts)

-- Substitute the word under the cursor.
vim.keymap.set("n", "<Leader>s", ":%s/\\<<C-r><C-w>\\>/", loud)

-- ────────────────────────── <LocalLeader>: register operations only ──

-- Yank/paste through register 0, which survives an intervening delete.
vim.keymap.set({ "n", "x" }, "<LocalLeader>y", '"0y', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>p", '"0p', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>P", '"0P', opts)
-- Delete into the void register.
vim.keymap.set({ "n", "x" }, "<LocalLeader>d", '"_d', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>D", '"_D', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>c", '"_c', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>C", '"_C', opts)
vim.keymap.set({ "n", "x" }, "<LocalLeader>x", '"_x', opts)

-- ────────────────────────────────────────────────── files / buffers ──

vim.keymap.set("n", "<Leader>w", "<Cmd>write<CR>", opts)
vim.keymap.set("n", "<Leader>W", "<Cmd>wall<CR>", opts)
vim.keymap.set("n", "<Leader>q", "<Cmd>quit<CR>", opts)
vim.keymap.set("n", "<Leader>Q", "<Cmd>qall<CR>", opts)
-- Save without leaving insert mode.
vim.keymap.set("i", "<M-w>", "<Esc><Cmd>write<CR>", opts)

-- <Leader>b* buffer verbs are next to snacks.bufdelete in plugins/ai.lua.

-- ───────────────────────────────────────── readline keys where they belong ──
-- Insert and command line only. <C-n>/<C-p> are left alone in insert mode
-- because blink.cmp owns them there.
vim.keymap.set({ "i", "c", "t" }, "<C-b>", "<Left>", loud)
vim.keymap.set({ "i", "c", "t" }, "<C-f>", "<Right>", loud)
vim.keymap.set({ "i", "c", "t" }, "<C-a>", "<Home>", loud)
vim.keymap.set({ "i", "c", "t" }, "<C-e>", "<End>", loud)
vim.keymap.set({ "i", "c", "t" }, "<C-d>", "<Del>", loud)
vim.keymap.set({ "i", "c", "t" }, "<C-h>", "<BS>", loud)
vim.keymap.set("c", "<C-p>", "<Up>", loud)
vim.keymap.set("c", "<C-n>", "<Down>", loud)

-- Insert the current file's directory / path while typing a command.
vim.keymap.set("c", "<C-x>", "<C-r>=expand('%:p:h')<CR>/", loud)
