" leaderをスペースに変更
let mapleader = "\<Space>"

function! s:split(...) abort
    let direction = a:1
    let file = exists('a:2') ? a:2 : ''
    call VSCodeCall(direction ==# 'h' ? 'workbench.action.splitEditorDown' : 'workbench.action.splitEditorRight')
    if !empty(file)
        call VSCodeExtensionNotify('open-file', expand(file), 'all')
    endif
endfunction

function! s:splitNew(...)
    let file = a:2
    call s:split(a:1, empty(file) ? '__vscode_new__' : file)
endfunction

function! s:closeOtherEditors()
    call VSCodeNotify('workbench.action.closeEditorsInOtherGroups')
    call VSCodeNotify('workbench.action.closeOtherEditors')
endfunction

function! s:manageEditorHeight(...)
    let count = a:1
    let to = a:2
    for i in range(1, count ? count : 1)
        call VSCodeNotify(to ==# 'increase' ? 'workbench.action.increaseViewHeight' : 'workbench.action.decreaseViewHeight')
    endfor
endfunction

function! s:manageEditorWidth(...)
    let count = a:1
    let to = a:2
    for i in range(1, count ? count : 1)
        call VSCodeNotify(to ==# 'increase' ? 'workbench.action.increaseViewWidth' : 'workbench.action.decreaseViewWidth')
    endfor
endfunction

command! -complete=file -nargs=? Split call <SID>split('h', <q-args>)
command! -complete=file -nargs=? Vsplit call <SID>split('v', <q-args>)
command! -complete=file -nargs=? New call <SID>split('h', '__vscode_new__')
command! -complete=file -nargs=? Vnew call <SID>split('v', '__vscode_new__')
command! -bang Only if <q-bang> ==# '!' | call <SID>closeOtherEditors() | else | call VSCodeNotify('workbench.action.joinAllGroups') | endif

" buffer management
nnoremap <Leader>n <Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>
xnoremap <Leader>n <Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>

nnoremap <Leader>q <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
xnoremap <Leader>q <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
nnoremap <Leader>c <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
xnoremap <Leader>c <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
nnoremap <Leader><C-c> <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
xnoremap <Leader><C-c> <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>

" window/splits management
nnoremap <Leader>s <Cmd>call <SID>split('h')<CR>
xnoremap <Leader>s <Cmd>call <SID>split('h')<CR>
nnoremap <Leader><C-s> <Cmd>call <SID>split('h')<CR>
xnoremap <Leader><C-s> <Cmd>call <SID>split('h')<CR>

nnoremap <Leader>v <Cmd>call <SID>split('v')<CR>
xnoremap <Leader>v <Cmd>call <SID>split('v')<CR>
nnoremap <Leader><C-v> <Cmd>call <SID>split('v')<CR>
xnoremap <Leader><C-v> <Cmd>call <SID>split('v')<CR>

nnoremap <Leader>= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>
xnoremap <Leader>= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>
nnoremap <Leader>_ <Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>
xnoremap <Leader>_ <Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>

nnoremap <Leader>+ <Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>
xnoremap <Leader>+ <Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>
nnoremap <Leader>- <Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>
xnoremap <Leader>- <Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>
nnoremap <Leader>> <Cmd>call <SID>manageEditorWidth(v:count,  'increase')<CR>
xnoremap <Leader>> <Cmd>call <SID>manageEditorWidth(v:count,  'increase')<CR>
nnoremap <Leader>< <Cmd>call <SID>manageEditorWidth(v:count,  'decrease')<CR>
xnoremap <Leader>< <Cmd>call <SID>manageEditorWidth(v:count,  'decrease')<CR>

nnoremap <Leader>o <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>
xnoremap <Leader>o <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>
nnoremap <Leader><C-o> <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>
xnoremap <Leader><C-o> <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>

" window navigation
nnoremap <Leader>j <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
xnoremap <Leader>j <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
nnoremap <Leader>k <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
xnoremap <Leader>k <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
nnoremap <Leader>h <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
xnoremap <Leader>h <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
nnoremap <Leader>l <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>
xnoremap <Leader>l <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>

nnoremap <Leader><C-j> <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
xnoremap <Leader><C-j> <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
nnoremap <Leader><C-i> <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
xnoremap <Leader><C-i> <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
nnoremap <Leader><C-h> <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
xnoremap <Leader><C-h> <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
nnoremap <Leader><C-l> <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>
xnoremap <Leader><C-l> <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>

nnoremap <Leader><S-j> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupDown')<CR>
xnoremap <Leader><S-j> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupDown')<CR>
nnoremap <Leader><S-k> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupUp')<CR>
xnoremap <Leader><S-k> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupUp')<CR>
nnoremap <Leader><S-h> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupLeft')<CR>
xnoremap <Leader><S-h> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupLeft')<CR>
nnoremap <Leader><S-l> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupRight')<CR>
xnoremap <Leader><S-l> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupRight')<CR>

" nnoremap <Leader>w <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
" xnoremap <Leader>w <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
" nnoremap <Leader><C-w> <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
" xnoremap <Leader><C-w> <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
" nnoremap <Leader>W <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
" xnoremap <Leader>W <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
" nnoremap <Leader>p <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
" xnoremap <Leader>p <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>

nnoremap <Leader>t <Cmd>call VSCodeNotify('workbench.action.focusFirstEditorGroup')<CR>
xnoremap <Leader>t <Cmd>call VSCodeNotify('workbench.action.focusFirstEditorGroup')<CR>
nnoremap <Leader>b <Cmd>call VSCodeNotify('workbench.action.focusLastEditorGroup')<CR>
xnoremap <Leader>b <Cmd>call VSCodeNotify('workbench.action.focusLastEditorGroup')<CR>

nnoremap <Leader>p <Cmd>call VSCodeNotify('find-it-faster.findFiles')<CR>
xnoremap <Leader>p <Cmd>call VSCodeNotify('find-it-faster.findFiles')<CR>
nnoremap <M-p> <Cmd>call VSCodeNotify('find-it-faster.findWithinFiles')<CR>
xnoremap <M-p> <Cmd>call VSCodeNotify('find-it-faster.findWithinFiles')<CR>
