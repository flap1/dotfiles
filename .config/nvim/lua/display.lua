-- nvim color
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1 -- enable true color

vim.o.synmaxcol = 200 -- Maximum column in which to search for syntax items
-- ColorScheme
vim.cmd([[ syntax enable ]]) -- switches on syntax highlighting
vim.o.t_Co = 256 -- number of colors
vim.o.background = "dark" -- dark / light

-- true color support
vim.g.colorterm = os.getenv("COLORTERM")
if vim.fn.exists("+termguicolors") == 1 then
	vim.o.termguicolors = true
end

-- colorscheme pluginconfig -> colorscheme
vim.o.cursorline = false -- Highlight the text line of the cursor

vim.o.display = "lastline" -- Change the way text is displayed, when lastline is included, as much as possible of the last line in a window will be displayed
vim.o.showmode = false -- Show mode(insert, normal, visual)
vim.o.showmatch = true -- When a ")" is inserted, briefly jump to the matching "("
vim.o.matchtime = 1 -- default: 5ms, Second to show the matching paren
vim.o.showcmd = true -- Show command
vim.o.number = true -- Print the line number in front of each line
vim.o.relativenumber = true -- Show the line number relative to the line with the cursor in front of each line
vim.o.wrap = true -- Lines longer than the width of the window will wrap and displaying continues on the next line
vim.o.title = false -- The title of the window will be set to the value of 'titlestring'
vim.o.scrolloff = 5 -- Minimal number of screen lines to keep above and below the cursor
vim.o.sidescrolloff = 5 -- The minimal number of screen columns to keep to the left and to the right of the cursor if 'nowrap' is set
vim.o.pumheight = 10 -- Determines the maximum number of items to show in the popup menu for Insert mode completion

-- folding
-- vim.o.foldmethod="marker"
vim.o.foldmethod = "manual" -- 折り畳みは手動で設定
vim.o.foldlevel = 1 -- 折り畳みの深さ
vim.o.foldlevelstart = 99 -- 編集開始時に常に全ての折り畳みを開いておく
vim.w.foldcolumn = "0:"

-- Cursor style
vim.o.guicursor = "n-v-c-sm:block-Cursor/lCursor-blinkon0,i-ci-ve:ver25-Cursor/lCursor,r-cr-o:hor20-Cursor/lCursor"

vim.o.cursorlineopt = "number" -- Comma-separated list of settings for how 'cursorline' is displayed. number: Highlight the line number of the cursor with CursorLineNr hl-CursorLineNr

-- ステータスライン関連
-- vim.o.laststatus = 2 -- The value of this option influences when the last window will have a status line
vim.o.shortmess = "aItToOF" -- This option helps to avoid all the hit-enter prompts caused by file messages

vim.o.cmdheight = 1 -- default: 1, Number of screen lines to use for the command-line
