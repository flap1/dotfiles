#!/bin/bash

source ~/.config/zsh/sh/function.zsh

# japanese
sudo apt install mozc-utils-gui

# pdf viewer
check_and_install okular

# terminal
check_and_install tmux
[ -e "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# cargo
check_and_install cargo "curl https://sh.rustup.rs -sSf | sh"

# zsh
check_and_install zsh
# tools
check_and_install fzf
check_and_install bat "sudo apt install bat; ln -s /usr/bin/batcat ~/dotfiles/bin/bat"
check_and_install rg "curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb; sudo apt install ./ripgrep_13.0.0_amd64.deb; sudo apt-mark hold ripgrep; rm ripgrep_13.0.0_amd64.deb"
check_and_install lsd "cargo install lsd"
check_and_install delta "cargo install git-delta"
check_and_install dust "cargo install du-dust"
check_and_install fd 'sudo apt install fd-find; ln -s $(which fdfind) ~/dotfiles/bin/fd'
check_and_install gawk # for translate-shell
check_and_install neofetch
check_and_install htop

# common
check_and_install curl
check_and_install unzip

# gh
check_and_install go 'wget https://go.dev/dl/go1.19.3.linux-amd64.tar.gz; sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz; rm go1.19.3.linux-amd64.tar.gz'
check_and_install ghq "go install github.com/x-motemen/ghq@latest"
check_and_install gh "sudo apt install gh; gh auth login"

# draw.io
check_and_install drawio "wget https://github.com/jgraph/drawio-desktop/releases/download/v20.3.0/drawio-amd64-20.3.0.deb; sudo apt install ./drawio-amd64-20.3.0.deb; rm drawio-amd64-20.3.0.deb"

# python poetry
curl -sSL https://install.python-poetry.org | python3 -

# font
# sudo apt -y install ttf-mscorefonts-installer

