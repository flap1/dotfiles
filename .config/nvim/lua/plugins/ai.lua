-- AI integration: claudecode.nvim (Claude Code CLI bridge)

return {
  -- snacks.nvim: required dependency for claudecode.nvim terminal UI
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    -- No generic terminal toggles and no aerc launcher: a shell, a mail client
    -- and anything else long-lived belongs in a tmux pane, where it outlives
    -- nvim. The terminal module stays enabled because claudecode needs it.
    keys = {
      { "<Leader>gl", function() Snacks.lazygit() end,          desc = "Lazygit" },
      { "<Leader>gL", function() Snacks.lazygit.log() end,      desc = "Lazygit log (cwd)" },
      { "<Leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit file history" },
    },
    opts = {
      terminal  = { enabled = true },
      input     = { enabled = true },
      notifier  = { enabled = true, timeout = 3000 },
      lazygit   = { enabled = true },
      -- No header art: nvim opens into a project you already chose in tmux,
      -- so the startup screen is a key menu, not a splash.
      dashboard = {
        enabled = true,
        sections = {
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File",    action = "<Cmd>Telescope find_files<CR>" },
            { icon = " ", key = "r", desc = "Recent Files", action = "<Cmd>Telescope oldfiles<CR>" },
            { icon = " ", key = "g", desc = "Find Word",    action = "<Cmd>Telescope live_grep<CR>" },
            { icon = " ", key = "e", desc = "New File",     action = "<Cmd>enew<CR>" },
            { icon = " ", key = "p", desc = "Plugins",      action = "<Cmd>Lazy<CR>" },
            { icon = " ", key = "q", desc = "Quit",         action = "<Cmd>qa<CR>" },
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
      { "<Leader>a",  nil,                               desc = "AI/Claude Code" },
      { "<Leader>ac", "<Cmd>ClaudeCode<CR>",           desc = "Toggle Claude" },
      { "<Leader>af", "<Cmd>ClaudeCodeFocus<CR>",      desc = "Focus Claude" },
      { "<Leader>ar", "<Cmd>ClaudeCode --resume<CR>",  desc = "Resume Claude" },
      { "<Leader>aC", "<Cmd>ClaudeCode --continue<CR>", desc = "Continue Claude" },
      { "<Leader>am", "<Cmd>ClaudeCodeSelectModel<CR>", desc = "Select Claude model" },
      { "<Leader>ab", "<Cmd>ClaudeCodeAdd %<CR>",      desc = "Add current buffer" },
      { "<Leader>as", "<Cmd>ClaudeCodeSend<CR>",       mode = "v", desc = "Send to Claude" },
      { "<Leader>as", "<Cmd>ClaudeCodeTreeAdd<CR>",    ft = { "oil" }, desc = "Add file from tree" },
      { "<Leader>aa", "<Cmd>ClaudeCodeDiffAccept<CR>", desc = "Accept diff" },
      { "<Leader>ad", "<Cmd>ClaudeCodeDiffDeny<CR>",   desc = "Deny diff" },
      { "<Leader>ai", "<Cmd>ClaudeCodeStatus<CR>",     desc = "Claude Code status" },
    },
  },
}
