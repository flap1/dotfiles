local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = vim.fn.readfile(vim.fn.expand("~/.config/nvim/lua/plugins/dashboard/koupenchan_music.txt"))
dashboard.section.footer.val = "Total plugins: " .. require("plugins/packer").count_plugins()
dashboard.section.header.opts.hl = "Question"
dashboard.section.buttons.val = {
  dashboard.button("l", "  Open last session", ":PossessionLoadCurrent<CR>"),
  dashboard.button("SPC f f", "  Find File  ", ":Telescope find_files<CR>"),
  dashboard.button("SPC f e", "  Everyday File  ", ":Telescope frecency<CR>"),
  dashboard.button("SPC f o", "  Recent File  ", ":Telescope oldfiles<CR>"),
  dashboard.button("SPC f w", "  Find Word  ", ":Telescope live_grep<CR>"),
  dashboard.button("SPC f m", "  Bookmarks  ", ":Telescope marks<CR>"),
  dashboard.button("CTRL n", "  Toggle Sidebar  ", ":NeoTreeRevealToggle<CR>"),
  dashboard.button("e", "  New file", ":enew<CR>"),
  dashboard.button("p", "  Update plugins", ":PackerSync<CR>"),
  dashboard.button("s", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>"),
  dashboard.button("q", "  Exit", ":qa<CR>"),
}
alpha.setup(dashboard.config)

local function get_listed_buffers()
  local buffers = {}
  local len = 0
  for buffer = 1, vim.fn.bufnr('$') do
    if vim.fn.buflisted(buffer) == 1 then
      len = len + 1
      buffers[len] = buffer
    end
  end

  return buffers
end

-- Display Alpha when all buffers are deleted
vim.api.nvim_create_augroup('alpha_on_empty', { clear = true })
vim.api.nvim_create_autocmd('User', {
  pattern = 'BDeletePre',
  group = 'alpha_on_empty',
  callback = function(event)
    local found_non_empty_buffer = false
    local buffers = get_listed_buffers()

    for _, bufnr in ipairs(buffers) do
      if not found_non_empty_buffer then
        local name = vim.api.nvim_buf_get_name(bufnr)
        local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')

        if bufnr ~= event.buf and name ~= '' and ft ~= 'Alpha' then
          found_non_empty_buffer = true
        end
      end
    end

    if not found_non_empty_buffer then
      require 'neo-tree'.close_all()
      vim.cmd [[:Alpha]]
    end
  end,
})
