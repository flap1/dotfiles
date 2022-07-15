function split(...)
  local arg = {...}
  local direction = arg[1]
  local file = arg[2] and arg[2] or ''
  VSCodeCall(direction == 'h' and 'workbench.action.splitEditorDown' or 'workbench.action.splitEditorRight')
  if file ~= '' then
    VSCodeExtensionNotify('open-file', vim.fn.expand(file), 'all')
  end
end

function splitNew(...)
  local arg = {...}
  local file = arg[2]
  split(arg[1], file == '' and '__vscode_new__' or file)
end

function closeOtherEditors()
  VSCodeNotify('workbench.action.closeEditorsInOtherGroups')
  VSCodeNotify('workbench.action.closeOtherEditors')
end

function manageEditorHeight(...)
  local arg = {...}
  local count, to = arg[1], arg[2]
  for i = 1, count and count or 1 do
    VSCodeNotify(to == 'increase' and 'workbench.action.increaseViewHeight' or 'workbench.action.decreaseViewHeight')
  end
end

function manageEditorWidth(...)
  local arg = {...}
  local count, to = arg[1], arg[2]
  for i = 1, count and count or 1 do
    VSCodeNotify(to == 'increase' and 'workbench.action.increaseViewWidth' or 'workbench.action.decreaseViewWidth')
	end
end

vim.cmd [[command! -complete=file -nargs=? Split call <SID>split('h', <q-args>)]]
vim.cmd [[command! -complete=file -nargs=? Vsplit call <SID>split('v', <q-args>)]]
vim.cmd [[command! -complete=file -nargs=? New call <SID>split('h', '__vscode_new__')]]
vim.cmd [[command! -complete=file -nargs=? Vnew call <SID>split('v', '__vscode_new__')]]
vim.cmd [[command! -bang Only if <q-bang> ==# '!' | call <SID>closeOtherEditors() | else | call VSCodeNotify('workbench.action.joinAllGroups') | endif]]

-- buffer management
vim.keymap.set({'n', 'x'}, "<Leader>n", "<<Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>q", "<<Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>c", "<<Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>>", { noremap = true, silent == true})

-- window/splits management
vim.keymap.set({'n', 'x'}, "<Leader>s", "<<Cmd>call <SID>split('h')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>v", "<<Cmd>call <SID>split('v')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>=", "<<Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>_", "<<Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>+", "<<Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>-", "<<Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>>", "<<Cmd>call <SID>manageEditorWitdh(v:count, 'increase')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader><", "<<Cmd>call <SID>manageEditorWitdh(v:count, 'decrease')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>o", "<<Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>>", { noremap = true, silent == true})

-- window navigation
vim.keymap.set({'n', 'x'}, "<Leader>j", "<<Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>k", "<<Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>h", "<<Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>l", "<<Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>>", { noremap = true, silent == true})

vim.keymap.set({'n', 'x'}, "<Leader><S-j>", "<<Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupDown')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader><S-k>", "<<Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupUp')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader><S-h>", "<<Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupLeft')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader><S-l>", "<<Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupRight')<CR>>", { noremap = true, silent == true})

-- vim.keymap.set({'n', 'x'}, "<Leader>w", "<<Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>>", { noremap = true, silent == true})
-- vim.keymap.set({'n', 'x'}, "<Leader>W", "<<Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>>", { noremap = true, silent == true})

vim.keymap.set({'n', 'x'}, "<Leader>t", "<<Cmd>call VSCodeNotify('workbench.action.focusFirstEditorGroup')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<Leader>b", "<<Cmd>call VSCodeNotify('workbench.action.focusLastEditorGroup')<CR>>", { noremap = true, silent == true})

vim.keymap.set({'n', 'x'}, "<Leader>p", "<<Cmd>call VSCodeNotify('find-it-faster.findFiles')<CR>>", { noremap = true, silent == true})
vim.keymap.set({'n', 'x'}, "<M-p>", "<<Cmd>call VSCodeNotify('find-it-faster.findWithinFiles')<CR>>", { noremap = true, silent == true})

-- view explorer
vim.keymap.set("n", "<Leader>e", "<<Cmd>call VSCodeNotify('workbench.view.explorer')<CR>>", { noremap = true, silent == true})

-- toggle Sidebar Visibility
vim.keymap.set("n", "<Leader>E", "<<Cmd>call VSCodeNotify('workbench.action.toggleSidebarVisibility')<CR>>", { noremap = true, silent == true})

-- save file
vim.keymap.set("n", "<Leader>w", "<<Cmd>call VSCodeNotify('workbench.action.files.save')<CR>>", { noremap = true, silent == true})
