require("base")
require("options")
require("display")
require("plugins")
require("mappings")
require("autocmd")
if vim.g.vscode then
  require("vscode-neovim/mappings")
end
vim.defer_fn(function()
  require("command")
end, 50)
