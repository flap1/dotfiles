require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "lua",
    "html",
    "python",
    "markdown",
    "javascript",
  },
  highlight = {
    enable = true,
    use_languagetree = true,
  },
  yati = { enable = true },
}
