require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "lua",
    "vim",
    "bash",
    "html",
    "yaml",
    "python",
    "toml",
    "markdown",
    "markdown_inline",
    "javascript",
  },
  highlight = {
    enable = true,
    use_languagetree = true,
    disable = function(_, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
  },
  context_commentstring = { enable = true },
  yati = { enable = true, disable = { "markdown" } },
  tree_setter = { enable = true },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 300,
    disable = { "cpp" }, -- please disable lua and bash for now
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  }
}
