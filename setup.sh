#!/bin/bash

set -e

# Create symbolic link with timestamp and move existing file or directory if necessary.
create_symlink() {
    src=$(realpath "$1")
    dst=$2
    timestamp=$(date "+%Y%m%d%H%M%S")

    if [ -e "$dst" -o -h "$dst" ]; then
        if [ -L "$dst" ]; then
            read -p "Do you want to remove the symbolic link $dst? (y/n): " yn
            case $yn in
                [Yy]* )
                    unlink "$dst" || sudo unlink "$dst"
                    echo "Symbolic link $dst has been removed.";;
                * )
                    echo "Canceled."
                    exit;;
            esac
        else
            read -p "Do you want to move $dst to ${dst}.${timestamp}? (y/n): " yn
            case $yn in
                [Yy]* )
                    mv "$dst" "${dst}.${timestamp}" || sudo mv "$dst" "${dst}.${timestamp}"
                    echo "$dst has been moved to ${dst}.${timestamp}.";;
                * )
                    echo "Canceled."
                    exit;;
            esac
        fi
    fi

    parent_dir=$(dirname "$dst")
    if [ ! -d "$parent_dir" ]; then
        read -p "Parent directory $parent_dir does not exist. Do you want to create it? (y/n): " yn
        case $yn in
            [Yy]* )
                mkdir -p "$parent_dir" || sudo mkdir -p "$parent_dir"
                echo "Parent directory $parent_dir has been created.";;
            * )
                echo "Canceled. Skipping symbolic link creation."
                return;;
        esac
    fi

    if ! ln -s "$src" "$dst"; then
        echo "Failed to create symbolic link $dst. Retrying with sudo..."
        sudo ln -sf "$src" "$dst"
    fi

    echo "Symbolic link $dst has been created to $src."
}

# create symbolic link
create_symlink "bin" "$HOME/bin"
create_symlink ".git_template" "$HOME/.git_template"
create_symlink ".latexmkrc" "$HOME/.latexmkrc"
create_symlink ".remarkrc.yml" "$HOME/.remarkrc.yml"
create_symlink ".zprofile" "$HOME/.zprofile"
create_symlink ".config/zsh" "$HOME/.config/zsh"
create_symlink ".config/nvim" "$HOME/.config/nvim"
create_symlink ".config/wezterm" "$HOME/.config/wezterm"
create_symlink ".config/gnome" "$HOME/.config/gnome"
create_symlink ".config/pictures" "$HOME/.config/pictures"
create_symlink ".config/Code/User/settings.json" "$HOME/.config/Code/User/settings.json"
create_symlink ".config/tmux/.tmux.conf" "$HOME/.tmux.conf"
create_symlink ".config/git/.gitconfig" "$HOME/.gitconfig"
create_symlink ".config/alacritty/.alacritty.yml" "$HOME/.alacritty.yml"
create_symlink ".config/ansible/.ansible.cfg" "$HOME/.ansible.cfg"

# mkdir
[ -d "$HOME/.git-worktrees" ] || mkdir "$HOME/.git-worktrees"

# change default shell
if [ "$(basename "$SHELL")" != "zsh" ]; then
    read -p "Do you want to change the default shell to zsh? (y/n): " yn
    case $yn in
        [Yy]* )
            sudo chsh -s "$(which zsh)" "$USER"
            echo "Default shell has been changed to zsh.";;
        * )
            echo "Canceled."
            exit;;
    esac
else
    echo "The default shell is already zsh."
fi

