-- Telescope: fuzzy finder + extensions

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-lua/popup.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "benfowler/telescope-luasnip.nvim",
      "nvim-telescope/telescope-bibtex.nvim",
      "jvgrootveld/telescope-zoxide",
    },
    keys = {
      -- Files
      { "<M-f>f", "<Cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", desc = "Find files" },
      { "<M-f>e", "<Cmd>Telescope frecency<CR>",       desc = "Frecency files" },
      { "<M-f>z", "<Cmd>Telescope zoxide list<CR>",    desc = "Zoxide dirs" },
      { "<M-f>o", "<Cmd>Telescope oldfiles<CR>",       desc = "Recent files" },
      { "<M-f>b", "<Cmd>Telescope file_browser<CR>",   desc = "File browser" },
      -- Text
      { "<M-f>j", "<Cmd>Telescope live_grep<CR>",      desc = "Live grep" },
      { "<M-f>s", "<Cmd>Telescope grep_string<CR>",    desc = "Grep string" },
      -- Buffers / misc
      { "<M-f>l", "<Cmd>Telescope buffers<CR>",        desc = "Buffers" },
      { "<M-f>m", "<Cmd>Telescope marks<CR>",          desc = "Marks" },
      { "<M-f>r", "<Cmd>Telescope registers<CR>",      desc = "Registers" },
      { "<M-f>k", "<Cmd>Telescope keymaps<CR>",        desc = "Keymaps" },
      { "<M-f>c", "<Cmd>Telescope commands<CR>",       desc = "Commands" },
      { "<M-f>h", "<Cmd>Telescope help_tags<CR>",      desc = "Help" },
      { "<M-f>n", "<Cmd>Telescope luasnip<CR>",        desc = "Snippets" },
      { "<M-f>/", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Buffer fuzzy" },
      -- Git
      { "<M-f>gc", "<Cmd>Telescope git_commits<CR>",   desc = "Git commits" },
      { "<M-f>gs", "<Cmd>Telescope git_status<CR>",    desc = "Git status" },
      { "<M-f>gb", "<Cmd>Telescope git_branches<CR>",  desc = "Git branches" },
      -- LSP
      { "<M-f>ds", "<Cmd>Telescope lsp_document_symbols<CR>",  desc = "Document symbols" },
      { "<M-f>ws", "<Cmd>Telescope lsp_workspace_symbols<CR>", desc = "Workspace symbols" },
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
          file_browser = {
            hijack_netrw = true,
          },
          frecency = {
            show_scores = false,
            show_unindexed = true,
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
      telescope.load_extension("frecency")
      telescope.load_extension("luasnip")
      telescope.load_extension("zoxide")
    end,
  },
}
