#!/bin/bash

pip install neovim-remote

DOT_FILES=( 
  ".config/zsh"
  ".config/git/.gitconfig" \
  "bin" \
  ".zshenv" \
  ".stylua.toml" \
  ".config/nvim" \
  ".config/wezterm" \
  ".latexmkrc" \
  # ".config/lazygit" \
  # ".config/peco" 
  # "tmux/.tmux.conf" \
  # "tmux/.tmux.conf.local" \
  # "alacritty/.alacritty.yml"
)

__prepare() {
  file=$1
  target=$2

  echo "-- Create symbolic link: $target"

  if [[ -L $target ]]; then
    unlink "$target"
    echo "Unlink $target"
  fi

  if [[ -e $target ]]; then
    backupFile=$target.$(date "+%Y%m%d%H%M%S") # backup
    mv -f "$target" "$backupFile"
    echo "Create backup: $backupFile"
  fi
}

for file in "${DOT_FILES[@]}"
do
  if [[ ! -e $file ]]; then
    echo "$file does not exist"
    continue
  fi
  if [[ -d $file ]]; then
    target=$HOME/$file
  else
    target=$HOME/$(basename "$file")
  fi
  __prepare "$file" "$target"
  ln -s "$(pwd)"/"$file" "$target" 
done

# change default shell
# sudo chsh -s "$(which zsh)" "$USER"

