-- UI plugins: colorscheme, statusline, bufferline, filetree, etc.

return {
  -- tokyonight: colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd("colorscheme tokyonight-night")
    end,
  },

  -- lualine: statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "SmiteshP/nvim-navic",
    },
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          { "filename", path = 1 },
          {
            function() return require("nvim-navic").get_location() end,
            cond = function() return require("nvim-navic").is_available() end,
          },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- nvim-navic: breadcrumbs for lualine
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    opts = { highlight = true },
  },

  -- bufferline: tab-style buffer list
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        offsets = {
          { filetype = "neo-tree", text = "File Explorer", highlight = "Directory" },
        },
      },
    },
  },

  -- neo-tree: file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<M-n>", "<Cmd>Neotree toggle<CR>",        desc = "NeoTree toggle" },
      { "<M-N>", "<Cmd>Neotree reveal<CR>",         desc = "NeoTree reveal" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = { width = 35 },
    },
  },

  -- nvim-web-devicons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },


  -- indent-blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
  },

  -- nvim-scrollbar
  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    dependencies = { "kevinhwang91/nvim-hlslens" },
    opts = {
      handlers = { cursor = false },
    },
    config = function(_, opts)
      require("scrollbar").setup(opts)
      require("scrollbar.handlers.search").setup()
    end,
  },

  -- nvim-highlight-colors: color code highlighting (norcalli/nvim-colorizer は未メンテ)
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      render = "background",
      enable_tailwind = true,
    },
  },

  -- todo-comments: highlight TODO/FIXME/etc.
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev todo" },
      { "<Leader>xt", "<Cmd>Trouble todo toggle<CR>", desc = "Todo (Trouble)" },
    },
  },


  -- which-key: keybinding helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 400,
    },
  },

  -- oil.nvim: edit filesystem like a buffer (rename/delete/create via normal editing)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = {
      { "-", "<Cmd>Oil<CR>", desc = "Open Oil (parent dir)" },
    },
    opts = {
      default_file_explorer = false, -- keep neo-tree as default
      view_options = { show_hidden = true },
      float = { padding = 2 },
    },
  },

  -- yazi.nvim: Rust-powered terminal file manager integration
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<Leader>fy", "<Cmd>Yazi<CR>",        desc = "Yazi (cwd)" },
      { "<Leader>fY", "<Cmd>Yazi cwd<CR>",    desc = "Yazi (file dir)" },
    },
    opts = {
      open_for_directories = false,
      keymaps = { show_help = "<F1>" },
    },
  },

  -- smart-splits.nvim: seamless navigation between Neovim + WezTerm panes
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false, -- must not lazy-load for WezTerm integration to work
    opts = {
      at_edge = "wrap",
      multiplexer_integration = "wezterm",
    },
    config = function(_, opts)
      require("smart-splits").setup(opts)
      -- Move between splits/panes (replaces plain <M-hjkl> window switching)
      vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left,  { desc = "Move to left split" })
      vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down,  { desc = "Move to lower split" })
      vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up,    { desc = "Move to upper split" })
      vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right, { desc = "Move to right split" })
      -- Resize splits
      vim.keymap.set("n", "<M-h>", require("smart-splits").resize_left,  { desc = "Resize left" })
      vim.keymap.set("n", "<M-j>", require("smart-splits").resize_down,  { desc = "Resize down" })
      vim.keymap.set("n", "<M-k>", require("smart-splits").resize_up,    { desc = "Resize up" })
      vim.keymap.set("n", "<M-l>", require("smart-splits").resize_right, { desc = "Resize right" })
    end,
  },
}
