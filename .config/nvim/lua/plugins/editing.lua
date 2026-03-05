-- Editing plugins: flash, surround, comment, cmp, snippets, etc.

return {
  -- flash.nvim: fast jump (replaces lightspeed/hop/leap)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          -- Use flash for f/F/t/T
          enabled = true,
          jump_labels = true,
        },
      },
    },
    keys = {
      { "s",    mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",    mode = { "n", "x", "o" }, function() require("flash").treesitter() end,         desc = "Flash Treesitter" },
      { "r",    mode = "o",               function() require("flash").remote() end,              desc = "Remote Flash" },
      { "R",    mode = { "o", "x" },      function() require("flash").treesitter_search() end,  desc = "Treesitter Search" },
      { "<C-s>", mode = "c",              function() require("flash").toggle() end,              desc = "Toggle Flash Search" },
    },
  },

  -- nvim-surround
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- nvim-autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      npairs.setup(opts)
      -- Integration with nvim-cmp
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- dial.nvim: increment/decrement enhanced
  {
    "monaqa/dial.nvim",
    event = "VeryLazy",
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
        },
      })
      vim.keymap.set({ "n", "v" }, "<C-a>",
        function() require("dial.map").manipulate("increment", "normal") end)
      vim.keymap.set({ "n", "v" }, "<C-x>",
        function() require("dial.map").manipulate("decrement", "normal") end)
      vim.keymap.set("v", "g<C-a>",
        function() require("dial.map").manipulate("increment", "gnormal") end)
      vim.keymap.set("v", "g<C-x>",
        function() require("dial.map").manipulate("decrement", "gnormal") end)
    end,
  },

  -- vim-visual-multi: multi-cursor
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
  },

  -- treesj: smart split/join (replaces unmaintained nvim-trevJ)
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<LocalLeader>j", function() require("treesj").toggle() end, desc = "TreeSJ toggle split/join" },
    },
    opts = { use_default_keymaps = false },
  },

  -- guess-indent: auto detect indentation
  {
    "nmac427/guess-indent.nvim",
    event = { "BufNewFile", "BufReadPre" },
    opts = {},
  },

  -- suda: sudo write/read
  { "lambdalisue/suda.vim", cmd = { "SudaRead", "SudaWrite" } },

  -- mkdir: auto create directories
  {
    "jghauser/mkdir.nvim",
    event = "VeryLazy",
    config = function() require("mkdir") end,
  },

  -- auto-save (okuuva fork: actively maintained, replaces Pocco81)
  {
    "okuuva/auto-save.nvim",
    event = "VeryLazy",
    opts = {
      enabled = true,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost" },
        defer_save = { "InsertLeave", "TextChanged" },
      },
      debounce_delay = 2000,
    },
  },

  -- nvim-hlslens: search highlight with count
  {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    opts = {
      calm_down = true,
      nearest_only = true,
    },
    config = function(_, opts)
      require("hlslens").setup(opts)
      local kopts = { noremap = true, silent = true }
      vim.keymap.set("n", "n",
        "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>", kopts)
      vim.keymap.set("n", "N",
        "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>", kopts)
      vim.keymap.set("n", "*",
        "*<Cmd>lua require('hlslens').start()<CR>", kopts)
      vim.keymap.set("n", "#",
        "#<Cmd>lua require('hlslens').start()<CR>", kopts)
    end,
  },

  -- nvim-asterisk: enhanced */# search
  {
    "haya14busa/vim-asterisk",
    event = "VeryLazy",
    config = function()
      vim.keymap.set({ "n", "x" }, "*",  "<Plug>(asterisk-z*)",  {})
      vim.keymap.set({ "n", "x" }, "#",  "<Plug>(asterisk-z#)",  {})
      vim.keymap.set({ "n", "x" }, "g*", "<Plug>(asterisk-gz*)", {})
      vim.keymap.set({ "n", "x" }, "g#", "<Plug>(asterisk-gz#)", {})
    end,
  },

  -- vim-edgemotion: jump to edge of block
  {
    "haya14busa/vim-edgemotion",
    event = "VeryLazy",
    config = function()
      vim.keymap.set({ "n", "x" }, "<C-j>", "<Plug>(edgemotion-j)", {})
      vim.keymap.set({ "n", "x" }, "<C-k>", "<Plug>(edgemotion-k)", {})
    end,
  },

  -- CamelCaseMotion: move inside camelCase/snake_case words
  {
    "bkad/CamelCaseMotion",
    event = "VeryLazy",
    config = function()
      vim.keymap.set({ "n", "x", "o" }, "<Leader>w", "<Plug>CamelCaseMotion_w", {})
      vim.keymap.set({ "n", "x", "o" }, "<Leader>b", "<Plug>CamelCaseMotion_b", {})
      vim.keymap.set({ "n", "x", "o" }, "<Leader>e", "<Plug>CamelCaseMotion_e", {})
    end,
  },

  -- fold-cycle: cycle through fold levels
  {
    "jghauser/fold-cycle.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<Tab>",   function() require("fold-cycle").open() end,          desc = "Fold open" },
      { "<S-Tab>", function() require("fold-cycle").close() end,         desc = "Fold close" },
      { "zC",      function() require("fold-cycle").close_all() end,     desc = "Fold close all" },
    },
  },

  -- nvim-neoclip: clipboard history
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "nvim-telescope/telescope.nvim", "kkharji/sqlite.lua" },
    event = "VeryLazy",
    opts = {
      enable_persistent_history = true,
    },
    config = function(_, opts)
      require("neoclip").setup(opts)
      require("telescope").load_extension("neoclip")
    end,
    keys = {
      { '<Leader>"', "<Cmd>Telescope neoclip<CR>", desc = "Clipboard history" },
    },
  },

  -- replacer.nvim: edit quickfix list
  {
    "gabrielpoca/replacer.nvim",
    keys = {
      { "<Leader>h", function() require("replacer").run() end, desc = "Replacer (quickfix edit)" },
    },
  },

  -- nvim-bqf: better quickfix window
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {},
  },

  -- translate.nvim
  {
    "uga-rosa/translate.nvim",
    cmd = "Translate",
    keys = {
      { "<Leader>tj", "<Cmd>Translate JA<CR>", mode = { "n", "x" }, desc = "Translate to Japanese" },
      { "<Leader>te", "<Cmd>Translate EN<CR>", mode = { "n", "x" }, desc = "Translate to English" },
    },
    opts = {
      default = { command = "translate_shell" },
    },
  },

  -- harpoon2: fast file bookmarks (1-key jump to pinned files)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {
      settings = { save_on_toggle = true },
    },
    keys = {
      { "<Leader>Ha", function() require("harpoon"):list():add() end,    desc = "Harpoon add" },
      { "<Leader>Hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
      { "<C-1>", function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
      { "<C-2>", function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
      { "<C-3>", function() require("harpoon"):list():select(3) end, desc = "Harpoon 3" },
      { "<C-4>", function() require("harpoon"):list():select(4) end, desc = "Harpoon 4" },
      { "<C-5>", function() require("harpoon"):list():select(5) end, desc = "Harpoon 5" },
    },
  },

  -- blink.cmp: completion engine (replaces nvim-cmp, ~6x faster)
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "*",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"]     = { "hide" },
        ["<CR>"]      = { "accept", "fallback" },
        ["<Tab>"]     = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"]   = { "snippet_backward", "select_prev", "fallback" },
        ["<C-b>"]     = { "scroll_documentation_up", "fallback" },
        ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      cmdline = {
        sources = { "cmdline" },
      },
      snippets = { preset = "luasnip" },
      completion = {
        ghost_text = { enabled = true },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = { border = "rounded" },
      },
      signature = { enabled = true },
    },
  },

  -- LuaSnip
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({
        paths = vim.fn.stdpath("config") .. "/snippets/lua",
      })
    end,
  },
}
