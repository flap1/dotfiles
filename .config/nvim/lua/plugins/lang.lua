-- Language-specific plugins

return {
  -- rustaceanvim: Rust support (replaces rust-tools.nvim)
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

  -- render-markdown: in-buffer markdown rendering (replaces markdown-preview.nvim,
  -- which needed a node build step and pushed you out to a browser)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      -- keep the rendering visible while editing; only reveal source on the cursor line
      anti_conceal = { enabled = true },
    },
  },

  -- typst-preview: live browser preview for Typst.
  -- tinymist itself has no built-in preview; this is the upstream-recommended plugin.
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {
      -- Bind to the tailscale address instead of the default 127.0.0.1, so the
      -- preview is reachable from any tailnet device (the Windows browser, the
      -- phone) at http://<this-host>:<port> with no port forwarding. Falls back to
      -- loopback when tailscale is down, which is the old behaviour.
      host = (function()
        local ip = vim.fn.systemlist("tailscale ip -4")[1]
        return (vim.v.shell_error == 0 and ip and ip:match("^%d+%.")) and ip or "127.0.0.1"
      end)(),
      -- Fixed port so the URL is stable and bookmarkable (default 0 = random).
      port = 23625,
      -- reuse the mason-installed tinymist instead of letting the plugin
      -- download a second 72MB copy of its own
      dependencies_bin = { tinymist = "tinymist" },
      -- Do not try to launch a browser on this headless box; open the URL
      -- yourself on whichever tailnet device you are sitting at.
      open_cmd = "echo 'typst preview: %s' >/dev/null",
    },
  },

  -- table-mode / quickrun removed: tables get formatted by prettier via conform,
  -- and running code belongs in a tmux pane where the output survives.

  -- neodev / lazydev already in lsp.lua for lua_ls
  -- Notes live in Obsidian, not in nvim (telekasten removed).
}
