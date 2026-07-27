-- Editing plugins: motion, surround, completion, snippets.
--
-- Motion is flash-only: treehopper/edgemotion/CamelCaseMotion all covered the
-- same "jump somewhere visible" job and were removed.

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

  -- blink.cmp: completion engine.
  -- Still needed on 0.12: the built-in 'autocomplete' handles only one source.
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
        -- NOT <C-Space>: tmux owns that as its prefix, so nvim would only see
        -- it after a double press. <C-g> is unused in insert mode.
        ["<C-g>"]     = { "show", "show_documentation", "hide_documentation" },
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
