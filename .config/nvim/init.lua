require 'base'
require 'options'
require 'display'

if vim.g.vscode then
	require 'vscode-neovim/mappings'
else
	require 'plugins'
	require 'autocmd'
	require 'mappings'
	vim.defer_fn(function()
		require("command")
	end, 50)

	if vim.fn.filereadable(vim.fn.expand("~/.nvim_local_init.lua")) ~= 0 then
		dofile(vim.fn.expand("~/.nvim_local_init.lua"))
	end
end
