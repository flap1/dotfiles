#!/bin/bash

DOT_FILES=( 
  ".config/zsh/.zshrc" \
  ".config/git/.gitconfig" \
  ".stylua.toml" \
  ".config/nvim" \
  ".config/wezterm" \
  ".config/lazygit" \
  ".latexmkrc" \
  # ".config/peco" 
  # "tmux/.tmux.conf" \
  # "tmux/.tmux.conf.local" \
  # "alacritty/.alacritty.yml"
)

__prepare() {
  file=$1
  target=$2

  echo ""
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

mkdir -p "$HOME"

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

cd $"dirname $0"

# change default shell
sudo chsh -s "$(which zsh)" "$USER"
