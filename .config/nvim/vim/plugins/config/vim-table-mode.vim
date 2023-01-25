let g:table_mode_corner='|'
let g:table_mode_map_prefix = '<LocalLeader>tm'

nmap <LocalLeader>tmr <Cmd>TableModeRealign<CR>

augroup TableMode
  autocmd!
  autocmd BufEnter *.md TableModeEnable
augroup END
