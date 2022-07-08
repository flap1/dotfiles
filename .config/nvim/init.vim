if &compatible
  set nocompatible
endif

" 外部設定ファイルの読み込み
runtime! option.vim
runtime! keymap.vim
if exists('g:vscode')
  runtime! vscode-keymap.vim
endif
runtime! plug.vim

" シンタックスハイライトをONにする
syntax enable

nmap <C-f> :NERDTreeToggle<CR>
let g:airline#extensions#tabline#enabled = 1

" Start NERDTree. If a file is specified, move the cursor to its window.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif
