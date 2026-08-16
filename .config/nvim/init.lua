-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local function git(args)
    local out = vim.fn.system(args)
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({ { "lazy.nvim: " .. out, "ErrorMsg" } }, true, {})
      error("lazy.nvim bootstrap failed")
    end
  end
  git({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  git({
    "git", "-C", lazypath, "checkout", "--quiet",
    "306a05526ada86a7b30af95c5cc81ffba93fef97",
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("core.options")
require("core.keymaps")
require("core.autocmds")

require("lazy").setup("plugins", {
  defaults = { lazy = true },
  -- Only used while lazy.nvim installs plugins, before base16 is configured.
  -- A built-in scheme so it can never fail.
  install = { colorscheme = { "habamax" } },
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

local local_init = vim.fn.stdpath("config") .. "/lua/local.lua"
if vim.fn.filereadable(local_init) ~= 0 then
  dofile(local_init)
end
