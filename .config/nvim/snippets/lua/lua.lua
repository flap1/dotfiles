local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("pcall", {
    t({ "local ok, _ = pcall(require, '" }),
    i(1),
    t({ "')", "if not ok then", "\t" }),
    i(0),
    t({ "", "end" }),
  }),
  s("esc_pattern", {
    i(1),
    t({ ':gsub("%W", "%%%0")' }),
  }),
  s("print_table", {
    t({
      "function print_table(tbl, indent)",
      "  if not indent then indent = 0 end",
      "  for k, v in pairs(tbl) do",
      "    local formatting = string.rep(\"  \", indent) .. k .. \": \"",
      "    if type(v) == \"table\" then",
      "      print(formatting)",
      "      print_table(v, indent+1)",
      "    else",
      "      print(formatting .. v)",
      "    end",
      "  end",
      "end",
    }),
  }),
}
