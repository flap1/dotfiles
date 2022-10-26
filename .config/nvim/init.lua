require 'base'
require 'options'
require 'display'
require 'plugins'
require 'autocmd'
require 'mappings'
if vim.g.vscode then
  require 'vscode-neovim/mappings'
end
vim.defer_fn(function()
	require("command")
end, 50)
if vim.fn.filereadable(vim.fn.expand("~/.nvim_local_init.lua")) ~= 0 then
	dofile(vim.fn.expand("~/.nvim_local_init.lua"))
end
