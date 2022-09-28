require("telescope").setup {
  defaults = {
    mappings = {
      n = {
        ["<esc>"] = require('telescope.actions').close,
        ["<Leader>q"] = require('telescope.actions').close,
      },
      i = {
        ["<esc>"] = require('telescope.actions').close,
        ["<Leader>q"] = require('telescope.actions').close,
      }
    },
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
    }
  },
  extensions = {
    frecency = {
      db_root = vim.fn.stdpath("state"),
      ignore_patterns = { "*.git/*", "*/tmp/*", "*/node_modules/*" },
      db_safe_mode = false,
      auto_validate = true,
    },
    bibtex = {
      -- Depth for the *.bib file
      depth = 1,
      -- Custom format for citation label
      custom_formats = {},
      -- Format to use for citation label.
      -- Try to match the filetype by default, or use 'plain'
      format = 'tex',
      -- Path to global bibliographies (placed outside of the project)
      global_files = { "~/.config/nvim/bibtex/paperpile.bib" },
      -- Define the search keys to use in the picker
      search_keys = { 'author', 'year', 'title' },
      -- Template for the formatted citation
      citation_format = '{{author}} ({{year}}), {{title}}.',
      -- Only use initials for the authors first name
      citation_trim_firstname = true,
      -- Max number of authors to write in the formatted citation
      -- following authors will be replaced by "et al."
      citation_max_auth = 3,
      -- Context awareness disabled by default
      context = true,
      -- Fallback to global/directory .bib files if context not found
      -- This setting has no effect if context = false
      context_fallback = true,
      -- Wrapping in the preview window is disabled by default
      wrap = false,
    },
  },
}

local opts = { noremap = true, silent = true }

-- find ------------------------------------------
vim.keymap.set("n", "[ff]i", "<Cmd>Telescope find_files<CR>", opts) -- ignore dotfiles
vim.keymap.set("n", "[ff]e", "<Cmd>Telescope frecency<CR>", opts) -- telescope-frecency
vim.keymap.set("n", "[ff]u", "<Cmd>Telescope symbols<CR>", opts) -- telescope-symbols, unicode
vim.keymap.set("n", "[ff]w", "<Cmd>Telescope live_grep<CR>", opts)
vim.keymap.set("n", "[ff]f", "<Cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", opts)
vim.keymap.set("n", "[ff]<Leader>", "<Cmd>Telescope buffers<CR>", opts)
vim.keymap.set("n", "[ff]@", "<Cmd>Telescope bibtex<CR>", opts) -- telescope-bibtex
vim.keymap.set("n", "[ff]c", "<Cmd>Telescope commands<CR>", opts)
vim.keymap.set("n", "[ff]h", "<Cmd>Telescope help_tags<CR>", opts)
vim.keymap.set("n", "[ff]t", "<Cmd>Telescope treesitter<CR>", opts)
vim.keymap.set("n", "[ff]o", "<Cmd>Telescope oldfiles<CR>", opts)
vim.keymap.set("n", "[ff]k", "<Cmd>Telescope keymaps<CR>", opts)
vim.keymap.set("n", "[ff]m", "<Cmd>Telescope marks<CR>", opts)
vim.keymap.set("n", "[ff]/", "<Cmd>Telescope search_history<CR>", opts)
vim.keymap.set("n", "[ff]r", "<Cmd>Telescope registers<CR>", opts)
vim.keymap.set("n", "[ff]q", "<Cmd>Telescope quickfix<CR>", opts)
vim.keymap.set("n", "[ff]p", "<Cmd>Telescope packer<CR>", opts) -- telescope-packer
vim.keymap.set("n", "[ff]a", "<Cmd>Telescope loclist<CR>", opts) -- under q
vim.keymap.set("n", "[ff]l", "<Cmd>Telescope luasnip<CR>", opts) -- telescope-luasnip
vim.keymap.set("n", "[ff];", "<Cmd>Telescope git_files<CR>", opts)
vim.keymap.set("n", "[ff]y", "<Cmd>Telescope neoclip<CR>", opts) -- neoclip
vim.keymap.set("n", "[ff]b", "<Cmd>Telescope file_browser hidden=true<CR>", opts) -- file-browser

-- git -------------------------------------------
vim.keymap.set("n", "[ff]gc", "<Cmd>Telescope git_commits<CR>", opts)
vim.keymap.set("n", "[ff]gs", "<Cmd>Telescope git_status<CR>", opts)
vim.keymap.set("n", "[ff]gC", "<Cmd>Telescope git_bcommits<CR>", opts)
vim.keymap.set("n", "[ff]gb", "<Cmd>Telescope git_branches<CR>", opts)
