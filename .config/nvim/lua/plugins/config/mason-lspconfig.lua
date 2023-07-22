local key_opts = { noremap = true, silent = true }
-- lsp
-- vim.keymap.set("n", ";", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "[lsp]", "<Nop>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", ";", "[lsp]", {})

vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', key_opts)
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', key_opts)
vim.keymap.set('n', '?', '<cmd>lua vim.lsp.buf.hover()<CR>', key_opts)
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', key_opts)
vim.keymap.set('n', 'g?', '<cmd>lua vim.lsp.buf.signature_help()<CR>', key_opts)
vim.keymap.set('n', ';wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', key_opts)
vim.keymap.set('n', ';wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', key_opts)
vim.keymap.set('n', ';wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', key_opts)
vim.keymap.set('n', ';D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', key_opts)
vim.keymap.set('n', ';a', '<cmd>lua vim.lsp.buf.code_action()<CR>', key_opts)
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', key_opts)
vim.keymap.set('n', ';e', '<cmd>lua vim.diagnostic.open_float()<CR><cmd>lua vim.diagnostic.open_float()<CR>', key_opts)
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', key_opts)
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', key_opts)
vim.keymap.set('n', ';q', '<cmd>lua vim.diagnostic.setloclist()<CR>', key_opts)
vim.keymap.set('n', ';f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', key_opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  require('nvim-navic').attach(client, bufnr)
end
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local opts = { capabilities = capabilities, on_attach = on_attach, root_dir = lspconfig.util.find_git_ancestor }
local rust_opts = {
  capabilities = capabilities,
  on_attach = on_attach,
  root_dir = lspconfig.util.find_git_ancestor,
  settings = { ["rust-analyzer"] = { check = { command = "clippy" } } }
}

-- for clang
local clangd_capabilities = capabilities
-- clangd_capabilities.offsetEncoding = "utf-8"

local handlers = {
  function(server_name)
    lspconfig[server_name].setup(opts)
  end,

  -- ["prettier"] = function()
  --   lspconfig.prettier.setup {
  --     cmd = { "prettier", "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
  --     filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "css", "less", "scss", "json",
  --       "graphql", "markdown", "vue", "yaml", "html" },
  --     root_dir = lspconfig.util.root_pattern(".prettierrc", ".prettierrc.json", ".prettierrc.toml", ".prettierrc.js",
  --       ".git"),
  --   }
  -- end,

  -- astro
  ['astro'] = function()
    lspconfig.astro.setup {}
  end,

  -- markdown
  ['remark_ls'] = function()
    lspconfig.remark_ls.setup {
      root_dir = lspconfig.util.root_pattern(".remarkrc.yml", ".remarkrc.js", ".git"),
      filetypes = { "markdown", "telekasten" }
    }
  end,

  -- python
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

  -- ["tsserver"] = function()
  --   lspconfig.tsserver.setup({
  --     init_options = {
  --       preferences = {
  --         -- disableSuggestions = true
  --       }
  --     }
  --   })
  -- end,

  ['clangd'] = function()
    lspconfig.clangd.setup {
      capabilities = clangd_capabilities,
      cmd = { "clangd", "--background-index", "--clang-tidy", "--cross-file-rename", "--completion-style=detailed" },
      -- handlers = {
      --   ["textDocument/publishDiagnostics"] = vim.lsp.with(
      --     vim.lsp.diagnostic.on_publish_diagnostics, {
      --       virtual_text = false,
      --       signs = true,
      --       underline = true,
      --       update_in_insert = true,
      --     }
      --   ),
      -- },
      root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".clangd", ".git"),
    }
  end,

  -- rust
  ['rust_analyzer'] = function()
    local has_rust_tools, rust_tools = pcall(require, 'rust-tools')
    if has_rust_tools then
      rust_tools.setup { server = rust_opts }
    else
      lspconfig.rust_analyzer.setup {
        settings = {
          ["rust-analyzer"] = {
            check = {
              command = "clippy"
            }
          }
        }
      }
    end
  end,

  -- lua
  ["lua_ls"] = function()
    local has_lua_dev, lua_dev = pcall(require, "neodev")
    if has_lua_dev then
      local l = lua_dev.setup({
        library = {
          enabled = true,
          runtime = true, -- runtime path
          types = true,   -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
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
      lspconfig.lua_ls.setup(l)
    else
      lspconfig.lua_ls.setup({
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
}

require('mason-lspconfig').setup({
  ensure_installed = { "lua_ls", "rust_analyzer", "remark_ls", "clangd", "astro" },
  handlers = handlers
})
