-- AI integration: claudecode.nvim (Claude Code CLI bridge)

return {
  -- snacks.nvim: required dependency for claudecode.nvim terminal UI
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      { "<M-->",  function() Snacks.terminal.toggle(nil, { win = { position = "bottom" } }) end, mode = { "n", "t" }, desc = "Terminal bottom" },
      { "<M-|>",  function() Snacks.terminal.toggle(nil, { win = { position = "right" }, env = { SNACKS_TERM = "right" } }) end,  mode = { "n", "t" }, desc = "Terminal right" },
      { "<leader>em", function() Snacks.terminal.toggle("aerc") end,                             desc = "Email (aerc)" },
      { "<Leader>gl", function() Snacks.lazygit() end,                                desc = "Lazygit" },
      { "<Leader>gf", function() Snacks.lazygit.log_file() end,                       desc = "Lazygit file history" },
      { "<Leader>gL", function() Snacks.lazygit.log() end,                            desc = "Lazygit log (cwd)" },
    },
    opts = {
      terminal  = { enabled = true },
      input     = { enabled = true },
      notifier  = { enabled = true, timeout = 3000 },
      lazygit   = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
        preset = {
          header = (function()
            local f = vim.fn.expand("~/.config/nvim/lua/plugins/dashboard/redacted-org.txt")
            if vim.fn.filereadable(f) == 1 then
              return table.concat(vim.fn.readfile(f), "\n")
            end
          end)(),
          keys = {
            { icon = " ", key = "l", desc = "Last Session",  action = "<Cmd>PossessionLoadCurrent<CR>" },
            { icon = " ", key = "f", desc = "Find File",     action = "<Cmd>Telescope find_files<CR>" },
            { icon = " ", key = "r", desc = "Recent Files",  action = "<Cmd>Telescope oldfiles<CR>" },
            { icon = " ", key = "g", desc = "Find Word",     action = "<Cmd>Telescope live_grep<CR>" },
            { icon = " ", key = "e", desc = "New File",      action = "<Cmd>enew<CR>" },
            { icon = " ", key = "p", desc = "Plugins",       action = "<Cmd>Lazy<CR>" },
            { icon = " ", key = "s", desc = "Settings",      action = "<Cmd>e $MYVIMRC<CR>" },
            { icon = " ", key = "q", desc = "Quit",          action = "<Cmd>qa<CR>" },
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

  -- claudecode.nvim: Claude Code CLI <-> Neovim bridge
  -- Implements the same WebSocket MCP protocol as the official VS Code extension
  {
    "coder/claudecode.nvim",
    event = "VeryLazy",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal_cmd = "claude",
      auto_start = true,
      -- Split configuration for terminal
      split_side = "right",
      split_width_percentage = 0.40,
    },
    keys = {
      { "<Leader>ac", "<Cmd>ClaudeCode<CR>",           desc = "Claude Code toggle" },
      { "<Leader>af", "<Cmd>ClaudeCodeFocus<CR>",      desc = "Claude Code focus" },
      { "<Leader>as", "<Cmd>ClaudeCodeSend<CR>",       mode = "v", desc = "Send selection to Claude" },
      { "<Leader>ar", "<Cmd>ClaudeCodeResume<CR>",     desc = "Claude Code resume session" },
      { "<Leader>am", "<Cmd>ClaudeCodeMCP<CR>",        desc = "Claude Code MCP tools" },
      { "<Leader>at", "<Cmd>ClaudeCodeTreeSend<CR>",   desc = "Send tree context to Claude" },
    },
  },
}
