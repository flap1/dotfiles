inoremap <silent> <C-f> <Cmd>call mkdx#InsertIndentHandler(1)<Cr>
inoremap <silent> <C-d> <Cmd>call mkdx#InsertIndentHandler(0)<Cr>

let g:mkdx#settings = { 'highlight': { 'enable': 1 },
      \ 'map' : {'enable': 1 },
      \ 'enter': { 'shift': 1 },
      \ 'links': { 'external': { 'enable': 1 } },
      \ 'toc': { 'text': 'Table of Contents', 'update_on_write': 1 },
      \ 'fold': { 'enable': 1 } }

" let g:mkdx#settings.insert_indent_mappings = 1

