local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

return {
  s("setupLogger", {
    t({ "from myutils import setup_logger", "logger = setup_logger(__name__)" }),
  }),
}
