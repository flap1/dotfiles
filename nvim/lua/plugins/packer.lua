local _packer = {}

vim.api.nvim_exec(
[[
augroup vimrc_packer
  autocmd!
  autocmd BufWritePost .config/nvim/lua/plugins/*.lua .config/nvim/lua/plugins/config/*.lua .config/nvim/vim/plugins/config/*.vim PackerCompile
augroup END
]],
true)

local function get_table_size(args) 
  local count = 0
  for _, __ in pairs(args) do
    count = count + 1
  end
  return count
end

_packer.count_plugins = function() return get_table_size(_G.packer_plugins) end

return _packer
