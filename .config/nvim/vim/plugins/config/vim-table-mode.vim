let g:table_mode_corner='|'
let g:table_mode_map_prefix = '<LocalLeader>t'

augroup TableMode
  autocmd!
  autocmd BufEnter *.md TableModeEnable
augroup END
