typeset -g -A key

bindkey "\E[H" beginning-of-line
bindkey "\E[F" end-of-line
bindkey "^K" kill-line
bindkey "^R" backward-word
bindkey "^T" forward-word
