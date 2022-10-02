vim.g.lightspeed_no_default_keymaps = true

require("lightspeed").setup {
  exit_after_idle_msecs = { unlabeled = 2000, labeled = nil },
  --- s/x ---
  jump_to_unique_chars = true,
}
vim.cmd([[
nmap <expr> f reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_f" : "f"
nmap <expr> F reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_F" : "F"
nmap <expr> t reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_t" : "t"
nmap <expr> T reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_T" : "T"
]])
