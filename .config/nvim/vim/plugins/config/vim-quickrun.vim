""
"" quickrun
""
" let g:quickrun_config = {
" \   'tex': {
" \       'command': 'lualatex',
" \       'exec': ['%c -synctex=1 -interaction=nonstopmode %s', 'xdg-open %s:r.pdf']
" \   },
" \}
" let g:quickrun_config = {
" \   'tex': {
" \       'command': 'latexmk',
" \       'exec': ['%c -gg -pdfdvi %s', 'xdg-open %s:r.pdf']
" \   },
" \}
let g:quickrun_config = {}
let g:quickrun_config['tex'] = {
\ 'command' : 'latexmk',
\ 'outputter' : 'error',
\ 'outputter/error/success' : 'null',
\ 'outputter/error/error' : 'quickfix',
\ 'srcfile' : expand("%"),
\ 'cmdopt': '-pdfdvi',
\ 'hook/sweep/files' : [
\                      '%S:p:r.aux',
\                      '%S:p:r.bbl',
\                      '%S:p:r.blg',
\                      '%S:p:r.dvi',
\                      '%S:p:r.fdb_latexmk',
\                      '%S:p:r.fls',
\                      '%S:p:r.log',
\                      '%S:p:r.out'
\                      ],
\ 'exec': '%c %s %a %o',
\}

" 部分的に選択してコンパイル
" http://auewe.hatenablog.com/entry/2013/12/25/033416 を参考に
let g:quickrun_config.tmptex = {
\   'exec': [
\           'mv -f %s %a/tmptex.tex',
\           'latexmk_tmptex_wrapper %a',
\           ],
\   'outputter' : 'error',
\   'outputter/error/error' : 'quickfix',
\
\   'hook/eval/enable' : 1,
\   'hook/eval/cd' : "%s:r",
\
\   'hook/eval/template' : '\documentclass{ltjsarticle}'
\                         .'\usepackage{float}'
\                         .'\usepackage{here}'
\                         .'\usepackage{url}'
\                         .'\usepackage{graphicx}'
\                         .'\usepackage{amsmath,amssymb,amsthm,ascmac,mathrsfs}'
\                         .'\allowdisplaybreaks[1]'
\                         .'\theoremstyle{definition}'
\                         .'\newtheorem{theorem}{定理}'
\                         .'\newtheorem*{theorem*}{定理}'
\                         .'\newtheorem{definition}[theorem]{定義}'
\                         .'\newtheorem*{definition*}{定義}'
\                         .'\renewcommand\vector[1]{\mbox{\boldmath{\$#1\$}}}'
\                         .'\makeatletter'
\                         .'\def\input\@path{{..//}{../..//}}'
\                         .'\makeatother'
\                         .'\begin{document}'
\                         .'%s'
\                         .'\end{document}',
\
\   'hook/sweep/files' : [
\                        '%a/tmptex.latex',
\                        '%a/tmptex.out',
\                        '%a/tmptex.fdb_latexmk',
\                        '%a/tmptex.log',
\                        '%a/tmptex.aux',
\                        '%a/tmptex.dvi'
\                        ],
\}

vnoremap <silent> <F5> :<C-u>
      \ let @x = expand("%:p:h:gs?\\\\?/?")<CR>
      \:QuickRun -mode v -type tmptex -args @x<CR>

" QuickRun and view compile result quickly (but don't preview pdf file)
nnoremap <silent> <F5> :QuickRun<CR>

augroup filetype
  autocmd!
  " tex file (I always use latex)
  autocmd BufRead,BufNewFile *.tex set filetype=tex
augroup END

" autocmd BufWritePost,FileWritePost *.tex QuickRun tex

