-- Motion, surround, completion, snippets.

return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          enabled = true,
          jump_labels = true,
        },
      },
    },
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,             desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,             desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<C-s>", mode = "c",               function() require("flash").toggle() end,             desc = "Toggle Flash Search" },
    },
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "*",
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
      keymap = {
        preset = "default",
        ["<C-g>"]   = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"]   = { "hide" },
        ["<CR>"]    = { "accept", "fallback" },
        ["<Tab>"]   = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
        ["<C-b>"]   = { "scroll_documentation_up", "fallback" },
        ["<C-f>"]   = { "scroll_documentation_down", "fallback" },
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

  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = "make install_jsregexp",
    config = function()
      local cfg = vim.fn.stdpath("config")
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = cfg .. "/snippets/vscode",
      })
      require("luasnip.loaders.from_lua").lazy_load({
        paths = cfg .. "/snippets/lua",
      })
    end,
  },
}
