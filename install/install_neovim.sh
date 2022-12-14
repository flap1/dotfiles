#!/bin/bash

source ~/.config/zsh/sh/function.zsh

# neovim
check_and_install nvim  "wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb; sudo apt install ./nvim-linux64.deb; rm ./nvim-linux64.deb"
check_and_install nvr "pip install neovim-remote"

# git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

