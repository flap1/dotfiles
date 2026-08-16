return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- main branch: setup only takes install_dir. Parsers are :TSUpdate
      -- (lazy build) and :TSInstall. Opening a file does not download one.
      require("nvim-treesitter").setup()

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- main-branch setup does not take keymaps; those are vim.keymap.set.
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local function sel(capture)
        return function()
          select.select_textobject(capture, "textobjects")
        end
      end
      vim.keymap.set({ "x", "o" }, "af", sel("@function.outer"))
      vim.keymap.set({ "x", "o" }, "if", sel("@function.inner"))
      vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"))
      vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"))
      vim.keymap.set({ "x", "o" }, "aa", sel("@parameter.outer"))
      vim.keymap.set({ "x", "o" }, "ia", sel("@parameter.inner"))

      local function go(fn, capture)
        return function()
          fn(capture, "textobjects")
        end
      end
      vim.keymap.set({ "n", "x", "o" }, "]f", go(move.goto_next_start, "@function.outer"))
      vim.keymap.set({ "n", "x", "o" }, "[f", go(move.goto_previous_start, "@function.outer"))
      vim.keymap.set({ "n", "x", "o" }, "]c", go(move.goto_next_start, "@class.outer"))
      vim.keymap.set({ "n", "x", "o" }, "[c", go(move.goto_previous_start, "@class.outer"))
    end,
  },
}
