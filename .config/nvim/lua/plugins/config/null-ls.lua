-- local cspell_config_dir = '~/.config/nvim/data/cspell'
-- local cspell_data_dir = '~/.local/share/cspell'
-- local cspell_files = {
--   config = vim.call('expand', cspell_config_dir .. '/cspell.json'),
--   dotfiles = vim.call('expand', cspell_config_dir .. '/dotfiles.txt'),
--   vim = vim.call('expand', cspell_data_dir .. '/vim.txt.gz'),
-- }

local null_ls = require 'null-ls'

local sources = {
  -- null_ls.builtins.formatting.stylua.with { extra_args = { '--config-path', vim.fn.expand '~/.stylua.toml' } }, -- lua
  -- null_ls.builtins.formatting.taplo, -- toml, cargo install taplo-cli --locked
  -- null_ls.builtins.diagnostics.eslint,
  -- null_ls.builtins.diagnostics.cspell.with({
  --   diagnostics_postprocess = function(diagnostic)
  --     diagnostic.severity = vim.diagnostic.severity["WARN"]
  --     local formatted = "[#{c}] #{m} (#{s})"
  --     formatted = formatted:gsub("#{m}", diagnostic.message)
  --     formatted = formatted:gsub("#{s}", diagnostic.source)
  --     formatted = formatted:gsub("#{c}", diagnostic.code or "")
  --     diagnostic.message = formatted
  --   end,
  --   condition = function()
  --     return vim.fn.executable("cspell") > 0
  --   end,
  --   extra_args = { '--config', cspell_files.config }
  -- }),
}

local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

local on_attach = function(client, bufnr)
  if client.supports_method 'textDocument/formatting' then
    vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format { bufnr = bufnr }
      end,
    })
  end
end

null_ls.setup {
  sources = sources,
  -- on_attach = on_attach,
}
