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

  -- UI Library ----------------------------------
  use { "stevearc/dressing.nvim", event = "VimEnter" }


  -- Devicons ---------------------------------
  if not os.getenv("DISABLE_DEVICONS") or os.getenv("DISABLE_DEVICONS") == "false" then
    use { "kyazdani42/nvim-web-devicons", after = colorscheme }
  end

  -- LSP & Completion ----------------------------
  ---- Auto Completion
  use { "hrsh7th/nvim-cmp", wants = { "LuaSnip" }, requires = {
    { "L3MON4D3/LuaSnip" },
    { "windwp/nvim-autopairs", config = function() require("plugins/config/nvim-autopairs") end},
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" }, -- path completion
    { "hrsh7th/cmp-cmdline" }, -- cmdline completion
    { "dmitmel/cmp-cmdline-history" }, -- cmdline history copletion
    { "hrsh7th/cmp-nvim-lua" }, -- lua completion
    { "hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp" }, -- lsp completion
    { "hrsh7th/cmp-nvim-lsp-signature-help" }, -- display function signatures with the current parameter emphasized
    { "hrsh7th/cmp-nvim-lsp-document-symbol" }, -- customize `/` search
    { "hrsh7th/cmp-emoji" }, -- emoji completion
    { "hrsh7th/cmp-calc" }, -- simple calc
    { "saadparwaiz1/cmp_luasnip" }, -- luasnip completion
    { "f3fora/cmp-spell" }, -- vim's spell suggests
    { "yutkat/cmp-mocword" }, -- mocward(predict next word) completion
    { "uga-rosa/cmp-dictionary", config = function() require "plugins/config/cmp-dictionary" end }, -- dictionary completion
    { "tzachar/cmp-tabnine", run = "./install.sh" },  -- AI completion
    { "ray-x/cmp-treesitter" }, -- treesitter node completion
    { "lukas-reineke/cmp-rg" }, -- ripgrep completion, `sudo apt-get install ripgrep`
    { "lukas-reineke/cmp-under-comparator", module = "cmp-under-comparator" } -- better sort completion
    },
      config = function() require("plugins/config/nvim-cmp") end }
  use { "onsails/lspkind-nvim", module = "lspkind", config = function() require "plugins/config/lspkind-nvim" end } -- show icon

  ---- Language Server Protocol(LSP)
  use { "neovim/nvim-lspconfig", event = "VimEnter", config = function() require("plugins/config/nvim-lspconfig") end }
  use { "williamboman/mason.nvim", event = "VimEnter", config = function() require("plugins/config/mason") end }
  use { "williamboman/mason-lspconfig.nvim", after = { "mason.nvim", "nvim-lspconfig", "cmp-nvim-lsp" }, config = function() require("plugins/config/mason-lspconfig") end }

  ---- LSP's UI
  use { "kkharji/lspsaga.nvim", after = "mason.nvim", config = function() require("plugins/config/lspsaga") end } -- highly performant UI
  use { "folke/lsp-colors.nvim", module = "lsp-colors" } -- creates missing LSP diagnostics highlight groups for color schemes
  use { "folke/trouble.nvim", after = "mason.nvim", config = function() require("plugins/config/trouble") end } -- A pretty list for showing diagnostics etc.
  use { "j-hui/fidget.nvim", after = "mason.nvim", config = function() require("plugins/config/fidget") end } -- Standalone UI for nvim-lsp progress

  -- FuzzyFinder Library --------------------------
  use { "nvim-telescope/telescope.nvim", requires = { { 'nvim-lua/plenary.nvim', opt = true } }, after = colorscheme, config = function() require("plugins/config/telescope") end }
  use { "nvim-telescope/telescope-frecency.nvim", requires = { "kkharji/sqlite.lua" }, after = "telescope.nvim", config = function() require("telescope").load_extension("frecency") end } -- :Telescope frecency
  use { "nvim-telescope/telescope-packer.nvim", requires = { "wbthomason/packer.nvim" }, after = "telescope.nvim", config = function() require("telescope").load_extension("packer") end } -- :Telescope packer
  use { "nvim-telescope/telescope-github.nvim", after = { "telescope.nvim" }, config = function() require("telescope").load_extension("gh") end } -- :Telescope gh
  use { "nvim-telescope/telescope-bibtex.nvim", after = 'telescope.nvim', config = function () require("telescope").load_extension("bibtex") end }
  use { "nvim-telescope/telescope-symbols.nvim", after = 'telescope.nvim' }

  -- Treesitter ----------------------------------
  use { "nvim-treesitter/nvim-treesitter", after = colorscheme, event = "VimEnter", run = ":TSUpdate", config = function() require("plugins/config/nvim-treesitter") end }
  use { "yioneko/nvim-yati", requires = "nvim-treesitter/nvim-treesitter", opt = true} -- Adjust indent
  use { "mfussenegger/nvim-treehopper", after = { "nvim-treesitter" }, config = function() require("plugins/config/nvim-treehopper") end }
  use { "David-Kunz/treesitter-unit", after = { "nvim-treesitter" }, config = function() require("plugins/config/treesitter-unit") end }
  use { "nvim-treesitter/nvim-treesitter-textobjects", after = { "nvim-treesitter" } }
  use { "mizlan/iswap.nvim", after = { "nvim-treesitter" }, config = function() require("plugins/config/iswap") end }

  -- Appearance ----------------------------------
  ---- Statusline
  use { "nvim-lualine/lualine.nvim", after = colorscheme, requires = { "kyazdani42/nvim-web-devicons", opt = true }, config = function() require("plugins/config/lualine") end }
  use { "SmiteshP/nvim-navic", module = "nvim-navic", setup = function() require("plugins/config/nvim-navic") end }

  ---- Bufferline
  if not vim.g.vscode then
    use { "akinsho/bufferline.nvim", after = colorscheme, requires = { 'kyazdani42/nvim-web-devicons' }, config = function() require("plugins/config/bufferline") end }
  end

  ---- Syntax
  use { "norcalli/nvim-colorizer.lua", event = "VimEnter", config = function() require("colorizer").setup() end } -- A high-performance color highlighter
  use { "t9md/vim-quickhl", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-quickhl.vim") end }
  -- use { "folke/todo-comments.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/todo-comments") end } -- TODO

  ---- Sidebar
  use { "sidebar-nvim/sidebar.nvim", config = function() require("plugins/config/sidebar") end }

  ---- Startup Screen
  use { "goolord/alpha-nvim", config = function() require("plugins/config/alpha-nvim") end } -- トップページ

  ---- Scrollbar
  use { "petertriho/nvim-scrollbar", requires = { { "kevinhwang91/nvim-hlslens", opt = true } }, after = { colorscheme, "nvim-hlslens" }, config = function() require("plugins/config/nvim-scrollbar") end }

  -- Editing -------------------------------------
  ---- AutoSave
  use { "Pocco81/auto-save.nvim", branch = "dev", config = function() require("plugins/config/auto-save") end }

  ---- Move
  use { "phaazon/hop.nvim", event = "VimEnter", config = function() require("plugins/config/hop") end }

  ---- Horizontal Move
  use { "jinh0/eyeliner.nvim", event = "VimEnter", config = function() require("eyeliner").setup({}) end }
  use { "ggandor/lightspeed.nvim", event = "VimEnter", setup = function() vim.g.lightspeed_no_default_keymaps = true end, config = function() require("plugins/config/lightspeed") end }

  ---- Vertical Move
  -- use { "haya14busa/vim-edgemotion", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/rc/pluginconfig/vim-edgemotion.vim") end } -- TODO
  -- use { "machakann/vim-columnmove", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/rc/pluginconfig/vim-columnmove.vim") end } -- TODO

  ---- Word Move
  -- use { "justinmk/vim-ipmotion", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/rc/pluginconfig/vim-ipmotion.vim") end } -- TODO
  -- use { "bkad/CamelCaseMotion", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/rc/pluginconfig/CamelCaseMotion.vim") end } -- TODO

  ---- MultiCursor -- TODO
  use { "mg979/vim-visual-multi", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-visual-multi.vim") end }


  ---- Operator
  -- use { "gbprod/substitute.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/substitute") end } -- TODO
  -- use { "kylechui/nvim-surround", event = "VimEnter", config = function() require("rc/pluginconfig/nvim-surround") end } -- TODO

  ---- Join
  -- use { "AckslD/nvim-trevJ.lua", module = "trevj", after = { "nvim-treesitter" }, config = function() require("rc/pluginconfig/nvim-trevJ") end } -- TODO

  ---- Add and Subtract
  use { "monaqa/dial.nvim", event = "VimEnter", config = function() require("plugins/config/dial") end }

  ---- Yank
  -- use { "hrsh7th/nvim-pasta", event = "VimEnter", config = function() require("rc/pluginconfig/nvim-pasta") end, } -- TODO
  -- use { "AckslD/nvim-neoclip.lua", requires = { { "nvim-telescope/telescope.nvim", opt = true }, { "kkharji/sqlite.lua", opt = true } }, after = { "telescope.nvim", "sqlite.lua" }, config = function() require("rc/pluginconfig/nvim-neoclip") end, } -- TODO

  -- Search --------------------------------------
  use { "kevinhwang91/nvim-hlslens", event = "VimEnter", config = function() require("plugins/config/nvim-hlslens") end }
  use { "haya14busa/vim-asterisk", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-asterisk.vim") end }

  -- File ----------------------------------------
  ---- Filer
  use { "nvim-neo-tree/neo-tree.nvim", event = "VimEnter" ,branch = "v2.x", requires = { "nvim-lua/plenary.nvim", "kyazdani42/nvim-web-devicons", "MunifTanjim/nui.nvim" }, config = function() require("plugins/config/neo-tree") end }

  ---- Buffer
  use { "kazhala/close-buffers.nvim", config = function() require("plugins/config/close-buffers") end } -- https://github.com/kazhala/close-buffers.nvim
  use { "famiu/bufdelete.nvim", event = "VimEnter", config = function() require("plugins/config/bufdelete") end }

  -- Standard Feature Enhancement ----------------
  ---- Manual -- TODO
  use { "thinca/vim-ref", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-ref.vim") end }
  use { "folke/which-key.nvim", event = "VimEnter", config = function() require("plugins/config/which-key") end }
  -- use { "sudormrfbin/cheatsheet.nvim", requires = { { "nvim-telescope/telescope.nvim", opt = true } }, after = { "telescope.nvim" } } 

  ---- Quickfix -- TODO
  -- use { "kevinhwang91/nvim-bqf", event = "VimEnter", config = function() require("rc/pluginconfig/nvim-bqf") end, }
  -- use { "gabrielpoca/replacer.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/replacer") end, }
  -- use { "stevearc/qf_helper.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/qf_helper") end, }

  ---- Session
  use { "jedrzejboczar/possession.nvim", config = function() require("plugins/config/possession") end }

  ---- SpellCorrect (iabbr) -- TODO
  -- use { "Pocco81/AbbrevMan.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/AbbrevMan") end }

  ---- Command
  use { "jghauser/mkdir.nvim", event = "VimEnter", config = function() require("mkdir") end }

  ---- Terminal
  use { "akinsho/toggleterm.nvim", after = { colorscheme }, config = function() require("plugins/config/toggleterm") end }

  -- Other ---------------------------------------
  ---- Translate -- TODO
  -- use { "uga-rosa/translate.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/translate") end }

  ---- Popup Info -- TODO
  -- use { "lewis6991/hover.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/hover") end }

  ---- Memo -- TODO
  -- use { "renerocksai/telekasten.nvim", after = { "telescope.nvim" }, require = { "renerocksai/calendar-vim" }, config = function() require("rc/pluginconfig/telekasten") end }
  -- use { "romgrk/todoist.nvim", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/todoist.vim") end } -- TODO
  use { "flap1/nvim-todoist.lua", event = "VimEnter", config = function() require('nvim-todoist').neovim_stuff.use_defaults() end }
  -- use { "stevearc/gkeep.nvim", run = ':UpdateRemotePlugins' }

  ---- Template -- TODO
  -- use { "glepnir/template.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/template") end }

  ---- Performance Improvement
  use { "tweekmonster/startuptime.vim" } -- :StartupTime, https://github.com/tweekmonster/startuptime.vim
  use { "lewis6991/impatient.nvim", config = function() require('impatient') require('impatient').enable_profile() end }
  use { "nathom/filetype.nvim", config = function() require("plugins/config/filetype") end } -- earlier then Neovim 0.8.0

  ---- Analytics -- TODO
  -- if not os.getenv("DISABLE_WAKATIME") or os.getenv("DISABLE_WAKATIME") == "true" then
  --   if vim.fn.filereadable(vim.fn.expand("~/.wakatime.cfg")) == 1 then
  --     use { "wakatime/vim-wakatime", event = "VimEnter" }
  --   end
  -- end

  -- Coding --------------------------------------
  ---- Writing assistant -- TODO
  use { "nmac427/guess-indent.nvim", event = { "BufNewFile", "BufReadPre" }, config = function() require("guess-indent").setup() end }
  -- use { "lfilho/cosco.vim", event = "VimEnter", config = function() vim.cmd("source ~/.config/nvim/rc/pluginconfig/cosco.vim") end }

  ---- Reading assistant -- TODO
  -- use { "lukas-reineke/indent-blankline.nvim", after = { colorscheme }, event = "VimEnter", config = function() require("rc/pluginconfig/indent-blankline") end }

  ---- Comment out
  use { "numToStr/Comment.nvim", event = "VimEnter", config = function() require("plugins/config/Comment") end }
  -- use { "s1n7ax/nvim-comment-frame", requires = { { "nvim-treesitter/nvim-treesitter", opt = true } }, after = { "nvim-treesitter" }, config = function() require("rc/pluginconfig/nvim-comment-frame") end } -- TODO

  ---- Annotation -- TODO
  -- use { "danymat/neogen", config = function() require("rc/pluginconfig/neogen") end, after = { "nvim-treesitter" } }

  ---- Brackets
  -- use { "andymass/vim-matchup", after = { "nvim-treesitter" }, config = function() vim.cmd("source ~/.config/nvim/rc/pluginconfig/vim-matchup.vim") end } -- TODO

  ---- Endwise -- TODO
  -- use { "RRethy/nvim-treesitter-endwise", requires = { { "nvim-treesitter/nvim-treesitter", opt = true } }, after = { "nvim-treesitter" } }

  -- Test -- TODO
  -- if vim.fn.executable("cargo") == 1 then
  --   use { "michaelb/sniprun", run = "bash install.sh", cmd = { "SnipRun" } }
  -- end

  ---- Task runner -- TODO
  -- use { "stevearc/overseer.nvim", after = { "dressing.nvim" }, config = function() require("rc/pluginconfig/overseer") end }

  ---- Code outline -- TODO
  -- use { "stevearc/aerial.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/aerial") end }

  ---- Snippet
  use { "L3MON4D3/LuaSnip", wants = "friendly-snippets", config = function() require("plugins/config/LuaSnip") end }
  use { "benfowler/telescope-luasnip.nvim", after = { "telescope.nvim", "LuaSnip" }, config = function() require("telescope").load_extension("luasnip") end } -- TODO
  use "rafamadriz/friendly-snippets" -- snippets collection

  ---- Project -- TODO
  -- use { "ahmedkhalf/project.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/project") end }

  ---- Git -- TODO
  -- use { "TimUntersberger/neogit", config = function() require("plugins/config/neogit") end }
  -- use { "akinsho/git-conflict.nvim", event = "VimEnter", config = function() require("git-conflict").setup() end }
  -- use { "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" }, event = "VimEnter", config = function() require("rc/pluginconfig/gitsigns") end }
  -- use { "sindrets/diffview.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/diffview") end }
  -- use { "rhysd/committia.vim" }
  -- use { "hotwatermorning/auto-git-diff", ft = { "gitrebase" } }
  -- use { "pwntester/octo.nvim", cmd = { "Octo" } } -- GitHub

  ---- Debugger -- TODO
  -- use { "mfussenegger/nvim-dap", event = "VimEnter", config = function() require("rc/pluginconfig/nvim-dap") end }
  -- use { "rcarriga/nvim-dap-ui", after = { "nvim-dap" }, config = function() require("rc/pluginconfig/nvim-dap-ui") end }
  -- use { "theHamsta/nvim-dap-virtual-text", after = { "nvim-dap" } }
  -- use { "nvim-telescope/telescope-dap.nvim", requires = { { "mfussenegger/nvim-dap", opt = true }, { "nvim-telescope/telescope.nvim", opt = true }, }, after = { "nvim-dap", "telescope.nvim" } }
  -- use({ "andrewferrier/debugprint.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/debugprint") end }

  ---- REPL -- TODO
  -- use { "hkupty/iron.nvim", event = "VimEnter", config = function() require("rc/pluginconfig/iron") end }

  -- Programming Languages -----------------------
  ---- Markdown
  use { "iamcco/markdown-preview.nvim", ft = { "markdown" }, run = ":call mkdp#util#install()" }
  -- use { "SidOfc/mkdx", ft = { "markdown" }, setup = function() vim.cmd("source ~/.config/nvim/rc/pluginsetup/mkdx.vim") end } -- TODO
  use { "dhruvasagar/vim-table-mode", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vim-table-mode.vim") end } -- markdownでテーブルを綺麗に表示

  ---- CSV -- TODO
  -- use { "chen244/csv-tools.lua", ft = { "csv" }, config = function() require("rc/pluginconfig/csv-tools") end, }

  ---- Lua
  use { "folke/lua-dev.nvim", module = "lua-dev" } -- Dev setup for init.lua and plugin development

  ---- Rust 
  use { "simrat39/rust-tools.nvim", module = "rust-tools" }

  ---- LaTeX
  use { "lervag/vimtex", config = function() vim.cmd("source ~/.config/nvim/vim/plugins/config/vimtex.vim") end }

  -- Paper writing
  -- Zotcite -- https://github.com/latex-lsp/texlab
  -- texlab -- https://github.com/latex-lsp/texlab, https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/texlab.lua
  -- vimtex -- https://github.com/lervag/vimtex
  -- vim-latex-live-preview -- https://github.com/xuhdev/vim-latex-live-preview

end)
