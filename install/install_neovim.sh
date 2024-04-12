#!/bin/bash

source ../.config/zsh/sh/function.zsh

# neovim
check_and_install nvim  "wget https://github.com/neovim/neovim/releases/download/v0.8.3/nvim-linux64.deb; sudo apt install ./nvim-linux64.deb; rm ./nvim-linux64.deb"
check_and_install nvr "pip install neovim-remote"

# git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# node
[ -x "$(command -v npm)" ] && [ ! -e "$HOME/node_modules/remark" ] || cd "$HOME" || npm install remark remark-validate-links remark-inline-links remark-frontmatter

