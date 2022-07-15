-- file fullpath
vim.api.nvim_create_user_command("Filepath", "echo expand('%:p')", { force = true, nargs = 1 })
