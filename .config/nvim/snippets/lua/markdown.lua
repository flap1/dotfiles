local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

return {
  s("badge_link", {
    t({ "- [" }),
    i(1, { "repo/name" }),
    f(function(args)
      return string.format(
        "](https://github.com/%s) ![](https://img.shields.io/github/stars/%s) ![](https://img.shields.io/github/last-commit/%s) ![](https://img.shields.io/github/commit-activity/y/%s)",
        args[1][1],
        args[1][1],
        args[1][1],
        args[1][1]
      )
    end, { 1 }),
  }),
  s("link", { t("["), i(1), t("]("), i(2), t(")"), i(0) }),
  s("clink", {
    t("["),
    i(1),
    t("]("),
    f(function()
      return vim.fn.getreg("+")
    end),
    t(")"),
    i(0),
  }),
}
