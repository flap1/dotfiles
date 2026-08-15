## =========================================================================
## Post Execution
## =========================================================================

# -------------------------------------------------------------------------
# mise (multi-language version manager)
# -------------------------------------------------------------------------
if command -v mise > /dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

# -------------------------------------------------------------------------
# uv (Python package manager)
# -------------------------------------------------------------------------
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# -------------------------------------------------------------------------
# AWS
# -------------------------------------------------------------------------
[ -f "$HOME/.aws/config" ] && export AWS_VAULT_BACKEND=file

# -------------------------------------------------------------------------
# CUDA
# -------------------------------------------------------------------------
if [ -d "/usr/local/cuda/bin" ]; then
    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
fi

# -------------------------------------------------------------------------
# ROS (optional - only loaded when present)
# -------------------------------------------------------------------------
[ -f "/opt/ros/humble/setup.zsh" ] && source "/opt/ros/humble/setup.zsh"

# -------------------------------------------------------------------------
# zoxide (smarter cd)
# -------------------------------------------------------------------------
if command -v zoxide > /dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# -------------------------------------------------------------------------
# atuin (shell history with SQLite + sync)
# -------------------------------------------------------------------------
if command -v atuin > /dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi

# -------------------------------------------------------------------------
# Starship prompt
# -------------------------------------------------------------------------
if command -v starship > /dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# -------------------------------------------------------------------------
# opencode (optional - only loaded when present)
# -------------------------------------------------------------------------
if [ -d "$HOME/.opencode/bin" ]; then
    export PATH="$HOME/.opencode/bin:$PATH"
fi

# -------------------------------------------------------------------------
# dotfiles: once-a-day inbound check
# -------------------------------------------------------------------------
# Backgrounded and silent unless origin is ahead. It fetches, so it must never
# be in the foreground of a prompt.
if command -v dotfiles >/dev/null; then
    (dotfiles check &) 2>/dev/null
fi
