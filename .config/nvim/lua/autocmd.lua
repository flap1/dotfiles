-- disable continuation of comments to the next line
vim.cmd(
[[
  autocmd FileType * set fo-=c fo-=r fo-=o
]]
)

-- Packer.nvim
vim.cmd(
[[
augroup packer_user_config
  autocmd!
  autocmd BufWritePost ~/.config/nvim/lua/plugins/*.lua,~/.config/nvim/lua/plugins/config/*.lua,~/.config/nvim/vim/plugins/config/*.vim source <afile> | PackerCompile
augroup END
]]
)

