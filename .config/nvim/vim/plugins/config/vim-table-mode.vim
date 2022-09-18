let g:table_mode_corner='|'

augroup TableMode
  autocmd!
  autocmd BufEnter *.md TableModeEnable
augroup END
