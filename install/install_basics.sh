#!/bin/bash

set -e

# Install if not found, with y/n prompt.
# Already installed tools are skipped silently.
ask_and_install() {
    local name=$1
    local cmd=$2
    local install_cmd=$3
    if command -v "$cmd" > /dev/null 2>&1; then
        echo "$name: already installed, skipping."
        return
    fi
    read -rp "Install $name? (y/n): " yn
    case $yn in
        [Yy]*) eval "$install_cmd" ;;
        *) echo "Skipped $name." ;;
    esac
}

# -------------------------------------------------------------------------
# System packages (sudo required - unavoidable)
# -------------------------------------------------------------------------
# zsh, git, curl, unzip, gawk are system-level and have no user-local alternative
sudo apt update
ask_and_install "zsh"   zsh   "sudo apt install -y zsh"
ask_and_install "git"   git   "sudo apt install -y git"
ask_and_install "curl"  curl  "sudo apt install -y curl"
ask_and_install "unzip" unzip "sudo apt install -y unzip"
ask_and_install "gawk"  gawk  "sudo apt install -y gawk"  # for translate-shell
ask_and_install "clang" clang "sudo apt install -y clang libclang-dev"  # required by cargo crates using bindgen (e.g. ouch)

# Japanese input (sudo required, no alternative)
ask_and_install "fcitx5-mozc" fcitx5 "sudo apt install -y fcitx5 fcitx5-mozc"

# Wayland clipboard (sudo required)
ask_and_install "wl-clipboard" wl-copy "sudo apt install -y wl-clipboard"

# -------------------------------------------------------------------------
# Rust toolchain (user-local: ~/.cargo)
# -------------------------------------------------------------------------
ask_and_install "rustup/cargo" cargo "curl https://sh.rustup.rs -sSf | sh -s -- -y && source $HOME/.cargo/env"

# -------------------------------------------------------------------------
# CLI tools via cargo (all user-local, no sudo)
# -------------------------------------------------------------------------
ask_and_install "eza"    eza    "cargo install eza"
ask_and_install "bat"    bat    "cargo install bat"
ask_and_install "ripgrep (rg)" rg "cargo install ripgrep"
ask_and_install "fd"     fd     "cargo install fd-find"
ask_and_install "delta"  delta  "cargo install git-delta"
ask_and_install "fzf"    fzf    "cargo install fzf-bin"
ask_and_install "zoxide" zoxide "cargo install zoxide"
ask_and_install "trashy" trash  "cargo install trashy"

# -------------------------------------------------------------------------
# More CLI tools via cargo (user-local, no sudo)
# -------------------------------------------------------------------------
ask_and_install "atuin"     atuin     "cargo install atuin"
ask_and_install "dust"      dust      "cargo install du-dust"
ask_and_install "bottom"    btm       "cargo install bottom"
ask_and_install "procs"     procs     "cargo install procs"
ask_and_install "tealdeer"  tldr      "cargo install tealdeer && tldr --update"
ask_and_install "just"      just      "cargo install just"
ask_and_install "hyperfine" hyperfine "cargo install hyperfine"
ask_and_install "tokei"     tokei     "cargo install tokei"
ask_and_install "xh"        xh        "cargo install xh"
ask_and_install "hexyl"     hexyl     "cargo install hexyl"
ask_and_install "ouch"      ouch      "cargo install ouch"
ask_and_install "grex"      grex      "cargo install grex"
ask_and_install "gping"     gping     "cargo install gping"
ask_and_install "watchexec" watchexec "cargo install watchexec-cli"
ask_and_install "yazi"      yazi      "cargo install --locked yazi-build && cargo install --locked yazi-fm yazi-cli"
ask_and_install "bob (neovim manager)" bob "cargo install bob-nvim && bob use stable"

# -------------------------------------------------------------------------
# Version managers (user-local)
# -------------------------------------------------------------------------
ask_and_install "mise" mise "curl https://mise.run | sh"
ask_and_install "uv"   uv   "curl -LsSf https://astral.sh/uv/install.sh | sh"
ask_and_install "pynvim (neovim python provider)" pynvim-python "uv tool install pynvim"

