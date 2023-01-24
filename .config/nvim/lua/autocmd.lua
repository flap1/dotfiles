local group_name = "autocmd"
vim.api.nvim_create_augroup(group_name, { clear = true })

-- disable continuation of comments to the next line
vim.cmd(
    [[
  autocmd FileType * set fo-=c fo-=r fo-=o
]]
)

-- Packer.nvim
vim.cmd(
    [[
augroup packer_user_config
  autocmd!
  autocmd BufWritePost ~/.config/nvim/lua/plugins/*.lua,~/.config/nvim/lua/plugins/config/*.lua,~/.config/nvim/vim/plugins/config/*.vim source <afile> | PackerCompile
augroup END
]]
)

-- Quickfix after grep
vim.cmd(
    [[
" create a self-clearing autocommand group called 'qf'
augroup qf
    " clear all autocommands in this group
    autocmd!

    " do :cwindow if the quickfix command doesn't start
    " with a 'l' (:grep, :make, etc.)
    autocmd QuickFixCmdPost [^l]* cwindow

    " do :lwindow if the quickfix command starts with
    " a 'l' (:lgrep, :lmake, etc.)
    autocmd QuickFixCmdPost l*    lwindow

    " do :cwindow when Vim was started with the '-q' flag
    autocmd VimEnter        *     cwindow
augroup END
]]
)

vim.api.nvim_create_autocmd({ "CmdwinEnter" }, {
    group = group_name,
    pattern = "*",
    callback = function()
        vim.cmd([[startinsert]])
    end,
    once = false,
})
