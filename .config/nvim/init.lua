-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("core.options")
require("core.keymaps")
require("core.autocmds")

if vim.g.vscode then
  require("vscode-neovim.mappings")
else
  require("lazy").setup("plugins", {
    defaults = { lazy = true },
    install = { colorscheme = { "tokyonight" } },
    checker = { enabled = false },
    rocks = { enabled = false },
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip", "matchit", "matchparen", "netrwPlugin",
          "tarPlugin", "tohtml", "tutor", "zipPlugin",
        },
      },
    },
    ui = { border = "rounded" },
  })

  -- Load local overrides if present
  local local_init = vim.fn.expand("~/.nvim_local_init.lua")
  if vim.fn.filereadable(local_init) ~= 0 then
    dofile(local_init)
  end
end
