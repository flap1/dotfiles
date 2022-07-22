#!/bin bash

ZSHRC="zsh/.zshrc"
TMUXCONF="tmux/.tmux.conf"
TMUXCONF_LOCAL="tmux/.tmux.conf.local"
GIT_CONFIG="git/.gitconfig"
ALACRITTY="alacritty/.alacritty.yml"
PECO="peco"
NVIM="nvim"

DOT_FILES=( $ZSHRC $TMUXCONF $TMUXCONF_LOCAL $GIT_CONFIG $ALACRITTY $PECO $NVIM )

__prepare() {
  file=$1
  target=$2

  echo ""
  echo "-- Create symbolic link: $target"

  if [[ -L $target ]]; then
    unlink $target
    echo "Unlink $target"
  fi

  if [[ -e $target ]]; then
    backupFile=$target.`date "+%Y%m%d%H%M%S"` # backup
    mv -f $target $backupFile
    echo "Create backup: $backupFile"
  fi
}

mkdir -p $HOME/.config

for file in ${DOT_FILES[@]}
do
  if [[ ! -e $file ]]; then
    echo "$file does not exist"
    continue
  fi
  if [[ -d $file ]]; then
    target=$HOME/.config/$file
  else
    target=$HOME/`basename ${file}`
  fi
  __prepare $file $target
  ln -s `pwd`/${file} $target 
done

cd `dirname $0`

# change default shell
sudo chsh -s "$(which zsh)" $USER
