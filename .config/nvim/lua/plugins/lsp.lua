-- LSP stack: mason + nvim-lspconfig + conform.nvim + nvim-lint

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

  -- mason-lspconfig: bridge between mason and nvim-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "lua_ls", "rust_analyzer", "clangd", "astro",
        "pyright", "ts_ls", "jsonls", "yamlls", "remark_ls",
      },
    },
  },

  -- nvim-lspconfig: configure language servers
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
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local lspconfig = require("lspconfig")

      local on_attach = function(client, bufnr)
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
        if client.server_capabilities.documentSymbolProvider then
          local ok, navic = pcall(require, "nvim-navic")
          if ok then navic.attach(client, bufnr) end
        end
      end

      local default_opts = {
        capabilities = capabilities,
        on_attach = on_attach,
        root_dir = lspconfig.util.find_git_ancestor,
      }

      require("mason-lspconfig").setup_handlers({
        -- Default handler
        function(server_name)
          lspconfig[server_name].setup(default_opts)
        end,

        ["lua_ls"] = function()
          lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", default_opts, {
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
          }))
        end,

        ["clangd"] = function()
          lspconfig.clangd.setup(vim.tbl_deep_extend("force", default_opts, {
            cmd = { "clangd", "--background-index", "--clang-tidy",
              "--cross-file-rename", "--completion-style=detailed" },
            root_dir = lspconfig.util.root_pattern(
              "compile_commands.json", "compile_flags.txt", ".clangd", ".git"),
          }))
        end,

        ["remark_ls"] = function()
          lspconfig.remark_ls.setup(vim.tbl_deep_extend("force", default_opts, {
            root_dir = lspconfig.util.root_pattern(".remarkrc.yml", ".remarkrc.js", ".git"),
            filetypes = { "markdown", "telekasten" },
          }))
        end,

        ["pyright"] = function()
          lspconfig.pyright.setup(vim.tbl_deep_extend("force", default_opts, {
            settings = {
              python = {
                analysis = { typeCheckingMode = "basic" },
              },
            },
          }))
        end,

        ["ts_ls"] = function()
          lspconfig.ts_ls.setup(default_opts)
        end,

        -- rust_analyzer is handled by rustaceanvim in lang.lua
        ["rust_analyzer"] = function() end,
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
