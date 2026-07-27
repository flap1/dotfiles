-- LSP stack: mason + nvim-lspconfig + conform.nvim + nvim-lint
-- Uses Neovim 0.11+ native vim.lsp.config() / vim.lsp.enable() API

return {
  -- Mason: LSP/formatter/linter installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ui = { border = "rounded" },
      ensure_installed = {
        -- formatters
        "stylua", "prettier", "ruff",
        -- linters
        "markdownlint",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      -- Auto-install ensure_installed tools
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, tool in ipairs(opts.ensure_installed or {}) do
          local p = registry.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },

  -- mason-lspconfig: install LSP servers via mason
  -- automatic_enable = true lets Neovim 0.11+ auto-enable installed servers
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls", "rust_analyzer", "clangd", "astro",
        "pyright", "ts_ls", "jsonls", "yamlls", "remark_ls",
        "tinymist",
      },
      automatic_enable = false, -- we call vim.lsp.enable() manually below
    },
  },

  -- nvim-lspconfig: configure language servers via vim.lsp.config() (Nvim 0.11+)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "folke/lazydev.nvim",
    },
    config = function()
      -- Diagnostic signs
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- LspAttach: set keymaps and navic when any LSP attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local bufnr = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "?", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "g?", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", ";D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", ";a", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", ";r", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", ";e", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", ";f", function()
            require("conform").format({ bufnr = bufnr, async = true })
          end, opts)
          vim.keymap.set("x", ";f", function()
            require("conform").format({ bufnr = bufnr, async = true })
          end, opts)

          -- Attach navic for breadcrumbs
          if client and client.server_capabilities.documentSymbolProvider then
            local ok, navic = pcall(require, "nvim-navic")
            if ok then navic.attach(client, bufnr) end
          end
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

      vim.lsp.config("remark_ls", {
        root_markers = { ".remarkrc.yml", ".remarkrc.js", ".git" },
        filetypes = { "markdown" },
      })

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
        "lua_ls", "clangd", "astro",
        "pyright", "ts_ls", "jsonls", "yamlls", "remark_ls",
        "tinymist",
      })
    end,
  },

  -- lazydev: Neovim Lua API completion (neodev replacement)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
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
    keys = {
      { ";;f", function() require("conform").format({ async = true }) end,
        mode = { "n", "x" }, desc = "Format buffer" },
    },
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

  -- fidget: LSP progress UI
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = { window = { winblend = 0 } },
    },
  },

  -- trouble: diagnostics list
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<Leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<Leader>xX", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics" },
      { "<Leader>xq", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix (Trouble)" },
    },
  },
}
