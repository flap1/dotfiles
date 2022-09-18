local file = "~/.config/nvim/data/my.dict"

require("cmp_dictionary").setup({
  dic = {
    ["*"] = file
  },
})

