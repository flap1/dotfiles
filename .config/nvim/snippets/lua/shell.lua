local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("start", {
    t({ "#!/usr/bin/env bash", "set -euo pipefail", "", "" }),
    i(0),
  }),
  s("if_command", {
    t("if command -v "), i(1, "cmd"), t({ " >/dev/null 2>&1; then", "\t" }), i(0), t({ "", "fi" }),
  }),
}
