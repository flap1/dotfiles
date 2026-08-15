return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = "rust",
    opts = {
      server = {
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
            cargo = { allFeatures = true },
            procMacro = { enable = true },
          },
        },
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = opts
    end,
  },

  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {
      host = (function()
        local ip = vim.fn.systemlist("tailscale ip -4")[1]
        return (vim.v.shell_error == 0 and ip and ip:match("^%d+%.")) and ip or "127.0.0.1"
      end)(),
      port = 23625,
      dependencies_bin = { tinymist = "tinymist" },
      open_cmd = "echo 'typst preview: %s' >/dev/null",
    },
  },
}
