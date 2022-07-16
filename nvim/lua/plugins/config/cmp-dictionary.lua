local file = vim.fn.stdpath("data") .. "/zsh/dictionary/my.dict"
local dic = {}
if vim.fn.filereadable(file) ~= 0 then
  dic = file
end
require("cmp_dictionary").setup({
  dic = { ["*"] = dic },
})

