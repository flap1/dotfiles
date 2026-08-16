# sheldon. Pins are git revisions in plugins.toml. fzf is a mise tool.
# Binary present is not enough: sheldon source fails if it cannot lock its
# config dir, and that must not skip compinit (gh/uv completions call compdef).

_dotfiles_compinit() {
    autoload -Uz compinit && compinit -C
}

if command -v sheldon >/dev/null 2>&1; then
    if _sheldon_src=$(sheldon source); then
        eval "$_sheldon_src"
        bindkey '^Y' autosuggest-accept
    else
        _dotfiles_compinit
    fi
    unset _sheldon_src
else
    _dotfiles_compinit
fi
unset -f _dotfiles_compinit

if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --color=always --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
export FZF_DEFAULT_OPTS="--ansi"

if (( $+functions[compdef] )); then
    command -v gh >/dev/null && eval "$(gh completion -s zsh)"
    command -v uv >/dev/null && eval "$(uv generate-shell-completion zsh 2>/dev/null)"
fi
