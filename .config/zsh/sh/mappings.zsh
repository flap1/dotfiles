typeset -g -A key

# EDITOR=nvim contains "vi", which would select the vi keymap. These
# bindings are emacs; say so before any of them are defined.
bindkey -e

bindkey "\E[H" beginning-of-line
bindkey "\E[F" end-of-line
bindkey "^K" kill-line
# ^R is history search (atuin, then fzf). Word hops stay on Meta.
