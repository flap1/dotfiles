-- nvim-dump-keymaps.lua
-- Run with: nvim --headless -l scripts/nvim-dump-keymaps.lua
-- Outputs all keymaps as TSV to stdout
-- Note: headless mode does not load lazy.nvim plugins,
-- so only core keymaps (set before plugin load) are captured here.
-- Plugin keymaps are statically extracted by gen-keymaps.sh from plugin files.

local modes = { "n", "i", "v", "x", "o", "t", "c" }
local mode_names = {
  n = "Normal",
  i = "Insert",
  v = "Visual+Select",
  x = "Visual",
  o = "Operator",
  t = "Terminal",
  c = "Command",
}

-- Print TSV header
io.write("mode\tkey\tdesc\taction\n")

for _, mode in ipairs(modes) do
  local maps = vim.api.nvim_get_keymap(mode)
  for _, map in ipairs(maps) do
    local key = map.lhs or ""
    local desc = map.desc or ""
    local rhs = map.rhs or (map.callback and "<lua>") or ""
    -- Skip internal/plugin keymaps with empty desc (too noisy)
    -- but keep all user-defined ones
    if key ~= "" then
      -- Escape tabs and newlines
      key = key:gsub("\t", "<Tab>"):gsub("\n", "<NL>")
      desc = desc:gsub("\t", " "):gsub("\n", " ")
      rhs = rhs:gsub("\t", "<Tab>"):gsub("\n", "<NL>")
      local mode_label = mode_names[mode] or mode
      io.write(string.format("%s\t%s\t%s\t%s\n", mode_label, key, desc, rhs))
    end
  end
end

vim.cmd("qa!")
