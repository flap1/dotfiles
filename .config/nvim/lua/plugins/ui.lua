-- UI plugins: colorscheme, statusline, file navigation
--
-- Chrome budget: tmux status line (1 row) + lualine (1 row). Nothing else.
-- Buffer/window switching lives in tmux (windows) and telescope (files),
-- so there is no bufferline and no persistent file tree.

return {
  -- Colorscheme: the design-system palette fed through base16.
  --
  -- base16 is used instead of hand-writing highlight groups: supply 16 colours
  -- and every plugin, treesitter capture and LSP group gets a consistent
  -- assignment for free. Design tokens map onto the ramp as follows —
  --   base00-07 = the neutral background→foreground ladder
  --   base08-0F = the accent slots (red/orange/yellow/green/cyan/blue/purple/brown)
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    -- Dark variant. The design system is specified for light web surfaces, so
    -- three tokens fail WCAG AA (4.5:1) against a dark editor background and are
    -- lifted to the next step of the same hue. Measured against base00 #0f172a:
    --   primary/green  #047857 → 3.26  lifted to #10b981 (7.04)
    --   error          #dc2626 → 3.70  lifted to #ef4444 (4.74)
    --   primary/brown  #8B5A2B → 3.06  lifted to #d8c3a8 (10.45, = border/brown)
    --   text/subtle    #64748b → 3.75  demoted to comments only, where AA is advisory
    -- Everything else is the literal token value.
    config = function()
      vim.o.background = "dark"
      require("base16-colorscheme").setup({
        base00 = "#0f172a", -- text/default, inverted — editor background
        base01 = "#1e293b", -- derived: one step up — gutter, floats, popup surfaces
        base02 = "#334155", -- derived: two steps up — visual selection
        base03 = "#64748b", -- text/subtle           — comments
        base04 = "#94a3b8", -- text/muted            — line numbers
        base05 = "#e2e8f0", -- derived: body text on dark
        base06 = "#f1f5f9", -- derived
        base07 = "#ffffff", -- text/on-primary       — brightest foreground
        base08 = "#ef4444", -- error, lifted         — variables, deletions
        base09 = "#f59e0b", -- active                — numbers, constants
        base0A = "#fbbf24", -- derived: active lightened, kept distinct from base09
        base0B = "#059669", -- success               — strings, insertions
        base0C = "#0ea5e9", -- info                  — escapes, support
        base0D = "#10b981", -- primary/green, lifted — functions (brand colour on code)
        base0E = "#a855f7", -- inactive              — keywords
        base0F = "#d8c3a8", -- border/brown          — deprecated, special
      })
    end,
  },

  -- No statusline plugin. laststatus=0 in core/options.lua; mode, position and
  -- filename land in the cmdline row that already exists. tmux owns the only bar.

  -- nvim-web-devicons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- nvim-highlight-colors: color code highlighting (norcalli/nvim-colorizer is unmaintained)
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

  -- oil.nvim: edit the filesystem like a buffer. Default explorer now that
  -- neo-tree is gone; yazi covers the "browse around" case.
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
      { "-", "<Cmd>Oil<CR>", desc = "Open Oil (parent dir)" },
    },
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
      float = { padding = 2 },
    },
  },

  -- snacks.explorer: the persistent left sidebar tree.
  -- Uses snacks, which is already loaded for lazygit/terminal/dashboard, so this
  -- costs no new plugin. (oil was the alternative but is a buffer-based editor,
  -- not a sidebar: selecting a file replaces the tree window itself.)
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = true },
      picker = {
        enabled = true, -- required: the explorer is a picker rendered as a sidebar
        sources = {
          explorer = {
            layout = { preset = "sidebar", preview = false },
            auto_close = false,
            follow_file = true, -- reveal the current buffer as you move around
            -- Gitignored entries stay visible in the sidebar and are filtered
            -- out of search instead. The sidebar answers "what is in this
            -- directory", and hiding target/ or .env from that answer hides
            -- that they exist at all; search answers "where is the thing I am
            -- editing", which build output only ever gets in the way of.
            hidden = true,
            ignored = true,
          },
        },
      },
    },
    keys = {
      { "<M-n>", function() Snacks.explorer() end,              desc = "Explorer (toggle sidebar)" },
      { "<M-N>", function() Snacks.explorer.reveal() end,       desc = "Explorer (reveal current file)" },
    },
  },

  -- yazi.nvim: Rust-powered terminal file manager integration
  {
    "mikavilpas/yazi.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<Leader>fy", "<Cmd>Yazi<CR>",     desc = "Yazi (file dir)" },
      { "<Leader>fY", "<Cmd>Yazi cwd<CR>", desc = "Yazi (cwd)" },
    },
    opts = {
      open_for_directories = false,
      keymaps = { show_help = "<F1>" },
    },
  },
}
