require("nvim-surround").setup({
  move_cursor = false,
  keymaps = { -- vim-surround style keymaps
    insert = "<C-s>",
    insert_line = "<C-s><C-s>",
    normal = "ys",
    normal_cur = "yss",
    normal_line = "yS",
    normal_cur_line = "ySS",
    visual = "s",
    delete = "ds",
    change = "cs",
  },
  aliases = {
    ["a"] = "a",
    ["b"] = "b",
    ["B"] = "B",
    ["r"] = "r",
    ["q"] = { '"', "'", "`" }, -- Any quote character
    [";"] = { ")", "]", "}", ">", "'", '"', "`" }, -- Any surrounding delimiter
  },
  highlight = { -- Highlight before inserting/changing surrounds
    duration = 0,
  },
})

