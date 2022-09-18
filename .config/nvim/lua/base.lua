local env = vim.env
local g = vim.g
local o = vim.o
local cmd = vim.cmd

-- Language
if vim.fn.has("unix") == 1 then
	env.LANG = "en_US.UTF-8"
else
	env.LANG = "en"
end
cmd([[ "language " .. os.getenv("LANG") ]])
o.langmenu = os.getenv("LANG")

-- Encoding
o.encoding = "utf-8" -- set vim's internal char encoding
o.fileencodings = "ucs-bom,utf-8,euc-jp,iso-2022-jp,cp932,sjis,latin1" -- automatic identification of file encoding
o.fileformats = "unix,dos,mac" -- automatic recognition of line feed codes

-- Skip some remote provider loading
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_python_provider = 0
g.loaded_pythonx_provider = 0
g.loaded_ruby_provider = 0

-- Improve plugin performance 
g.load_black = 1 

-- Disable built-in plugins
local disabled_built_ins = {
    '2html_plugin',
    'fzf',
    'getscript',
    'getscriptPlugin',
    'gtags',
    'gtags_cscope',
    'gzip',
    'logiPat',
    'man',
    'matchit',
    'matchparen',
    'netrwFileHandlers',
    'netrwPlugin',
    'netrwSettings',
    'remote_plugins',
    'rplugin',
    'rrhelper',
    'shada_plugin',
    'spec',
    'spellfile_plugin',
    'tar',
    'tarPlugin',
    'tutor_mode_plugin',
    'vimball',
    'vimballPlugin',
    'zip',
    'zipPlugin'
}
for i = 1, #disabled_built_ins do
  g['loaded_' .. disabled_built_ins[i]] = 1
end

