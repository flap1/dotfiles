#!/bin/bash

source ~/.config/zsh/sh/function.zsh

check_and_install chrome-gnome-shell
check_and_install gnome-tweaks
check_and_install gnome-shell-extensions
check_and_install dconf-editor

if [ ! -e ~/.config/pictures/Monterey2.png ]; then
	gdrive_download https://drive.google.com/file/d/1YiOxt3_V-ezSxgIVFwn2s5gGCRQfA0hK/view?usp=share_link ~/.config/pictures/Monterey2.png
fi

if [ ! -e ~/.themes/Mojave-Dark ]; then
	mkdir -p ~/.themes; cd ~/.themes
	gdrive_download https://drive.google.com/file/d/1qrkARtP-eeKN9URP1-pq-8HfvPtr4IFA/view?usp=share_link Mojave-Dark.tar.xz
	tar -xvf Mojave-Dark.tar.xz
	rm Mojave-Dark.tar.xz
fi
	
if [ ! -e ~/.icons/McMojave-cursors ]; then
	mkdir -p ~/.icons; cd ~/.icons
	gdrive_download https://drive.google.com/file/d/1twWJDAxkEfgt2zzry6f8hnRX_nMjCWRK/view?usp=share_link McMojave-cursors.tar.xz
	tar -xvf McMojave-cursors.tar.xz
	rm  McMojave-cursors.tar.xz
fi

if [ ! -e ~/.icons/McMojave-circle ]; then
	mkdir -p ~/.icons; cd ~/.icons
	gdrive_download https://drive.google.com/file/d/1RWo4ikP_voVbRwEi2h-NXWj4u4wJLesi/view?usp=share_link McMojave-circle.tar.xz
	tar -xvf McMojave-circle.tar.xz
	cp -r McMojave-circle McMojave-circle-dark
	rm  McMojave-circle.tar.xz
fi

