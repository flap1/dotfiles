local group = vim.api.nvim_create_augroup("core_autocmds", { clear = true })

-- Disable comment continuation on new lines
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Auto-open quickfix after grep/make
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = group,
  pattern = "[^l]*",
  callback = function() vim.cmd("cwindow") end,
})
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = group,
  pattern = "l*",
  callback = function() vim.cmd("lwindow") end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  pattern = "*",
  callback = function() vim.cmd("cwindow") end,
})

-- Start insert in command-line window
vim.api.nvim_create_autocmd("CmdwinEnter", {
  group = group,
  pattern = "*",
  callback = function() vim.cmd("startinsert") end,
})

-- Highlight on yank, and mirror the yank to the system clipboard.
-- Not clipboard=unnamedplus: that sends x/d/c to + as well, so deleting one
-- character destroys the Windows clipboard. Only y is sent. Limiting regname
-- to the unnamed register avoids sending "+y twice, which goes via
-- g.clipboard.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 200 })
    if vim.v.event.operator == "y" and vim.v.event.regname == "" then
      vim.fn.setreg("+", vim.v.event.regcontents, vim.v.event.regtype)
    end
  end,
})

-- Restore cursor position on file open
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-create parent directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
