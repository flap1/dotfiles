-- Telescope: fuzzy finder + extensions

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-frecency.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "benfowler/telescope-luasnip.nvim",
      "jvgrootveld/telescope-zoxide",
    },
    -- <Leader>f is the `find` namespace. Everything that answers "where is X"
    -- lives here and nowhere else. Rare pickers (marks, registers, commands,
    -- snippets) are intentionally unbound — `:Telescope <name>` is enough.
    keys = {
      -- hidden but not no_ignore: dotfiles are things you edit, build output is
      -- not. In a Rust worktree target/ alone is six figures of files, and every
      -- one of them competes with the file you meant. The sidebar still shows
      -- them, and `:Telescope find_files no_ignore=true` is there on the rare
      -- day you want to search one.
      { "<Leader>ff", "<Cmd>Telescope find_files follow=true hidden=true<CR>", desc = "Files" },
      { "<Leader>fg", "<Cmd>Telescope live_grep<CR>",   desc = "Grep" },
      { "<Leader>fw", "<Cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
      { "<Leader>fb", "<Cmd>Telescope buffers<CR>",     desc = "Buffers" },
      { "<Leader>fr", "<Cmd>Telescope frecency<CR>",    desc = "Recent (frecency)" },
      { "<Leader>fz", "<Cmd>Telescope zoxide list<CR>", desc = "Directories (zoxide)" },
      { "<Leader>f/", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "In this buffer" },
      { "<Leader>fs", "<Cmd>Telescope lsp_document_symbols<CR>",  desc = "Symbols (file)" },
      { "<Leader>fS", "<Cmd>Telescope lsp_workspace_symbols<CR>", desc = "Symbols (project)" },
      { "<Leader>fh", "<Cmd>Telescope help_tags<CR>",   desc = "Help" },
      { "<Leader>fk", "<Cmd>Telescope keymaps<CR>",     desc = "Keymaps" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            vertical   = { mirror = false },
            width = 0.87, height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ["<C-n>"]  = actions.cycle_history_next,
              ["<C-p>"]  = actions.cycle_history_prev,
              ["<C-j>"]  = actions.move_selection_next,
              ["<C-k>"]  = actions.move_selection_previous,
              ["<C-q>"]  = actions.send_to_qflist + actions.open_qflist,
              ["<Esc>"]  = actions.close,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          frecency = {
            show_scores = false,
            show_unindexed = true,
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("frecency")
      telescope.load_extension("luasnip")
      telescope.load_extension("zoxide")
    end,
  },
}
