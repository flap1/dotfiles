let mapleader = "\<Space>"

" leave insert
inoremap jk <esc>

" focus explorer
nmap <leader>e <cmd>call VSCodeNotify('workbench.view.explorer')<cr>
nmap <leader>E <cmd>call VSCodeNotify('workbench.action.toggleSidebarVisibility')<cr>

" save file
nmap <leader>w <cmd>call VSCodeNotify('workbench.action.files.save')<cr>
" close file
nmap <leader>d <cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<cr>
" tab move
nmap <C-h> <cmd>call VSCodeNotify('workbench.action.previousEditor')<cr>
nmap <C-l> <cmd>call VSCodeNotify('workbench.action.nextEditor')<cr>
" tab only
nmap <C-w><C-o> <cmd>call VSCodeNotify('workbench.action.closeOtherEditors')<cr>
" cursor move
nnoremap <S-j> 5j
nnoremap <S-k> 5k
vnoremap <S-j> 5j
vnoremap <S-k> 5k

nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-g> <cmd>Telescope live_grep<cr>
" プロジェクトルートではなく現在開いているファイルを起点にファイル検索
nnoremap <M-p> <cmd>lua require('telescope.builtin').find_files( { cwd = vim.fn.expand('%:p:h') })<cr>
nnoremap <M-g> <cmd>lua require('telescope.builtin').live_grep( { cwd = vim.fn.expand('%:p:h') })<cr>
