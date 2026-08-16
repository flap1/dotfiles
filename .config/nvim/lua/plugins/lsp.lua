-- LSP stack: mason + nvim-lspconfig + conform.nvim + nvim-lint
-- Uses Neovim 0.11+ native vim.lsp.config() / vim.lsp.enable() API

return {
  -- Mason: :Mason / :LspInstall only. Opening a file does not load this
  -- plugin and does not hit the network. Servers come from PATH (mise, or
  -- whatever :Mason already put on it).
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = { ui = { border = "rounded" } },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    cmd = { "LspInstall", "LspUninstall" },
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {},
      automatic_enable = false,
    },
  },

  -- nvim-lspconfig: configure language servers via vim.lsp.config() (Nvim 0.11+)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "saghen/blink.cmp",
      "folke/lazydev.nvim",
    },
    config = function()
      -- Diagnostic signs
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN]  = "W",
            [vim.diagnostic.severity.HINT]  = "H",
            [vim.diagnostic.severity.INFO]  = "I",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- LspAttach: set buffer-local LSP keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local bufnr = ev.buf
          local opts = { noremap = true, silent = true, buffer = bufnr }

          -- `g` is goto: navigation only.
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
          -- K (hover) and <C-s> (signature help, insert mode) are Neovim
          -- defaults as of 0.11 and are left alone.

          -- <Leader>c is code: actions on the buffer, not movement through it.
          vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<Leader>cr", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "x" }, "<Leader>cf", function()
            require("conform").format({ bufnr = bufnr, async = true })
          end, opts)
          vim.keymap.set("n", "<Leader>cd", vim.diagnostic.open_float, opts)

          -- Diagnostics join the [ / ] family.
          vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
          vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
        end,
      })

      -- Base config applied to all servers
      vim.lsp.config("*", {
        capabilities = capabilities,
        root_markers = { ".git" },
      })

      -- Per-server overrides using vim.lsp.config()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
              severity = { ["missing-parameter"] = "Hint" },
            },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("clangd", {
        cmd = { "clangd", "--background-index", "--clang-tidy",
          "--cross-file-rename", "--completion-style=detailed" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
      })

      -- No remark_ls. Without a .remarkrc and per-project remark plugins it
      -- lints nothing, and unified-language-server crashes every time because
      -- workspace/configuration comes back null. markdownlint (nvim-lint) and
      -- prettier (conform) cover markdown.

      vim.lsp.config("tinymist", {
        -- attach even outside a git repo; typst notes often live as loose files
        root_markers = { ".git", "typst.toml" },
        single_file_support = true,
        settings = {
          -- typstyle ships inside tinymist, no separate install
          formatterMode = "typstyle",
          exportPdf = "onType",
          -- treesitter already highlights typst; semantic tokens fight it
          semanticTokens = "disable",
        },
      })

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = { typeCheckingMode = "basic" },
          },
        },
      })

      -- Enable all servers except rust_analyzer (handled by rustaceanvim)
      vim.lsp.enable({
        "lua_ls", "clangd",
        "pyright", "ts_ls", "jsonls", "yamlls",
        "tinymist",
      })
    end,
  },

  -- lazydev: Neovim Lua API completion (neodev replacement)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {},
  },

  -- conform.nvim: formatter
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
    -- No keys here: <Leader>cf is bound on LspAttach, and format-on-save
    -- covers the rest. A second format binding for the no-LSP case is not
    -- worth a key.
  },

  -- nvim-lint: linter
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = {
        markdown = { "markdownlint" },
        python = { "ruff" },
        sh = { "shellcheck" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
