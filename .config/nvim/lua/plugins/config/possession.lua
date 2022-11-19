local ignore_filetypes = { "gitcommit", "gitrebase" }

local function get_dir_pattern()
  local pattern = "/"
  if vim.fn.has("win32") == 1 then
    pattern = "[\\:]"
  end
  return pattern
end

local function is_normal_buffer(buffer)
  local buftype = vim.api.nvim_buf_get_option(buffer, "buftype")
  if #buftype == 0 then
    if not vim.api.nvim_buf_get_option(buffer, "buflisted") then
      vim.api.nvim_buf_delete(buffer, { force = true })
      return false
    end
  elseif buftype ~= "terminal" then
    vim.api.nvim_buf_delete(buffer, { force = true })
    return false
  end
  return true
end

local function is_restorable(buffer)
  local n = vim.api.nvim_buf_get_name(buffer)
  local cwd = vim.fn.getcwd()
  if string.match(n, cwd:gsub("%W", "%%%0") .. "/%s*")
      and vim.api.nvim_buf_is_valid(buffer)
      and is_normal_buffer(buffer)
      and vim.fn.filereadable(n) == 1
  then
    return true
  end
  return false
end

require("possession").setup({
  session_dir = (require("plenary.path"):new(vim.fn.stdpath("state")) / "possession"):absolute(),
  silent = true,
  autosave = {
    tmp_name = vim.fn.getcwd():gsub(get_dir_pattern(), "__"),
  },
  commands = {
      save = 'SSave',
      load = 'SLoad',
      delete = 'SDelete',
      list = 'SList',
  },
  hooks = {
    before_save = function(name)
      if vim.fn.argc() > 0 then
        vim.api.nvim_command("%argdel")
      end
      if vim.tbl_contains(ignore_filetypes, vim.api.nvim_buf_get_option(0, "filetype")) then
        return false
      end
      local bufs = vim.api.nvim_list_bufs()
      for index, value in ipairs(bufs) do
        if is_restorable(value) then
          return true
        end
      end
      return false
    end,
  },
  plugins = {
    delete_hidden_buffers = {
      hooks = {
        -- "before_load",
        -- vim.o.sessionoptions:match("buffer") and "before_save",
      },
      force = false,
    },
  },
})

vim.api.nvim_create_user_command("PossessionSaveCurrent", function()
  local tmp_name = vim.fn.getcwd():gsub(get_dir_pattern(), "__")
  vim.cmd("PossessionSave!" .. tmp_name)
end, { force = true })

vim.api.nvim_create_user_command("PossessionLoadCurrent", function()
  local tmp_name = vim.fn.getcwd():gsub(get_dir_pattern(), "__")
  vim.cmd("PossessionLoad" .. tmp_name)
end, { force = true })

-- vim.api.nvim_create_user_command("SaveWindow", function()
--   vim.cmd("PossessionSave " .. vim.fn.strftime("%Y%m%d_%H%M%S"))
-- end, { force = true })

vim.api.nvim_create_augroup("vimrc_possession", { clear = true })
vim.api.nvim_create_autocmd({ "VimLeave" }, {
  group = "vimrc_possession",
  pattern = "*",
  callback = function()
    vim.cmd([[PossessionSaveCurrent]])
  end,
  once = false,
})

require('telescope').load_extension('possession')
