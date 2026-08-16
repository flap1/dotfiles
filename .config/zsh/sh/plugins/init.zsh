# sheldon. Pins are git revisions in plugins.toml. fzf is a mise tool.

if command -v sheldon >/dev/null 2>&1; then
    eval "$(sheldon source)"
    bindkey '^Y' autosuggest-accept
else
    autoload -Uz compinit && compinit -C
fi

if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --color=always --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
export FZF_DEFAULT_OPTS="--ansi"

command -v gh >/dev/null && eval "$(gh completion -s zsh)"
command -v uv >/dev/null && eval "$(uv generate-shell-completion zsh 2>/dev/null)"
