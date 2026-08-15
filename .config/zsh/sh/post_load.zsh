if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

if [ -d "/usr/local/cuda/bin" ]; then
    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
fi

[ -f "/opt/ros/humble/setup.zsh" ] && source "/opt/ros/humble/setup.zsh"

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if [ -d "$HOME/.opencode/bin" ]; then
    export PATH="$HOME/.opencode/bin:$PATH"
fi

if command -v dotfiles >/dev/null; then
    (dotfiles check &) 2>/dev/null
fi
