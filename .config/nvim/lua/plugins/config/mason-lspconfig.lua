require('mason-lspconfig').setup()

local opts = { noremap = true, silent = true }
-- lsp
-- vim.keymap.set("n", ";", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "[lsp]", "<Nop>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", ";", "[lsp]", {})

vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.keymap.set('n', '?', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.keymap.set('n', 'g?', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
vim.keymap.set('n', ';wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
vim.keymap.set('n', ';wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
vim.keymap.set('n', ';wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
vim.keymap.set('n', ';D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
vim.keymap.set('n', ';a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
vim.keymap.set('n', ';e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.keymap.set('n', ';q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
vim.keymap.set('n', ';f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  require('nvim-navic').attach(client, bufnr)
end

local lspconfig = require 'lspconfig'
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local opts = { capabilities = capabilities, on_attach = on_attach }

require('mason-lspconfig').setup_handlers({
  function(server_name)
    lspconfig[server_name].setup(opts)
  end,

  -- markdown
  -- ['remark_ls'] = function()
  --   lspconfig.remark_ls.setup({
  --     filetypes = { "markdown", "telekasten" }
  --   })
  -- end,
  ["pylsp"] = function()
    lspconfig.pylsp.setup({
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = {
              ignore = {},
              maxLineLength = 120
            }
          }
        }
      }
    })
  end,

  -- rust
  ['rust_analyzer'] = function()
    local has_rust_tools, rust_tools = pcall(require, 'rust-tools')
    if has_rust_tools then
      rust_tools.setup { server = opts }
    else
      lspconfig.rust_analyzer.setup {}
    end
  end,

  -- lua
  ["sumneko_lua"] = function()
    local has_lua_dev, lua_dev = pcall(require, "neodev")
    if has_lua_dev then
      local l = lua_dev.setup({
        library = {
          enabled = true,
          runtime = true, -- runtime path
          types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
          -- plugins = false, -- installed opt or start plugins in packpath
          -- you can also specify the list of plugins to make available as a workspace library
          -- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
          plugins = { "nvim-treesitter", "plenary.nvim" },
        },
        -- runtime_path = false,
        -- lspconfig = opts,
      })
      l["settings"]["Lua"] = {}
      l["settings"]["Lua"]["diagnostics"] = {
        globals = { "vim" },
        severity = {
          ["missing-parameter"] = "Hint",
        },
      }
      lspconfig.sumneko_lua.setup(l)
    else
      lspconfig.sumneko_lua.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
              severity = {
                ["missing-parameter"] = "Hint",
              },
            },
          },
        },
      })
    end
  end,
})
