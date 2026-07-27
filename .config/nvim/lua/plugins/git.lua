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

        -- git is one noun, so it gets one namespace: <Leader>g.
        -- (These used to live under <Leader>h, which named the *object* rather
        -- than the tool and left git split across two prefixes.)
        vim.keymap.set("n", "]h", gs.next_hunk, opts)
        vim.keymap.set("n", "[h", gs.prev_hunk, opts)
        vim.keymap.set({ "n", "v" }, "<Leader>gs", "<Cmd>Gitsigns stage_hunk<CR>", opts)
        vim.keymap.set({ "n", "v" }, "<Leader>gr", "<Cmd>Gitsigns reset_hunk<CR>", opts)
        vim.keymap.set("n", "<Leader>gS", gs.stage_buffer, opts)
        vim.keymap.set("n", "<Leader>gu", gs.undo_stage_hunk, opts)
        vim.keymap.set("n", "<Leader>gp", gs.preview_hunk, opts)
        vim.keymap.set("n", "<Leader>gb", function() gs.blame_line({ full = true }) end, opts)
        vim.keymap.set("n", "<Leader>gB", gs.toggle_current_line_blame, opts)
        -- Hunk as a text object: dih, vih, yih.
        vim.keymap.set({ "o", "x" }, "ih", "<Cmd>Gitsigns select_hunk<CR>", opts)
      end,
    },
  },

  -- neogit removed: lazygit (<Leader>gl, via snacks) covers the same job,
  -- and survives nvim restarts because it is a separate process.

  -- diffview: diff viewer. This is the main tool for reading what an agent did.
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<Leader>gd", "<Cmd>DiffviewOpen<CR>",          desc = "Diffview open" },
      { "<Leader>gD", "<Cmd>DiffviewClose<CR>",         desc = "Diffview close" },
      { "<Leader>gh", "<Cmd>DiffviewFileHistory %<CR>", desc = "File history" },
      -- The review diff: what this branch does to main, as one change.
      { "<Leader>gm", "<Cmd>DiffviewOpen origin/main...HEAD<CR>", desc = "Review branch vs main" },
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
