require 'base'
require 'options'
require 'display'
require 'plugins'
require 'autocmd'
require 'mappings'
if vim.g.vscode then
  require 'vscode-neovim/mappings'
end
