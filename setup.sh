#!/usr/bin bash

set -x # debug output

cd `dirname $0`

export DOTENV_HOME=$(pwd)

# zsh
ln -sf ${DOTENV_HOME}/zsh/.zshrc ~/.zshrc

# git
mkdir -p ~/.config/git
ln -sf ${DOTENV_HOME}/.gitconfig ~/.gitconfig

if [[ ! -d ~/dotfiles ]]; then
  ln -s $DOTENV_HOME/.. ~/dotfiles
fi

# tmux
ln -sf ${DOTENV_HOME}/.tmux.conf ~/.tmux.conf

# alacritty
ln -sf ${DOTENV_HOME}/.alacritty.yml ~/.alacritty.yml

# change default shell
sudo chsh -s "$(which zsh)" $USER
