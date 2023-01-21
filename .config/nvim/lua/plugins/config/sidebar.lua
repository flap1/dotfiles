require("sidebar-nvim").setup({
  disable_default_keybindings = 0,
  bindings = {
    ["q"] = function()
      require("sidebar-nvim").close()
    end,
  },
  files = {
    icon = "",
    show_hidden = true,
    ignored_paths = { "%.git$" }
  },
  open = false,
  side = "right",
  initial_width = 35,
  update_interval = 1000,
  sections = { "datetime", "buffers", "git", "diagnostics", "todos" },
  section_separator = "-----",
})

vim.keymap.set("n", "<M-s>", "<Cmd>SidebarNvimToggle<CR>", { noremap = true, silent = true })
