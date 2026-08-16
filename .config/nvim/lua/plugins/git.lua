return {
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
        local gs = require("gitsigns")
        local opts = { buffer = bufnr, noremap = true, silent = true }

        vim.keymap.set("n", "]h", function() gs.nav_hunk("next") end, opts)
        vim.keymap.set("n", "[h", function() gs.nav_hunk("prev") end, opts)
        vim.keymap.set({ "n", "v" }, "<Leader>gs", "<Cmd>Gitsigns stage_hunk<CR>", opts)
        vim.keymap.set({ "n", "v" }, "<Leader>gr", "<Cmd>Gitsigns reset_hunk<CR>", opts)
        vim.keymap.set("n", "<Leader>gS", gs.stage_buffer, opts)
        vim.keymap.set("n", "<Leader>gu", gs.undo_stage_hunk, opts)
        vim.keymap.set("n", "<Leader>gp", gs.preview_hunk, opts)
        vim.keymap.set("n", "<Leader>gb", function() gs.blame_line({ full = true }) end, opts)
        vim.keymap.set("n", "<Leader>gB", gs.toggle_current_line_blame, opts)
        vim.keymap.set({ "o", "x" }, "ih", "<Cmd>Gitsigns select_hunk<CR>", opts)
      end,
    },
  },

  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = { "CodeDiff" },
    keys = {
      { "<Leader>gd", "<Cmd>CodeDiff<CR>",                   desc = "Working tree diff" },
      { "<Leader>gh", "<Cmd>CodeDiff history %<CR>",         desc = "File history" },
      { "<Leader>gH", "<Cmd>CodeDiff history<CR>",           desc = "Repository history" },
      { "<Leader>gm", "<Cmd>CodeDiff origin/main...HEAD<CR>", desc = "Review branch vs main" },
    },
    opts = {
      explorer = {
        view_mode = "tree",
        indent_markers = true,
        width = 32,
      },
    },
  },
}
