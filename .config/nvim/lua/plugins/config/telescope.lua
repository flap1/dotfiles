local fb_actions = require "telescope".extensions.file_browser.actions
local base_dirs = {
  '~/dotfiles',
}
local action_layout = require("telescope.actions.layout")
local actions = require("telescope.actions")

-- Custom actions
local transform_mod = require("telescope.actions.mt").transform_mod
local nvb_actions = transform_mod {
  yank_content = function(prompt_bufnr)
    -- Get selected entry and the file full path
    local content = require("telescope.actions.state").get_selected_entry()

    -- Yank the path to unnamed register
    vim.fn.setreg('+', content.value)

    -- Close the popup
    require("telescope.actions").close(prompt_bufnr)
  end,
}

require("telescope").setup {
  defaults = {
    prompt_prefix = " ",
    mappings = {
      n = {
        ["<esc>"] = actions.close,
        ["<Leader>q"] = actions.close,
        ["<M-p>"] = action_layout.toggle_preview
      },
      i = {
        ["<esc>"] = actions.close,
        ["<Leader>q"] = actions.close,
        ["<C-i>"] = require("telescope").extensions.hop.hop,
        ["<C-u>"] = false, -- disable C-u
        -- custom hop loop to multi selects and sending selected entries to quickfix list
        ["<C-space>"] = function(prompt_bufnr)
          local opts = {
            callback = actions.toggle_selection,
            loop_callback = actions.send_selected_to_qflist,
          }
          require("telescope").extensions.hop._hop_loop(prompt_bufnr, opts)
        end,
        ["<M-p>"] = action_layout.toggle_preview
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
  pickers = {
    -- https://github.com/nvim-telescope/telescope.nvim
    find_files = {theme = "ivy", mappings = {n = {["y"] = nvb_actions.yank_content}, i = {["<C-y>"] = nvb_actions.yank_content}}},
    live_grep = {theme = "ivy", mappings = {n = {["y"] = nvb_actions.yank_content}, i = {["<C-y>"] = nvb_actions.yank_content}}},
    command_history = {theme = "ivy", mappings = {n = {["y"] = nvb_actions.yank_content}, i = {["<C-y>"] = nvb_actions.yank_content}}},
    keymaps = {theme = "ivy", mappings = {n = {["y"] = nvb_actions.yank_content}, i = {["<C-y>"] = nvb_actions.yank_content}}},
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
      -- Template for the formatted citation citation_format = '{{author}} ({{year}}), {{title}}.',
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
    file_browser = {
      mappings = {
        ["i"] = {
          ["<C-w>"] = fb_actions.change_cwd,
          ["<C-t>"] = false
        },
        ["n"] = {
          ["x"] = fb_actions.change_cwd
        },
      },
    },
    hop = {
      -- Highlight groups to link to signs and lines; the below configuration refers to demo
      -- sign_hl typically only defines foreground to possibly be combined with line_hl
      sign_hl = { "WarningMsg", "Title" },
      -- optional, typically a table of two highlight groups that are alternated between
      line_hl = { "CursorLine", "Normal" },
      -- options specific to `hop_loop`
      -- true temporarily disables Telescope selection highlighting
      clear_selection_hl = false,
      -- highlight hopped to entry with telescope selection highlight
      -- note: mutually exclusive with `clear_selection_hl`
      trace_entry = true,
      -- jump to entry where hoop loop was started from
      reset_selection = true,
    },
    project = {
      base_dirs = base_dirs,
      hidden_files = true, -- default: false
      theme = "dropdown",
      order_by = "asc"
    },
    bookmarks = {
      selected_browser = 'vivaldi',
      -- Either provide a shell command to open the URL
      url_open_command = 'open',
      -- Or provide the plugin name which is already installed
      -- Available: 'vim_external', 'open_browser'
      url_open_plugin = nil,
      -- Show the full path to the bookmark instead of just the bookmark name
      full_path = true,
      -- Provide a custom profile name for Firefox browser
      firefox_profile_name = nil,
      -- Provide a custom profile name for Waterfox browser
      waterfox_profile_name = nil,
      -- Add a column which contains the tags for each bookmark for buku
      buku_include_tags = false,
      -- Provide debug messages
      debug = false,
    },
  },
}
local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<C-p>', "<Cmd>lua require'telescope'.extensions.project.project{}<CR>", opts)
vim.keymap.set('n', '<M-p>', "<Cmd>lua require'telescope'.extensions.project.project{}<CR>", opts)
vim.keymap.set('i', '<M-p>', "<Esc><Cmd>lua require'telescope'.extensions.project.project{}<CR>", opts)
vim.keymap.set('t', '<M-p>', "<C-\\><C-n><Cmd>lua require'telescope'.extensions.project.project{}<CR>", opts)

-- find ------------------------------------------
vim.keymap.set("n", "[ff]x", "<Cmd>Telescope find_files<CR>", opts) -- ignore(x) dotfiles
vim.keymap.set("n", "[ff]e", "<Cmd>Telescope frecency<CR>", opts) -- telescope-frecency
vim.keymap.set("n", "[ff]u", "<Cmd>Telescope symbols<CR>", opts) -- telescope-symbols, unicode
vim.keymap.set("n", "[ff]j", "<Cmd>Telescope live_grep<CR>", opts)
vim.keymap.set("n", "[ff]f", "<Cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", opts)
vim.keymap.set("n", "[ff]<Leader>", "<Cmd>Telescope buffers<CR>", opts)
vim.keymap.set("n", "[ff]@", "<Cmd>Telescope bibtex<CR>", opts) -- telescope-bibtex
vim.keymap.set("n", "[ff]c", "<Cmd>Telescope command_history<CR>", opts)
vim.keymap.set("n", "[ff]h", "<Cmd>Telescope help_tags<CR>", opts)
vim.keymap.set("n", "[ff]t", "<Cmd>Telescope treesitter<CR>", opts)
vim.keymap.set("n", "[ff]o", "<Cmd>Telescope oldfiles<CR>", opts)
vim.keymap.set("n", "[ff]k", "<Cmd>Telescope keymaps<CR>", opts)
vim.keymap.set("n", "[ff]m", "<Cmd>Telescope marks<CR>", opts)
vim.keymap.set("n", "[ff]/", "<Cmd>Telescope search_history<CR>", opts)
vim.keymap.set("n", "[ff]r", "<Cmd>Telescope registers<CR>", opts)
vim.keymap.set("n", '"', "<Cmd>Telescope registers<CR>", opts)
vim.keymap.set("n", "[ff]q", "<Cmd>Telescope quickfix<CR>", opts)
vim.keymap.set("n", "[ff]p", "<Cmd>Telescope packer<CR>", opts) -- telescope-packer
vim.keymap.set("n", "[ff]a", "<Cmd>Telescope loclist<CR>", opts) -- under q
vim.keymap.set("n", "[ff]l", "<Cmd>Telescope luasnip<CR>", opts) -- telescope-luasnip
vim.keymap.set("n", "[ff];", "<Cmd>Telescope git_files<CR>", opts)
vim.keymap.set("n", "[ff]b", "<Cmd>Telescope file_browser hidden=true<CR>", opts) -- file-browser
vim.keymap.set("n", "[ff]i", "<Cmd>Telescope media_files<CR>", opts) -- telescope-media_files, images
vim.keymap.set("n", "<Leader>b", "<Cmd>Telescope bookmarks<CR>", opts) -- telescope-bookmarks

-- find ------------------------------------------
vim.keymap.set("t", "<M-f>x", "<C-\\><C-n><Cmd>Telescope find_files<CR>", opts) -- ignore(x) dotfiles
vim.keymap.set("t", "<M-f>e", "<C-\\><C-n><Cmd>Telescope frecency<CR>", opts) -- telescope-frecency
vim.keymap.set("t", "<M-f>u", "<C-\\><C-n><Cmd>Telescope symbols<CR>", opts) -- telescope-symbols, unicode
vim.keymap.set("t", "<M-f>j", "<C-\\><C-n><Cmd>Telescope live_grep<CR>", opts)
vim.keymap.set("t", "<M-f>f", "<C-\\><C-n><Cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", opts)
vim.keymap.set("t", "<M-f><Leader>", "<C-\\><C-n><Cmd>Telescope buffers<CR>", opts)
vim.keymap.set("t", "<M-f>@", "<C-\\><C-n><Cmd>Telescope bibtex<CR>", opts) -- telescope-bibtex
vim.keymap.set("t", "<M-f>c", "<C-\\><C-n><Cmd>Telescope command_history<CR>", opts)
vim.keymap.set("t", "<M-f>h", "<C-\\><C-n><Cmd>Telescope help_tags<CR>", opts)
vim.keymap.set("t", "<M-f>t", "<C-\\><C-n><Cmd>Telescope treesitter<CR>", opts)
vim.keymap.set("t", "<M-f>o", "<C-\\><C-n><Cmd>Telescope oldfiles<CR>", opts)
vim.keymap.set("t", "<M-f>k", "<C-\\><C-n><Cmd>Telescope keymaps<CR>", opts)
vim.keymap.set("t", "<M-f>m", "<C-\\><C-n><Cmd>Telescope marks<CR>", opts)
vim.keymap.set("t", "<M-f>/", "<C-\\><C-n><Cmd>Telescope search_history<CR>", opts)
vim.keymap.set("t", "<M-f>r", "<C-\\><C-n><Cmd>Telescope registers<CR>", opts)
vim.keymap.set("t", "<M-f>q", "<C-\\><C-n><Cmd>Telescope quickfix<CR>", opts)
vim.keymap.set("t", "<M-f>p", "<C-\\><C-n><Cmd>Telescope packer<CR>", opts) -- telescope-packer
vim.keymap.set("t", "<M-f>a", "<C-\\><C-n><Cmd>Telescope loclist<CR>", opts) -- under q
vim.keymap.set("t", "<M-f>l", "<C-\\><C-n><Cmd>Telescope luasnip<CR>", opts) -- telescope-luasnip
vim.keymap.set("t", "<M-f>;", "<C-\\><C-n><Cmd>Telescope git_files<CR>", opts)
vim.keymap.set("t", "<M-f>b", "<C-\\><C-n><Cmd>Telescope file_browser hidden=true<CR>", opts) -- file-browser
vim.keymap.set("t", "<M-f>i", "<C-\\><C-n><Cmd>Telescope media_files<CR>", opts) -- telescope-media_files, images

vim.keymap.set("i", "<M-f>x", "<Esc><Cmd>Telescope find_files<CR>", opts) -- ignore(x) dotfiles
vim.keymap.set("i", "<M-f>e", "<Esc><Cmd>Telescope frecency<CR>", opts) -- telescope-frecency
vim.keymap.set("i", "<M-f>u", "<Esc><Cmd>Telescope symbols<CR>", opts) -- telescope-symbols, unicode
vim.keymap.set("i", "<M-f>j", "<Esc><Cmd>Telescope live_grep<CR>", opts)
vim.keymap.set("i", "<M-f>f", "<Esc><Cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", opts)
vim.keymap.set("i", "<M-f><Leader>", "<Esc><Cmd>Telescope buffers<CR>", opts)
vim.keymap.set("i", "<M-f>@", "<Esc><Cmd>Telescope bibtex<CR>", opts) -- telescope-bibtex
vim.keymap.set("i", "<M-f>c", "<Esc><Cmd>Telescope command_history<CR>", opts)
vim.keymap.set("i", "<M-f>h", "<Esc><Cmd>Telescope help_tags<CR>", opts)
vim.keymap.set("i", "<M-f>t", "<Esc><Cmd>Telescope treesitter<CR>", opts)
vim.keymap.set("i", "<M-f>o", "<Esc><Cmd>Telescope oldfiles<CR>", opts)
vim.keymap.set("i", "<M-f>k", "<Esc><Cmd>Telescope keymaps<CR>", opts)
vim.keymap.set("i", "<M-f>m", "<Esc><Cmd>Telescope marks<CR>", opts)
vim.keymap.set("i", "<M-f>/", "<Esc><Cmd>Telescope search_history<CR>", opts)
vim.keymap.set("i", "<M-f>r", "<Esc><Cmd>Telescope registers<CR>", opts)
vim.keymap.set("i", "<M-f>q", "<Esc><Cmd>Telescope quickfix<CR>", opts)
vim.keymap.set("i", "<M-f>p", "<Esc><Cmd>Telescope packer<CR>", opts) -- telescope-packer
vim.keymap.set("i", "<M-f>a", "<Esc><Cmd>Telescope loclist<CR>", opts) -- under q
vim.keymap.set("i", "<M-f>l", "<Esc><Cmd>Telescope luasnip<CR>", opts) -- telescope-luasnip
vim.keymap.set("i", "<M-f>;", "<Esc><Cmd>Telescope git_files<CR>", opts)
vim.keymap.set("i", "<M-f>b", "<Esc><Cmd>Telescope file_browser hidden=true<CR>", opts) -- file-browser
vim.keymap.set("i", "<M-f>i", "<Esc><Cmd>Telescope media_files<CR>", opts) -- telescope-media_files, images

vim.keymap.set("n", "<M-f>x", "<Cmd>Telescope find_files<CR>", opts) -- ignore(x) dotfiles
vim.keymap.set("n", "<M-f>e", "<Cmd>Telescope frecency<CR>", opts) -- telescope-frecency
vim.keymap.set("n", "<M-f>u", "<Cmd>Telescope symbols<CR>", opts) -- telescope-symbols, unicode
vim.keymap.set("n", "<M-f>j", "<Cmd>Telescope live_grep<CR>", opts)
vim.keymap.set("n", "<M-f>f", "<Cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", opts)
vim.keymap.set("n", "<M-f><Leader>", "<Cmd>Telescope buffers<CR>", opts)
vim.keymap.set("n", "<M-f>@", "<Cmd>Telescope bibtex<CR>", opts) -- telescope-bibtex
vim.keymap.set("n", "<M-f>c", "<Cmd>Telescope command_history<CR>", opts)
vim.keymap.set("n", "<M-f>h", "<Cmd>Telescope help_tags<CR>", opts)
vim.keymap.set("n", "<M-f>t", "<Cmd>Telescope treesitter<CR>", opts)
vim.keymap.set("n", "<M-f>o", "<Cmd>Telescope oldfiles<CR>", opts)
vim.keymap.set("n", "<M-f>k", "<Cmd>Telescope keymaps<CR>", opts)
vim.keymap.set("n", "<M-f>m", "<Cmd>Telescope marks<CR>", opts)
vim.keymap.set("n", "<M-f>/", "<Cmd>Telescope search_history<CR>", opts)
vim.keymap.set("n", "<M-f>r", "<Cmd>Telescope registers<CR>", opts)
vim.keymap.set("n", "<M-f>q", "<Cmd>Telescope quickfix<CR>", opts)
vim.keymap.set("n", "<M-f>p", "<Cmd>Telescope packer<CR>", opts) -- telescope-packer
vim.keymap.set("n", "<M-f>a", "<Cmd>Telescope loclist<CR>", opts) -- under q
vim.keymap.set("n", "<M-f>l", "<Cmd>Telescope luasnip<CR>", opts) -- telescope-luasnip
vim.keymap.set("n", "<M-f>;", "<Cmd>Telescope git_files<CR>", opts)
vim.keymap.set("n", "<M-f>b", "<Cmd>Telescope file_browser hidden=true<CR>", opts) -- file-browser
vim.keymap.set("n", "<M-f>i", "<Cmd>Telescope media_files<CR>", opts) -- telescope-media_files, images

-- git -------------------------------------------
vim.keymap.set("n", "[ff]gc", "<Cmd>Telescope git_commits<CR>", opts)
vim.keymap.set("n", "[ff]gs", "<Cmd>Telescope git_status<CR>", opts)
vim.keymap.set("n", "[ff]gC", "<Cmd>Telescope git_bcommits<CR>", opts)
vim.keymap.set("n", "[ff]gb", "<Cmd>Telescope git_branches<CR>", opts)
