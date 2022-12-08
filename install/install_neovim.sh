#!/bin/bash

function check_and_install () {
    if ! [ -x "$(command -v $1)" ]; then
        if [ "$#" = "2" ]; then
            eval $2
        elif [ "$#" = "1" ]; then
            sudo apt install $1
        else
            echo "arg must be one or two"
            exit
        fi
    fi
}

# neovim
check_and_install nvim  "wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb; sudo apt install ./nvim-linux64.deb; rm ./nvim-linux64.deb"
check_and_install nvr "pip install neovim-remote"

# git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

