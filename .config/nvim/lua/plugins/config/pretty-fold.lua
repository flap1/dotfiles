require('pretty-fold').setup {
  fill_char = '-',
  sections = {
    left = {
      '+', function() return string.rep('-', vim.v.foldlevel) end,
      ' ', 'number_of_folded_lines', ': ', 'content',
    }
  } -- }
}
