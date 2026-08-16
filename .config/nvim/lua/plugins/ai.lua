-- snacks is declared once. claudecode needs its terminal module.

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      { "<Leader>e", function() Snacks.explorer() end,         desc = "File explorer" },
      { "<Leader>gl", function() Snacks.lazygit() end,          desc = "Lazygit" },
      { "<Leader>gL", function() Snacks.lazygit.log() end,      desc = "Lazygit log (cwd)" },
      { "<Leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit file history" },
      { "<Leader>bd", function() Snacks.bufdelete() end,        desc = "Delete buffer" },
      { "<Leader>bD", function() Snacks.bufdelete.all() end,    desc = "Delete all buffers" },
      { "<Leader>bo", function() Snacks.bufdelete.other() end,  desc = "Delete other buffers" },
    },
    opts = {
      terminal = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      lazygit = { enabled = true },
      dashboard = { enabled = false },
      explorer = { enabled = true },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            layout = {
              layout = {
                backdrop = false,
                position = "left",
                width = 32,
                min_width = 24,
                height = 0,
                border = "single",
                box = "vertical",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
              },
            },
            exclude = {
              "node_modules",
              ".cache",
              "__pycache__",
              ".venv",
              "target",
              ".next",
              ".turbo",
            },
          },
        },
      },
    },
    init = function()
      vim.notify = function(msg, level, opts)
        Snacks.notify(msg, vim.tbl_deep_extend("force", opts or {}, { level = level }))
      end
    end,
  },

  {
    "coder/claudecode.nvim",
    event = "VeryLazy",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal_cmd = "claude",
      auto_start = true,
      split_side = "right",
      split_width_percentage = 0.40,
    },
    keys = {
      { "<Leader>ac", "<Cmd>ClaudeCode<CR>",            desc = "Toggle Claude" },
      { "<Leader>af", "<Cmd>ClaudeCodeFocus<CR>",       desc = "Focus Claude" },
      { "<Leader>ar", "<Cmd>ClaudeCode --resume<CR>",   desc = "Resume Claude" },
      { "<Leader>aC", "<Cmd>ClaudeCode --continue<CR>", desc = "Continue Claude" },
      { "<Leader>am", "<Cmd>ClaudeCodeSelectModel<CR>", desc = "Select Claude model" },
      { "<Leader>ab", "<Cmd>ClaudeCodeAdd %<CR>",       desc = "Add current buffer" },
      { "<Leader>as", "<Cmd>ClaudeCodeSend<CR>",        mode = "v", desc = "Send to Claude" },
      { "<Leader>as", "<Cmd>ClaudeCodeTreeAdd<CR>",     ft = { "oil" }, desc = "Add file from tree" },
      { "<Leader>aa", "<Cmd>ClaudeCodeDiffAccept<CR>",  desc = "Accept diff" },
      { "<Leader>ad", "<Cmd>ClaudeCodeDiffDeny<CR>",    desc = "Deny diff" },
      { "<Leader>ai", "<Cmd>ClaudeCodeStatus<CR>",      desc = "Claude Code status" },
    },
  },
}
