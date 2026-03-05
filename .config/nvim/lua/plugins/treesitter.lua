-- Treesitter: syntax, highlight, textobjects

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "HiPhish/rainbow-delimiters.nvim",
    },
    config = function()
      -- main branch: require("nvim-treesitter.configs") is removed.
      -- Parsers are installed via TSInstall / opts.ensure_installed.
      -- Highlight/indent are enabled via vim.treesitter API.
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "bash", "html", "yaml", "python",
          "toml", "c", "markdown", "markdown_inline", "javascript",
          "typescript", "tsx", "json", "rust", "go", "css",
        },
        auto_install = true,
      })

      -- Enable highlight and indent via Neovim native API
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local ok = pcall(vim.treesitter.start)
          if not ok then return end
        end,
      })
    end,
  },

  -- nvim-treesitter-textobjects (main branch)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = { ["<LocalLeader>a"] = "@parameter.inner" },
          swap_previous = { ["<LocalLeader>A"] = "@parameter.inner" },
        },
      })
    end,
  },

  -- rainbow-delimiters: colorize brackets
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow = require("rainbow-delimiters")
      require("rainbow-delimiters.setup").setup({
        strategy = {
          [""] = rainbow.strategy["global"],
          vim = rainbow.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      })
    end,
  },

  -- hlargs: highlight function arguments
  {
    "m-demare/hlargs.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- nvim-treehopper: hop to treesitter nodes
  {
    "mfussenegger/nvim-treehopper",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "m", mode = { "o", "x" },
        function() require("tsht").nodes() end, desc = "Treehopper" },
    },
  },
}
