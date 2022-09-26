require("telescope").setup {
  defaults = {
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
  },
}

local opts = { noremap = true, silent = true }

-- find ------------------------------------------
vim.keymap.set("n", "[ff]i", "<Cmd>Telescope find_files<CR>", opts) -- ignore dotfiles
vim.keymap.set("n", "[ff]e", "<Cmd>Telescope frecency<CR>", opts) -- telescope-frecency
vim.keymap.set("n", "[ff]w", "<Cmd>Telescope live_grep<CR>", opts)
vim.keymap.set("n", "[ff]f", "<Cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", opts)
vim.keymap.set("n", "[ff]b", "<Cmd>Telescope buffers<CR>", opts)
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
vim.keymap.set("n", "[ff]l", "<Cmd>Telescope loclist<CR>", opts)
vim.keymap.set("n", "[ff]s", "<Cmd>Telescope luasnip<CR>", opts) -- telescope-luasnip
vim.keymap.set("n", "[ff];", "<Cmd>Telescope git_files<CR>", opts)

-- git -------------------------------------------
vim.keymap.set("n", "<Leader>gc", "<Cmd>Telescope git_commits<CR>", opts)
vim.keymap.set("n", "<Leader>gs", "<Cmd>Telescope git_status<CR>", opts)
vim.keymap.set("n", "<Leader>gC", "<Cmd>Telescope git_bcommits<CR>", opts)
vim.keymap.set("n", "<Leader>gb", "<Cmd>Telescope git_branches<CR>", opts)
