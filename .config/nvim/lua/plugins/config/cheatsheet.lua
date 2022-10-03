require("cheatsheet").setup({
    bundled_cheatsheets = {
        -- only show the default cheatsheet
        enabled = { "markdown", "regex", "nerd-fonts" },
    },
    bundled_plugin_cheatsheets = {
        -- enabled = {}
        -- disabled = { "gitsigns.nvim" },
    },
    telescope_mappings = {
        ['<CR>'] = require('cheatsheet.telescope.actions').select_or_fill_commandline,
        ['<A-CR>'] = require('cheatsheet.telescope.actions').select_or_execute,
        ['<C-Y>'] = require('cheatsheet.telescope.actions').copy_cheat_value,
        ['<C-E>'] = require('cheatsheet.telescope.actions').edit_user_cheatsheet,
    }
})

vim.keymap.set("n", "<Leader>c", ":Cheatsheet<CR>", { noremap = true, silent = true })