# -------------------------------------------------------------------------
# Shell linting/formatting tools (user-local via mise)
# -------------------------------------------------------------------------
ask_and_install "shfmt"      shfmt      "mise use --global shfmt"
ask_and_install "shellcheck" shellcheck "mise use --global shellcheck"

# -------------------------------------------------------------------------
# Starship prompt (user-local via --bin-dir)
# -------------------------------------------------------------------------
ask_and_install "starship" starship "curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir $HOME/.local/bin -y"

# -------------------------------------------------------------------------
# GitHub CLI (user-local binary)
# -------------------------------------------------------------------------
ask_and_install "gh" gh "$(cat <<'EOF'
  mkdir -p "$HOME/.local/bin"
  VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep tag_name | cut -d'"' -f4 | tr -d v)
  curl -sL "https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_amd64.tar.gz" | tar xz -C /tmp
  cp "/tmp/gh_${VERSION}_linux_amd64/bin/gh" "$HOME/.local/bin/gh"
  gh auth login
EOF
)"

if command -v ghq > /dev/null 2>&1; then
    echo "ghq: already installed, skipping."
else
    read -rp "Install ghq? (y/n): " yn
    if [[ $yn == [Yy]* ]]; then
        if ! command -v go > /dev/null 2>&1; then
            echo "go not found. Installing via mise..."
            mise use --global go@latest
            eval "$(mise activate bash)"
        fi
        go install github.com/x-motemen/ghq@latest
    else
        echo "Skipped ghq."
    fi
fi

if command -v lazygit > /dev/null 2>&1; then
    echo "lazygit: already installed, skipping."
else
    read -rp "Install lazygit? (y/n): " yn
    if [[ $yn == [Yy]* ]]; then
        if ! command -v go > /dev/null 2>&1; then
            echo "go not found. Installing via mise..."
            mise use --global go@latest
            eval "$(mise activate bash)"
        fi
        go install github.com/jesseduffield/lazygit@latest
    else
        echo "Skipped lazygit."
    fi
fi

if command -v lazydocker > /dev/null 2>&1; then
    echo "lazydocker: already installed, skipping."
else
    read -rp "Install lazydocker? (y/n): " yn
    if [[ $yn == [Yy]* ]]; then
        if ! command -v go > /dev/null 2>&1; then
            echo "go not found. Installing via mise..."
            mise use --global go@latest
            eval "$(mise activate bash)"
        fi
        go install github.com/jesseduffield/lazydocker@latest
    else
        echo "Skipped lazydocker."
    fi
fi

# -------------------------------------------------------------------------
# Docker (sudo required for daemon install + usermod)
# -------------------------------------------------------------------------
if command -v docker > /dev/null 2>&1; then
    echo "docker: already installed, skipping."
else
    read -rp "Install Docker? (y/n): " yn
    if [[ $yn == [Yy]* ]]; then
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker "$USER"
        echo "Docker installed. Re-login to use without sudo."
    else
        echo "Skipped Docker."
    fi
fi

# docker compose plugin (user-local: ~/.docker/cli-plugins, no sudo)
if docker compose version > /dev/null 2>&1; then
    echo "docker compose: already installed, skipping."
else
    read -rp "Install docker compose plugin? (y/n): " yn
    if [[ $yn == [Yy]* ]]; then
        mkdir -p "$HOME/.docker/cli-plugins"
        curl -sL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
            -o "$HOME/.docker/cli-plugins/docker-compose"
        chmod +x "$HOME/.docker/cli-plugins/docker-compose"
        echo "docker compose installed."
    else
        echo "Skipped docker compose."
    fi
fi

# -------------------------------------------------------------------------
# WezTerm (terminal emulator)
# -------------------------------------------------------------------------
bash "$(dirname "$0")/install_wezterm.sh"

# -------------------------------------------------------------------------
# tmux plugins (TPM + catppuccin + cpu + sensible + resurrect + continuum)
# -------------------------------------------------------------------------
bash "$(dirname "$0")/install_tmux.sh"

# -------------------------------------------------------------------------
# Fonts (user-local: ~/.local/share/fonts)
# -------------------------------------------------------------------------
read -rp "Install Nerd Fonts? (y/n): " yn
[[ $yn == [Yy]* ]] && bash "$(dirname "$0")/install_fonts.sh" || echo "Skipped fonts."
