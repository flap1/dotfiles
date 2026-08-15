-- UI: colorscheme and one directory editor. tmux owns the only bar.
-- oil is the explorer; yazi stays a shell command (`yy`).

return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    -- Dark variant. Three tokens fail WCAG AA against base00 #0f172a and are
    -- lifted to the next step of the same hue.
    config = function()
      vim.o.background = "dark"
      require("base16-colorscheme").setup({
        base00 = "#0f172a",
        base01 = "#1e293b",
        base02 = "#334155",
        base03 = "#64748b",
        base04 = "#94a3b8",
        base05 = "#e2e8f0",
        base06 = "#f1f5f9",
        base07 = "#ffffff",
        base08 = "#ef4444",
        base09 = "#f59e0b",
        base0A = "#fbbf24",
        base0B = "#059669",
        base0C = "#0ea5e9",
        base0D = "#10b981",
        base0E = "#a855f7",
        base0F = "#d8c3a8",
      })
    end,
  },

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

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
}
