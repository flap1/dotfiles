-- <BS>: backspace
-- <CR>: Enter
-- <Del>: Delete
-- <EOL>: End of Line
-- <Bar>: |
-- https://vim-jp.org/vimdoc-en/options.html
-- https://vim-jp.org/vimdoc-ja/options.html
-- https://neovim.io/doc/user/options.html

vim.opt.guifont = { "UDEV Gothic 35NFLG" }

vim.g.mapleader = " " -- set mapleader(<Leader>)
vim.g.maplocalleader = "," -- set maplocalleader(<LocalLeader>)

vim.o.shada = "'50,<1000,s100,\"1000,!" -- set the number of lines stored in a register and add ! for YankRing
vim.o.shadafile = vim.fn.stdpath("state") .. "/shada/main.shada" -- set shada file path

vim.fn.mkdir(vim.fn.fnamemodify(vim.fn.expand(vim.g.viminfofile), ":h"), "p") -- viminfofile: viminfofile path

vim.o.shellslash = true -- set \ to / in the file path in Windows

vim.o.complete = vim.o.complete .. ",k" -- add dictionary file to input completion
vim.o.completeopt = "menuone,noselect,noinsert" -- option of input completion
-- menuone: Use the pop-up menu even when there is only one candidate.
-- noselect: Forcing the user to make a selection from a menu without automatic selection
-- noinsert: Any matching text will not be inserted unless the user selects it from the menu

vim.o.history = 10000 -- default: 50, max: 10000, Number of stored history of commands and previously used search patterns
vim.o.timeout = true -- enable time limit for suggested searches(ms)
vim.o.timeoutlen = 750 -- default: 1000ms, Time to wait for key code or mapped key sequence to complete
vim.o.ttimeoutlen = 10 -- default: 100ms, Time to wait for only mapped key sequence to complete
vim.o.updatetime = 2000 -- default: 4000ms, If this many milliseconds nothing is typed the swap file will be written to disk

vim.o.jumpoptions = "stack" -- Make the jumplist behave like the tagstack or like a web browser
vim.o.mousescroll = "ver:0,hor:0" -- default: ver:3,hor:6, disable mouse scrolling by using a count of 0
-- "hor" controls horizontal scrolling and "ver" controls vertical scrolling

-- Tab
vim.o.tabstop = 2 -- default: 8, Number of spaces that a <Tab> in the file counts for
vim.o.shiftwidth = 2 -- default: 8, Number of spaces to use for each step of (auto)indent used for 'cindent', >>, <<, etc
vim.o.softtabstop = 0 -- default: 0, Number of spaces that a <Tab> counts for while performing editing operations. It also affects <BS>
vim.o.expandtab = true -- Convert tabs to spaces
-- vim.o.autoindent = "smartindent"  -- default: false, autoindent
vim.o.list = true -- default: false, list mode: display tab char
vim.o.listchars = "tab:» " --  -- Characters used for display in 'list mode' and :list command

-- Insert
vim.o.backspace = "indent,eol,start" -- Influences the working of <BS>, <Del>, CTRL-W and CTRL-U in Insert mode
vim.o.formatoptions = vim.o.formatoptions .. "m" -- add multi byte, sequence of letters which describes how automatic formatting is to be done
-- https://github.com/vim-jp/issues/issues/152 use nofixeol
-- vim.o.binary noeol=true
vim.o.fixendofline = true -- When writing a file and this option is on, <EOL> at the end of file will be restored if missing
-- vim.o.formatoptions=vim.o.formatoptions .. "j" -- Delete comment character when joining commented lines

-- vim.o.iskeyword="48-57,192-255" -- be set to all non-blank printable characters except '*', '"' and '|'

-- Command
vim.o.wildmenu = true -- enhaance command-line completion
vim.o.wildmode = "longest,list,full" -- completion mode
-- longest: Complete till longest common string
-- list: When more than one match, list all matches
-- full: Complete the next full match

-- Search
vim.o.wrapscan = true -- Return to the top after searching to the end
-- vim.o.nowrapscan -- Doesn't return to the top after searching to the end
vim.o.ignorecase = true -- Ignore case in search patterns
vim.o.smartcase = true -- Override the 'ignorecase' option if the search pattern contains upper case characters
vim.o.incsearch = true -- While typing a search command, show where the pattern, as it was typed so far, matches
vim.o.hlsearch = true -- When there is a previous search pattern, highlight all its matches

