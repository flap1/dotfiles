require("translate").setup({
    default = {
        command = "google",
    },
    preset = {
        output = {
            split = {
                append = true,
            },
        },
    },
})

vim.keymap.set("n", "<LocalLeader>tj", "viw:Translate ja<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<LocalLeader>te", "viw:Translate en<CR>", { noremap = true, silent = true })
vim.keymap.set("x", "<LocalLeader>tj", ":Translate ja -output=split<CR>", { noremap = true, silent = true })
vim.keymap.set("x", "<LocalLeader>te", ":Translate en -output=split<CR>", { noremap = true, silent = true })

