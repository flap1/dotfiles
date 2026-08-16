# Interactive-only. A name still means the program it names.
# ls/eza is the one exception: the flag grammar is the same family.
# Tools that mise has not installed yet keep the Unix verb.

(( $+commands[trash] )) && alias rm='trash put'
alias cp='cp -i'
alias mv='mv -i'
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias rez='exec zsh'

if (( $+commands[eza] )); then
    alias ls='eza --group-directories-first'
    alias la='eza -A --group-directories-first'
    alias ll='eza -Ahl --group-directories-first'
    alias lt='eza -Ahl --tree --group-directories-first'
fi

alias vi="$EDITOR"
alias vim="$EDITOR"

alias lg='lazygit'

if [[ -n ${WAYLAND_DISPLAY:-} ]] && (( $+commands[wl-copy] )); then
    alias -g C='| tee >(wl-copy)'
    alias -g Y='| wl-copy'
elif (( $+commands[pbcopy] )); then
    alias -g C='| tee >(pbcopy)'
    alias -g Y='| pbcopy'
fi
