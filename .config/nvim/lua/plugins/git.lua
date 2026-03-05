-- Git plugins: gitsigns, neogit, diffview, git-conflict

return {
  -- gitsigns: inline git blame, hunk operations
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      current_line_blame = false,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local opts = { buffer = bufnr, noremap = true, silent = true }

        vim.keymap.set("n", "]h", gs.next_hunk, opts)
        vim.keymap.set("n", "[h", gs.prev_hunk, opts)
        vim.keymap.set({ "n", "v" }, "<Leader>hs", "<Cmd>Gitsigns stage_hunk<CR>", opts)
        vim.keymap.set({ "n", "v" }, "<Leader>hr", "<Cmd>Gitsigns reset_hunk<CR>", opts)
        vim.keymap.set("n", "<Leader>hS", gs.stage_buffer, opts)
        vim.keymap.set("n", "<Leader>hu", gs.undo_stage_hunk, opts)
        vim.keymap.set("n", "<Leader>hR", gs.reset_buffer, opts)
        vim.keymap.set("n", "<Leader>hp", gs.preview_hunk, opts)
        vim.keymap.set("n", "<Leader>hb", function() gs.blame_line({ full = true }) end, opts)
        vim.keymap.set("n", "<Leader>hB", gs.toggle_current_line_blame, opts)
        vim.keymap.set("n", "<Leader>hd", gs.diffthis, opts)
        vim.keymap.set("n", "<Leader>hD", function() gs.diffthis("~") end, opts)
        -- Text object
        vim.keymap.set({ "o", "x" }, "ih", "<Cmd>Gitsigns select_hunk<CR>", opts)
      end,
    },
  },

  -- neogit: Magit-like Git UI
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<Leader>gg", "<Cmd>Neogit<CR>", desc = "Neogit" },
    },
    opts = {
      integrations = { diffview = true, telescope = true },
    },
  },

  -- diffview: diff viewer
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<Leader>gd", "<Cmd>DiffviewOpen<CR>",   desc = "DiffView open" },
      { "<Leader>gD", "<Cmd>DiffviewClose<CR>",  desc = "DiffView close" },
      { "<Leader>gh", "<Cmd>DiffviewFileHistory %<CR>", desc = "File history" },
    },
    opts = {},
  },

  -- git-conflict: conflict resolution
  {
    "akinsho/git-conflict.nvim",
    event = "BufReadPost",
    opts = {
      default_mappings = true,
      default_commands = true,
      disable_diagnostics = false,
    },
  },
}
