local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = vim.fn.readfile(vim.fn.expand("~/.config/nvim/lua/plugins/dashboard/koupenchan_music.txt"))
dashboard.section.footer.val = "Total plugins: " .. require("plugins/packer").count_plugins()
dashboard.section.header.opts.hl = "Question"
dashboard.section.buttons.val = {
  dashboard.button("SPC f f", "  Find File  ", ":Telescope find_files<CR>"),
  dashboard.button("SPC f o", "  Recent File  ", ":Telescope oldfiles<CR>"),
  dashboard.button("SPC f w", "  Find Word  ", ":Telescope live_grep<CR>"),
  dashboard.button("SPC b m", "  Bookmarks  ", ":Telescope marks<CR>"),
  dashboard.button("CTRL n", "  Toggle Sidebar  ", ":NeoTreeRevealToggle<CR>"),
  dashboard.button("e", "  New file", ":enew<CR>"),
  dashboard.button("p", "  Update plugins", ":PackerSync<CR>"),
  dashboard.button("s", "  Settings", ":e $MYVIMRC | :cd %:p:h <CR>"),
  dashboard.button("q", "  Exit", ":qa<CR>"),
}
alpha.setup(dashboard.config)
