require("cheatsheet").setup({
    bundled_cheatsheets = {
        -- only show the default cheatsheet
        -- enabled = { "markdown", "regex", "nerd-fonts" },
        -- enabled = { "markdown", "regex" },
        enabled = {},
    },
    bundled_plugin_cheatsheets = {
        enabled = {}
        -- disabled = { "gitsigns.nvim" },
    },
    register = "+",
    telescope_mappings = {
        ['<CR>'] = require('cheatsheet.telescope.actions').select_or_fill_commandline,
        ['<C-CR>'] = require('cheatsheet.telescope.actions').select_or_execute,
        ['<C-Y>'] = require('cheatsheet.telescope.actions').copy_cheat_value,
        ['<C-E>'] = require('cheatsheet.telescope.actions').edit_user_cheatsheet,
    }
})

vim.keymap.set("n", "<M-?>", "<Cmd>Cheatsheet<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<M-?>", "<Esc><Cmd>Cheatsheet<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<M-?>", "<C-\\><C-n><Cmd>Cheatsheet<CR>", { noremap = true, silent = true })

