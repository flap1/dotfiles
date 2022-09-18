local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/opt/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.api.nvim_command('silent !git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

vim.cmd [[ packadd packer.nvim ]]
require 'plugins/packer'

---@format disable
return require("packer").startup(function(use)
  -- Plugin Manager
  use { 'wbthomason/packer.nvim', opt = true } -- packer.nvim

  -- Dependent Library --------------------------------
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
  ---- tokyonight
  local colorscheme = "tokyonight.nvim"
  use { "folke/tokyonight.nvim", event = { "VimEnter", "ColorSchemePre" }, config = function() require "plugins/config/tokyonight" end }
  ---- nightfox
  -- local colorscheme = "nightfox.nvim"
  -- use { "EdenEast/nightfox.nvim", event = { "VimEnter", "ColorSchemePre" }, config = function () require "plugins/config/nightfox" end }

  -- Speedup -------------------------------------
  -- use 'lewis6991/impatient.nvim' -- https://github.com/lewis6991/impatient.nvim

  -- Devicons ---------------------------------
  if not os.getenv("DISABLE_DEVICONS") or os.getenv("DISABLE_DEVICONS") == "false" then
    use { "kyazdani42/nvim-web-devicons", after = colorscheme }
  end

  -- Session --------------------------------------
  use { "jedrzejboczar/possession.nvim", config = function() require("plugins/config/possession") end }

  -- LSP & Completion ----------------------------
  ---- Auto Completion
  use { "hrsh7th/nvim-cmp", requires = { { "L3MON4D3/LuaSnip", opt = true, event = "VimEnter" }, { "windwp/nvim-autopairs", opt = true, event = "VimEnter" } }, after = { "LuaSnip", "nvim-autopairs" }, config = function() require("plugins/config/nvim-cmp") end }
  use { "onsails/lspkind-nvim", module = "lspkind", config = function() require "plugins/config/lspkind-nvim" end } -- show icon
  use { "hrsh7th/cmp-buffer", after = "nvim-cmp" } -- buffer completion
  use { "hrsh7th/cmp-path", after = "nvim-cmp" } -- path completion
  use { "hrsh7th/cmp-cmdline", after = "nvim-cmp" } -- cmdline completion
  use { "dmitmel/cmp-cmdline-history", after = "nvim-cmp" } -- cmdline history copletion
  use { "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" } -- lua completion
  use { "hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp" } -- lsp completion
  use { "hrsh7th/cmp-nvim-lsp-signature-help", after = "nvim-cmp" } -- display function signatures with the current parameter emphasized
  use { "hrsh7th/cmp-nvim-lsp-document-symbol", after = "nvim-cmp" } -- customize `/` search
  use { "hrsh7th/cmp-emoji", after = "nvim-cmp" } -- emoji completion
  use { "hrsh7th/cmp-calc", after = "nvim-cmp" } -- simple calc
  use { "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" } -- luasnip completion
  use { "f3fora/cmp-spell", after = "nvim-cmp" } -- vim's spell suggests
  use { "yutkat/cmp-mocword", after = "nvim-cmp" } -- mocward(predict next word) completion
  use { "uga-rosa/cmp-dictionary", after = "nvim-cmp", config = function() require "plugins/config/cmp-dictionary" end } -- dictionary completion

  use { "tzachar/cmp-tabnine", run = "./install.sh", after = "nvim-cmp" } -- AI completion
  use { "ray-x/cmp-treesitter", after = "nvim-cmp" } -- treesitter node completion
  use { "lukas-reineke/cmp-rg", after = "nvim-cmp" } -- ripgrep completion, `sudo apt-get install ripgrep`
  use { "lukas-reineke/cmp-under-comparator", module = "cmp-under-comparator" } -- better sort completion

  ---- Language Server Protocol(LSP)
  use { "neovim/nvim-lspconfig", event = "VimEnter", config = function() require("plugins/config/nvim-lspconfig") end }
  use { "williamboman/mason.nvim", event = "VimEnter", config = function() require("plugins/config/mason") end }
  use { "williamboman/mason-lspconfig.nvim", after = { "mason.nvim", "nvim-lspconfig", "cmp-nvim-lsp" }, config = function() require("plugins/config/mason-lspconfig") end }

  ---- LSP's UI
  use { "kkharji/lspsaga.nvim", after = "mason.nvim", config = function() require("plugins/config/lspsaga") end } -- highly performant UI
  use { "folke/lsp-colors.nvim", module = "lsp-colors" } -- creates missing LSP diagnostics highlight groups for color schemes
  use { "folke/trouble.nvim", after = "mason.nvim", config = function() require("plugins/config/trouble") end } -- A pretty list for showing diagnostics etc.
  use { "j-hui/fidget.nvim", after = "mason.nvim", config = function() require("plugins/config/fidget") end } -- Standalone UI for nvim-lsp progress

  -- Syntax --------------------------------------
  use { "norcalli/nvim-colorizer.lua", event = "VimEnter", config = function() require("colorizer").setup() end } -- A high-performance color highlighter
  use { "t9md/vim-quickhl", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-quickhl.vim") end }

  -- Git -----------------------------------------
  use { "TimUntersberger/neogit", event = "VimEnter", config = function() require("plugins/config/neogit") end }

  -- Lint ----------------------------------------
  -- use { "jose-elias-alvarez/null-ls.nvim", commit = "76d0573f", after = "mason.nvim", config = function() require("plugins/config/null-ls") end }

  -- Comment Library ------------------------------
  use { "numToStr/Comment.nvim", event = "VimEnter", config = function() require("plugins/config/Comment") end }

  -- FuzzyFinder Library --------------------------
  use { "nvim-telescope/telescope.nvim", requires = { { 'nvim-lua/plenary.nvim', opt = true } }, after = colorscheme, config = function() require("plugins/config/telescope") end }
  use { "nvim-telescope/telescope-frecency.nvim", requires = { "kkharji/sqlite.lua" }, after = "telescope.nvim", config = function() require("telescope").load_extension("frecency") end } -- :Telescope frecency
  use { "nvim-telescope/telescope-packer.nvim", requires = { "wbthomason/packer.nvim" }, after = "telescope.nvim", config = function() require("telescope").load_extension("packer") end } -- :Telescope packer
  use { "nvim-telescope/telescope-github.nvim", after = { "telescope.nvim" }, config = function() require("telescope").load_extension("gh") end } -- :Telescope gh

  -- Treesitter ----------------------------------
  use { "nvim-treesitter/nvim-treesitter", after = colorscheme, event = "VimEnter", run = ":TSUpdate", config = function() require("plugins/config/nvim-treesitter") end }
  use { "yioneko/nvim-yati", requires = "nvim-treesitter/nvim-treesitter", opt = true} -- Adjust indent, bug due to treesitter @2022/9/7

  -- Appearance ----------------------------------
  ---- Statusline
  use { "nvim-lualine/lualine.nvim", after = colorscheme, requires = { "kyazdani42/nvim-web-devicons", opt = true }, config = function() require("plugins/config/lualine") end }
  use { "SmiteshP/nvim-navic", module = "nvim-navic", setup = function() require("plugins/config/nvim-navic") end }

  ---- Bufferline
  if not vim.g.vscode then
    use { "akinsho/bufferline.nvim", after = colorscheme, requires = { 'kyazdani42/nvim-web-devicons' }, config = function() require("plugins/config/bufferline") end }
  end

  ---- Startup Screen
  use { "goolord/alpha-nvim", config = function() require("plugins/config/alpha-nvim") end } -- トップページ

  ---- Scrollbar
  use { "petertriho/nvim-scrollbar", requires = { { "kevinhwang91/nvim-hlslens", opt = true } }, after = { colorscheme, "nvim-hlslens" }, config = function() require("plugins/config/nvim-scrollbar") end }

  -- Add and Subtract
  use { "monaqa/dial.nvim", event = "VimEnter", config = function() require("plugins/config/dial") end }

  -- Search --------------------------------------
  use { "kevinhwang91/nvim-hlslens", event = "VimEnter", config = function() require("plugins/config/nvim-hlslens") end }
  use { "haya14busa/vim-asterisk", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-asterisk.vim") end }

  -- Filer ---------------------------------------
  use { "nvim-neo-tree/neo-tree.nvim", branch = "v2.x", requires = { "nvim-lua/plenary.nvim", "kyazdani42/nvim-web-devicons", "MunifTanjim/nui.nvim" }, config = function() require("plugins/config/neo-tree") end }

  -- Buffer --------------------------------------
  use { "kazhala/close-buffers.nvim", config = function() require("plugins/config/close-buffers") end } -- https://github.com/kazhala/close-buffers.nvim
  use { "famiu/bufdelete.nvim", event = "VimEnter", config = function() require("plugins/config/bufdelete") end }

  -- Snippet -------------------------------------
  use { "L3MON4D3/LuaSnip", event = "VimEnter", config = function() require("plugins/config/LuaSnip") end }
  use { "rafamadriz/friendly-snippets", opt = true } -- snippets collection

  -- AutoSave ------------------------------------
  use { "Pocco81/auto-save.nvim", branch = "dev", config = function() require("plugins/config/auto-save") end }

  -- MultiCursor ---------------------------------
  use { "mg979/vim-visual-multi", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-visual-multi.vim") end }

  -- Move ----------------------------------------
  use { "phaazon/hop.nvim", event = "VimEnter", config = function() require("plugins/config/hop") end }
  ---- Horizontal Move
  use { "jinh0/eyeliner.nvim", event = "VimEnter", config = function() require("eyeliner").setup({}) end }
  use { "ggandor/lightspeed.nvim", event = "VimEnter", setup = function() vim.g.lightspeed_no_default_keymaps = true end, config = function() require("plugins/config/lightspeed") end }

  -- Manual --------------------------------------
  use { "thinca/vim-ref", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-ref.vim") end }
  use { "folke/which-key.nvim", event = "VimEnter", config = function() require("plugins/config/which-key") end }

  -- Brackets ------------------------------------
  use { "windwp/nvim-autopairs", event = "VimEnter", config = function() require("plugins/config/nvim-autopairs") end }

  -- Markdown -------------------------------------
  use { "iamcco/markdown-preview.nvim", ft = { "markdown" }, run = ":call mkdp#util#install()" }
  use { "dhruvasagar/vim-table-mode", event = "VimEnter", cmd = { "TableModeEnable" }, config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-table-mode.vim") end } -- markdownでテーブルを綺麗に表示

  -- Lua ------------------------------------------
  use { "folke/lua-dev.nvim", module = "lua-dev" } -- Dev setup for init.lua and plugin development

  -- Rust ----------------------------------------
  use { "simrat39/rust-tools.nvim", module = "rust-tools" }
end)
