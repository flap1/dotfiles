return {
  { "nvim-lua/plenary.nvim", lazy = true },
  { "kkharji/sqlite.lua", lazy = true },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-frecency.nvim",
    },
    keys = {
      { "<Leader>ff", "<Cmd>Telescope find_files follow=true hidden=true<CR>", desc = "Files" },
      { "<Leader>fg", "<Cmd>Telescope live_grep<CR>",   desc = "Grep" },
      { "<Leader>fw", "<Cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
      { "<Leader>fb", "<Cmd>Telescope buffers<CR>",     desc = "Buffers" },
      { "<Leader>fr", "<Cmd>Telescope frecency<CR>",    desc = "Recent (frecency)" },
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
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
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
    end,
  },
}
