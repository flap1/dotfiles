local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("fn_result", {
    t("fn "), i(1, "name"), t("("), i(2), t(") -> Result<()> {"),
    t({ "", "\t" }), i(0), t({ "", "\tOk(())", "}" }),
  }),
  s("fn_test", {
    t({ "#[test]", "fn " }), i(1, "name"), t({ "() {", "\t" }), i(0), t({ "", "}" }),
  }),
  s("mod_test", {
    t({ "#[cfg(test)]", "mod tests {", "\tuse super::*;", "", "\t#[test]", "\tfn " }),
    i(1, "name"), t({ "() {", "\t}", "}" }),
  }),
}
