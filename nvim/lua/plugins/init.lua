local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
  vim.api.nvim_command("silent !git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

vim.cmd([[ packadd packer.nvim ]])
require "plugins/packer"

return require("packer").startup(function()
  use {'wbthomason/packer.nvim', opt = true}

  -- Basic Library --------------------------------
  ---- Vim
  use { "tpope/vim-repeat", event = "VimEnter" }
  ---- Lua
  use { "nvim-lua/popup.nvim", module = "popup" }
  use { "nvim-lua/plenary.nvim" } -- do not lazy load
  use { "kkharji/sqlite.lua", module = "sqlite" }
  use { "MunifTanjim/nui.nvim", module = "nui" }

  -- Notify Library ------------------------------- 
  use { "rcarriga/nvim-notify", module = "notify" }

  -- Colorschme Library ---------------------------
  local colorscheme = "tokyonight.nvim"
  use { 
    "folke/tokyonight.nvim",
    event = { "VimEnter", "ColorSchemePre" },
    config = function ()
      require "plugins/config/tokyonight"
    end,
  }
  -- local colorscheme = "nightfox.nvim"
  -- use { 
  --   "EdenEast/nightfox.nvim",
  --   event = { "VimEnter", "ColorSchemePre" },
  --   config = function ()
  --     require "plugins/config/nightfox"
  --   end,
  -- }

  -- Font Library ---------------------------------
  if not os.getenv("DISABLE_DEVICONS") or os.getenv("DISABLE_DEVICONS") == "false" then
    use { "kyazdani42/nvim-web-devicons", after = colorscheme }
  end

  -- LSP & Completion ----------------------------
  ---- Auto Completion
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      { "L3MON4D3/LuaSnip", opt = true, event = "VimEnter" },
      { "windwp/nvim-autopairs", opt = true, event = "VimEnter" },
    },
    after = { "LuaSnip", "nvim-autopairs" },
    config = function()
      require("plugins/config/nvim-cmp")
    end,
  }
  use {
    "onsails/lspkind-nvim",
    module = "lspkind",
    config = function()
      require "plugins/config/lspkind-nvim"
    end,
  }
  use { "hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp" }
  use { "hrsh7th/cmp-buffer", after = "nvim-cmp" }
  use { "hrsh7th/cmp-path", after = "nvim-cmp" }
  use { "hrsh7th/cmp-cmdline", after = "nvim-cmp" }
  use { "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" }
  use { "hrsh7th/cmp-emoji", after = "nvim-cmp" }
  use { "hrsh7th/cmp-calc", after = "nvim-cmp" }
  use { "f3fora/cmp-spell", after = "nvim-cmp" }
  use { "yutkat/cmp-mocword", after = "nvim-cmp" }
  use { "uga-rosa/cmp-dictionary",
    after = "nvim-cmp",
    config = function()
      require "plugins/config/cmp-dictionary"
    end,
  }
  use { "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" }
  use{
    "tzachar/cmp-tabnine",
    run = "./install.sh",
    after = "nvim-cmp",
  }
  use({ "ray-x/cmp-treesitter", after = "nvim-cmp" })
  use({ "lukas-reineke/cmp-rg", after = "nvim-cmp" })
  use({ "lukas-reineke/cmp-under-comparator", module = "cmp-under-comparator" })

  ---- Language Server Protocol(LSP)
  use({
    "neovim/nvim-lspconfig",
    event = { "VimEnter" },
    config = function()
      require("plugins/config/nvim-lspconfig")
    end,
  })
  use({
    "williamboman/nvim-lsp-installer",
    after = { "nvim-lspconfig", "cmp-nvim-lsp" },
    config = function()
      require("plugins/config/nvim-lsp-installer")
    end,
  })

  ---- LSP's UI
  use({
    "kkharji/lspsaga.nvim",
    after = "nvim-lsp-installer",
    config = function()
      require("plugins/config/lspsaga")
    end,
  })
  use {"folke/lsp-colors.nvim", module = "lsp-colors", }
  use {
    "folke/trouble.nvim",
    after = { "nvim-lsp-installer" },
    config = function()
      require("plugins/config/trouble")
    end,
  }
  use {
    "j-hui/fidget.nvim",
    after = "nvim-lsp-installer",
    config = function()
      require("plugins/config/fidget")
    end,
  }

  -- Syntax --------------------------------------
  use {
    "xiyaowong/nvim-cursorword",
    after = colorscheme,
    config = function()
      require("plugins/config/nvim-cursorword")
    end,
  }
  use {
    "norcalli/nvim-colorizer.lua",
    event = "VimEnter",
    config = function()
      require("colorizer").setup()
    end,
  }
  use {
    "t9md/vim-quickhl",
    event = "VimEnter",
    config = function()
      vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-quickhl.vim")
    end,
  }
  
  -- Git -----------------------------------------
  use {
    "TimUntersberger/neogit",
    event = "VimEnter",
    config = function()
      require("plugins/config/neogit")
    end,
  }

  -- Lint ----------------------------------------
  use {
    "jose-elias-alvarez/null-ls.nvim",
    after = "nvim-lsp-installer",
    config = function()
      require("plugins/config/null-ls")
    end,
  }


  -- Comment Library ------------------------------
  use {
    "numToStr/Comment.nvim",
    event = "VimEnter",
    config = function()
      require("plugins/config/Comment")
    end,
  }

  -- FuzzyFinder Library --------------------------
  use {
    "nvim-telescope/telescope.nvim",
    requires = { { 'nvim-lua/plenary.nvim', opt = true } },
    after = { colorscheme },
    config = function()
      require("plugins/config/telescope")
    end,
  }
  use {
    "nvim-telescope/telescope-frecency.nvim",
    requires = { "kkharji/sqlite.lua" },
    after = { "telescope.nvim" },
    config = function()
      require("telescope").load_extension("frecency")
    end,
  }

  -- Treesitter ----------------------------------
  use {
    "nvim-treesitter/nvim-treesitter",
    after = { colorscheme },
    event = "VimEnter",
    run = ":TSUpdate",
    config = function()
      require("plugins/config/nvim-treesitter")
    end,
  }

  -- Appearance ----------------------------------
  ---- Statusline
  use {
    "nvim-lualine/lualine.nvim",
    after = colorscheme,
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
    config = function()
      require("plugins/config/lualine")
    end,
  }

  ---- Bufferline
  if not vim.g.vscode then
    use {
      "akinsho/bufferline.nvim",
      after = colorscheme,
      requires = { 'kyazdani42/nvim-web-devicons' },
      config = function()
        require("plugins/config/bufferline")
      end,
    }
  end

  ---- Startup Screen
  use {
    "goolord/alpha-nvim",
    config = function()
      require("plugins/config/alpha-nvim")
    end,
  }

  ---- Scrollbar
  use {
    "petertriho/nvim-scrollbar",
    requires = { { "kevinhwang91/nvim-hlslens", opt = true } },
    after = { colorscheme, "nvim-hlslens" },
    config = function()
      require("plugins/config/nvim-scrollbar")
    end,
  }

  -- Add and Subtract
  use {
    "monaqa/dial.nvim",
    event = "VimEnter",
    config = function()
      require("plugins/config/dial")
    end,
  }

  -- Search --------------------------------------
  use {
    "kevinhwang91/nvim-hlslens",
    event = "VimEnter",
    config = function()
      require("plugins/config/nvim-hlslens")
    end,
  }
  use({
    "haya14busa/vim-asterisk",
    event = "VimEnter",
    config = function()
      vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-asterisk.vim")
    end,
  })


  -- Filer ---------------------------------------
  use {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("plugins/config/neo-tree")
    end,
  }

  -- Buffer --------------------------------------
  use {
    "famiu/bufdelete.nvim",
    event = "VimEnter",
    config = function()
      require("plugins/config/bufdelete")
    end,
  }

  -- Snippet -------------------------------------
  use {
    "L3MON4D3/LuaSnip",
    event = "VimEnter",
    config = function()
      require("plugins/config/LuaSnip")
    end,
  }
  use { "rafamadriz/friendly-snippets", opt = true }

  -- AutoSave ------------------------------------
  use { 
    "Pocco81/AutoSave.nvim",
    config = function()
      require("plugins/config/AutoSave")
    end,
  }

  -- MultiCursor ---------------------------------
  use {
    "mg979/vim-visual-multi",
    config = function()
      vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-visual-multi.vim")
    end,
  }

  -- Move ----------------------------------------
  use {
    "phaazon/hop.nvim",
    event = "VimEnter",
    config = function()
      require("plugins/config/hop")
    end,
  } 
  ---- Horizontal Move
  use {
    "jinh0/eyeliner.nvim",
    event = "VimEnter",
    config = function()
      require("eyeliner").setup({})
    end,
  } 
  use {
    "ggandor/lightspeed.nvim",
    event = "VimEnter",
    setup = function()
      vim.g.lightspeed_no_default_keymaps = true
    end,
    config = function()
      require("plugins/config/lightspeed")
    end,
  } 

  -- Manual --------------------------------------
  use {
    "thinca/vim-ref",
    event = "VimEnter",
    config = function()
      vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-ref.vim")
    end,
  }
  use {
    "folke/which-key.nvim",
    event = "VimEnter",
    config = function()
      require("plugins/config/which-key")
    end,
  }

  -- Brackets ------------------------------------
  use {
    "windwp/nvim-autopairs",
    event = "VimEnter",
    config = function()
      require("plugins/config/nvim-autopairs")
    end,
  } 

end)
