vim.api.nvim_create_user_command("SetNumberToggle", "set number! relativenumber!", { force = true })

-- CDC = Change to Directory of Current file
vim.api.nvim_create_user_command("CdCurrentDirectory", "cd %:p:h", { force = true })

-- Change indent
vim.api.nvim_create_user_command("IndentChange", "set tabstop=<args> shiftwidth=<args>", { force = true, nargs = 1 })

-- file fullpath
vim.api.nvim_create_user_command("Filepath", "echo expand('%:p')", { force = true, nargs = "?" })
vim.api.nvim_create_user_command("YankRelPath", ':let @+ = expand("%")', { force = true, nargs = "?" })
vim.api.nvim_create_user_command("YankFullPath", ':let @+ = expand("%:p")', { force = true, nargs = "?" })
vim.api.nvim_create_user_command(
	"FileWithNumber",
	"echo join([expand('%'),  line('.')], ':')",
	{ force = true, nargs = "?" }
)

-- edit plugin config
vim.api.nvim_create_user_command("EditPluginConfigVim", function()
	local plugin_name = string.match(vim.fn.expand("<cWORD>"), "['\"].*/(.*)['\"]")
	vim.cmd(
		"edit "
			.. vim.fn.resolve(vim.fn.expand(vim.fn.stdpath("config") .. "/vim/plugins/config/"))
			.. "/"
			.. vim.fn.fnamemodify(plugin_name, ":r")
			.. ".vim"
	)
end, { force = true })
vim.api.nvim_create_user_command("EditPluginConfigLua", function()
	local plugin_name = string.match(vim.fn.expand("<cWORD>"), "['\"].*/(.*)['\"]")
	vim.cmd(
		"edit "
			.. vim.fn.resolve(vim.fn.expand(vim.fn.stdpath("config") .. "/lua/plugins/config/"))
			.. "/"
			.. vim.fn.fnamemodify(plugin_name, ":r")
			.. ".lua"
	)
end, { force = true })

vim.api.nvim_create_user_command(
	"Profile",
	"profile start /tmp/nvim-profile.log | profile func * | profile file *",
	{ force = true }
)

vim.api.nvim_create_user_command("TabInfo", function()
	local function create_winid2bufnr_dict()
		local winid2bufnr_dict = {}
		for _, bnr in ipairs(vim.fn.range(1, vim.fn.bufnr("$"))) do
			for _, wid in ipairs(vim.fn.win_findbuf(bnr)) do
				winid2bufnr_dict[wid] = bnr
			end
		end
		return winid2bufnr_dict
	end
	print("====== Tab Page Info ======")
	local current_tnr = vim.fn.tabpagenr()
	local winid2bufnr_dict = create_winid2bufnr_dict()
	for _, tnr in ipairs(vim.fn.range(1, vim.fn.tabpagenr("$"))) do
		local current_winnr = vim.fn.tabpagewinnr(tnr)
		local symbol1 = (tnr == current_tnr) and ">" or " "
		print(symbol1 .. "Tab:" .. tnr)
		print("    Buffer number | Window Number | Window ID | Buffer Name")
		for _, wnr in ipairs(vim.fn.range(1, vim.fn.tabpagewinnr(tnr, "$"))) do
			local wid = vim.fn.win_getid(wnr, tnr)
			local bnr = winid2bufnr_dict[wid]
			local symbol2 = (wnr == current_winnr) and "*" or " "
			local c = string.format("%13d | %13d | %9d | %s", bnr, wnr, wid, vim.fn.bufname(bnr))
			print("   " .. symbol2 .. c)
		end
	end
end, { force = true, bar = true })