-- Window
vim.o.splitbelow = true -- splitting a window will put the new window below the current one
vim.o.splitright = true -- splitting a window will put the new window right of the current one

-- File
vim.o.autoread = true -- When a file has been detected to have been changed outside of Vim and it has not been changed inside of Vim
vim.o.swapfile = false -- Use a swapfile for the buffer
vim.o.hidden = true -- When off a buffer is unloaded when it is abandoned.  When on a buffer becomes hidden when it is abandoned

---- backup
-- vim.o.backup=false   -- Make a backup before overwriting a file
vim.o.backup = true
vim.o.backupdir = vim.fn.stdpath("state") .. "/backup/" -- List of directories for the backup file, separated with commas
vim.fn.mkdir(vim.o.backupdir, "p") -- Make backup directory
-- vim.o.backupext = string.gsub(vim.o.backupext, "[vimbackup]", "") -- String which is appended to a file name to make the name of the backup file
vim.o.backupskip = "" -- A list of skip file patterns

---- swap
vim.o.directory = vim.fn.stdpath("state") .. "/swap/" -- List of directory names for the swap file, separated with commas
vim.fn.mkdir(vim.o.directory, "p") -- Make swap directory
vim.o.updatecount = 100 -- default: 200, After typing 100 characters the swap file will be written to disk

---- undo
vim.o.undofile = true -- Vim automatically saves undo history to an undo file when writing a buffer to a file, and restores undo history from the same file on buffer read.
vim.o.undodir = vim.fn.stdpath("state") .. "/undo/" -- List of directory names for undo files, separated with commas
vim.fn.mkdir(vim.o.undodir, "p") -- Make undo directory
vim.o.modeline = false -- If 'modeline' is off or 'modelines' is zero no lines are checked
-- vim.o.autochdir = true -- Vim will change the current working directory whenever you open a file, switch buffers, delete a buffer or open/close a window

-- clipboard
if vim.fn.has("clipboard") == 1 then
  vim.o.clipboard = "unnamedplus,unnamed"
  -- unnamedplus: save to + register(OS clipboard)
  -- unnamed: save to * register
end

-- beep sound
vim.o.errorbells = false -- Ring the bell (beep or screen flash) for error messages
vim.o.visualbell = false -- Use visual bell instead of beeping.

-- tags
vim.opt.tags = "./tags," .. vim.go.tags

-- session
vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,globals"
-- buffers: hidden and unloaded buffers, not just those in windows
-- curdir: the current directory
-- tabpages: all tab pages; without this only the current tab page is restored, so that you can make a session for each tab page separately

-- quickfix
vim.o.switchbuf = "useopen,uselast"
-- useopen: If included, jump to the first open window that contains the specified buffer (if there is one).
-- uselast: If included, jump to the previously used window when jumping to errors with quickfix commands

-- smart indent for long line
vim.o.breakindent = true -- Every wrapped line will continue visually indented (same amount of space as the beginning of that line)

vim.o.pumblend = 30 -- 0-100, Display pop-up menus used for completion, etc. semi-transparently
-- vim.o.wildoptions = vim.o.wildoptions .. ",pum" -- default: pum,tagfile
vim.o.spelllang = "en,cjk" -- Spellchecking will be done for these languages
vim.o.inccommand = "split" -- Get a live preview of both searches and complex find and replace
vim.g.vimsyn_embed = "l" -- This option allows users to select what, if any, types of embedded script highlighting they wish to have
-- l: lua

-- diff
vim.o.diffopt = vim.o.diffopt .. ",vertical,internal,algorithm:patience,iwhite,indent-heuristic" -- Option settings for diff mode

-- increment
vim.opt.nrformats:append("unsigned") -- This defines what bases Vim will consider for numbers when using the CTRL-A and CTRL-X commands for adding to and subtracting from a number respectively
-- unsigned: If included, numbers are recognized as unsigned

vim.g.python3_host_prog = "~/.pyenv/shims/python3"

-- load zshenv
vim.o.shellcmdflag = "-ic"

-- load local settings
vim.g.autosource_conf_names = { '.exrc', '.exrc.lua' }

-- spell
vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }
