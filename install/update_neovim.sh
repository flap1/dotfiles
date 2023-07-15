#!/bin/bash

# uninstall neovim: `which nvim` 
nvim_path=$(which nvim)

if [[ -n $nvim_path ]]; then
  echo "nvim path: $nvim_path"

  # nvim 実行可能ファイルを削除
  sudo rm "$nvim_path"

  echo "nvim has been removed."
else
  echo "nvim is not found."
fi

neovim_folder="$HOME/neovim"

if [ -d "$neovim_folder" ]; then
  echo "Found existing neovim folder at $neovim_folder"
  cd "$neovim_folder" || exit
else
  echo "neovim folder not found. Cloning neovim repository..."
  git clone https://github.com/neovim/neovim.git "$neovim_folder"
  cd "$neovim_folder" || exit
fi

make CMAKE_BUILD_TYPE=Release
sudo make install

