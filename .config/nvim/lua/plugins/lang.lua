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

  -- vimtex: LaTeX
  {
    "lervag/vimtex",
    ft = { "tex", "latex", "plaintex" },
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-pdf", "-shell-escape", "-verbose",
          "-file-line-error", "-synctex=1", "-interaction=nonstopmode",
        },
      }
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_syntax_enabled = 1
      vim.g.vimtex_quickfix_mode = 0
    end,
  },

  -- markdown-preview
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = { "markdown", "telekasten" },
    config = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_refresh_slow = 0
    end,
    keys = {
      { "<Leader>mp", "<Cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Markdown Preview" },
    },
  },

  -- vim-table-mode: markdown tables
  {
    "dhruvasagar/vim-table-mode",
    cmd = { "TableModeToggle", "TableModeEnable" },
    ft = { "markdown", "telekasten" },
  },

  -- csv.vim
  {
    "chrisbra/csv.vim",
    ft = "csv",
  },

  -- plantuml-previewer
  {
    "weirongxu/plantuml-previewer.vim",
    dependencies = {
      "tyru/open-browser.vim",
      "aklt/plantuml-syntax",
    },
    ft = { "plantuml" },
  },

  -- vim-quickrun: run code in buffer
  {
    "thinca/vim-quickrun",
    cmd = "QuickRun",
    keys = {
      { "<Leader>r", "<Cmd>QuickRun<CR>", desc = "QuickRun" },
    },
  },

  -- nvim-dap: debugger
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<Leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP breakpoint" },
      { "<Leader>dc", function() require("dap").continue() end,          desc = "DAP continue" },
      { "<Leader>dn", function() require("dap").step_over() end,         desc = "DAP step over" },
      { "<Leader>di", function() require("dap").step_into() end,         desc = "DAP step into" },
      { "<Leader>do", function() require("dap").step_out() end,          desc = "DAP step out" },
      { "<Leader>dr", function() require("dap").repl.open() end,         desc = "DAP REPL" },
    },
    config = function()
      local dap = require("dap")
      -- Rust / C: LLDB adapter
      dap.adapters.lldb = {
        type = "executable",
        command = "/usr/bin/lldb-vscode",
        name = "lldb",
      }
      dap.configurations.rust = {
        {
          name = "Launch",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.c = dap.configurations.rust
      dap.configurations.cpp = dap.configurations.rust
    end,
  },

  -- neodev / lazydev already in lsp.lua for lua_ls

  -- telekasten: Zettelkasten notes
  {
    "renerocksai/telekasten.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    cmd = "Telekasten",
    opts = {
      home = vim.fn.expand("~/zettelkasten"),
    },
    keys = {
      { "<Leader>zf", "<Cmd>Telekasten find_notes<CR>",     desc = "Telekasten find" },
      { "<Leader>zn", "<Cmd>Telekasten new_note<CR>",       desc = "Telekasten new note" },
      { "<Leader>zt", "<Cmd>Telekasten goto_today<CR>",     desc = "Telekasten today" },
      { "<Leader>zg", "<Cmd>Telekasten search_notes<CR>",   desc = "Telekasten grep" },
      { "<Leader>zz", "<Cmd>Telekasten toggle_todo<CR>",    mode = { "n", "v" }, desc = "Telekasten toggle todo" },
    },
  },
}
