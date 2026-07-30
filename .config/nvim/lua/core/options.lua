-- https://neovim.io/doc/user/options.html

vim.opt.guifont = { "UDEV Gothic 35NFLG" }

-- Encoding
vim.o.encoding = "utf-8"
vim.o.fileencodings = "utf-8,iso-2022-jp,euc-jp,sjis"

-- History / Session
vim.o.shada = "'50,<1000,s100,\"1000,!"
vim.o.shadafile = vim.fn.stdpath("state") .. "/shada/main.shada"
vim.o.history = 10000
vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,globals"

-- Timing
vim.o.timeout = true
vim.o.timeoutlen = 750
vim.o.ttimeoutlen = 10
vim.o.updatetime = 2000

-- Tab / Indent
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 0
vim.o.expandtab = true
vim.o.breakindent = true
vim.o.list = true
vim.o.listchars = "tab:» "

-- Insert
vim.o.backspace = "indent,eol,start"
vim.o.formatoptions = vim.o.formatoptions .. "m"
vim.o.fixendofline = true

-- Search
vim.o.wrapscan = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.inccommand = "split"

-- Command line
vim.o.wildmenu = true
vim.o.wildmode = "longest,list,full"

-- Window
vim.o.splitbelow = true
vim.o.splitright = true

-- Jump
vim.o.jumpoptions = "stack"
vim.o.mousescroll = "ver:0,hor:0"

-- Completion
vim.o.complete = vim.o.complete .. ",k"
vim.o.completeopt = "menuone,noselect,noinsert"
vim.o.pumblend = 30

-- File
vim.o.autoread = true
vim.o.swapfile = false
vim.o.hidden = true
vim.o.modeline = false

-- Backup
vim.o.backup = true
vim.o.backupdir = vim.fn.stdpath("state") .. "/backup/"
vim.fn.mkdir(vim.o.backupdir, "p")
vim.o.backupskip = ""

-- Swap
vim.o.directory = vim.fn.stdpath("state") .. "/swap/"
vim.fn.mkdir(vim.o.directory, "p")
vim.o.updatecount = 100

-- Undo
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath("state") .. "/undo/"
vim.fn.mkdir(vim.o.undodir, "p")

-- Clipboard
-- Windows Terminal over SSH: 書き込みは OSC52、読み出しは無名レジスタ。
-- ponytail: paste に osc52.paste を使うと WT が返事を返さないので
-- "waiting for osc 52 response" で固まる。read は端末に聞かない。
local osc52 = require("vim.ui.clipboard.osc52")
local function paste()
  return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
end
vim.g.clipboard = {
  name = "OSC52",
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = { ["+"] = paste, ["*"] = paste },
}
-- clipboard は空のまま。y のコピーは autocmds.lua の TextYankPost が担当。
-- Windows からの貼り付けは Ctrl+Shift+V（端末の bracketed paste）で、"+p ではない

-- Bells
vim.o.errorbells = false
vim.o.visualbell = false

-- Tags
vim.opt.tags = "./tags," .. vim.go.tags

-- Quickfix
vim.o.switchbuf = "useopen,uselast"

-- Spell
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

-- Diff
vim.o.diffopt = vim.o.diffopt .. ",vertical,internal,algorithm:patience,iwhite,indent-heuristic"

-- Increment (unsigned numbers support)
vim.opt.nrformats:append("unsigned")

-- Display
vim.o.number = true
vim.o.relativenumber = false
vim.o.cursorline = true
vim.o.signcolumn = "yes"
vim.o.wrap = true
vim.o.scrolloff = 4
vim.o.sidescrolloff = 8

-- Colors
vim.o.termguicolors = true

-- Shell: load zshenv for PATH
vim.o.shellcmdflag = "-ic"

-- Providers: disable unused ones to suppress warnings
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- Python provider: pynvim installed via `uv tool install pynvim`
vim.g.python3_host_prog = vim.fn.exepath("pynvim-python")

-- Disable netrw (oil.nvim is the file explorer)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- No tabline: tmux's window list is the only row of tabs on screen.
vim.o.showtabline = 0

-- No statusline either. The cmdline row is already on screen, so put the same
-- information there instead of spending a second row on it.
vim.o.laststatus = 0
vim.o.showmode = true  -- -- INSERT -- in the cmdline
vim.o.ruler = true     -- line:col at the right of the cmdline
vim.o.showcmd = true   -- pending keys / visual selection size
-- Filename on demand: <C-g>. Git state: lazygit (<Leader>gl) or the tmux bar.

-- Without a statusline, splits need a visible seam.
vim.opt.fillchars:append({ horiz = "─", horizup = "┴", horizdown = "┬", vert = "│" })
