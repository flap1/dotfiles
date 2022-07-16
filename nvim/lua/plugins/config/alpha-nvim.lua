local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = vim.fn.readfile(vim.fn.expand("~/.config/nvim/files/dashboard_custom_header.txt"))
dashboard.section.header.opts.hl = "Question"
dashboard.section.buttons.val = {
	dashboard.button("f", " Find file", ":Telescope find_files<CR>"),
	dashboard.button("p", " Update plugins", ":PackerSync<CR>"),
	dashboard.button("q", " Exit", ":qa<CR>"),
}
alpha.setup(dashboard.config)

