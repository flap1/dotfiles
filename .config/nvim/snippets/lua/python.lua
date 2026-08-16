local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

return {
  s("logger", {
    t({ "from logging import getLogger", "logger = getLogger(name=__name__)" }),
  }),
}
