#!/bin/bash

if ! [ -x "$(command -v vivaldi)" ]; then
    mkdir -p ~/Downloads/app
    wget https://downloads.vivaldi.com/stable/vivaldi-stable_5.6.2867.36-1_amd64.deb -P ~/Downloads/app
    sudo apt install ~/Downloads/app/vivaldi-stable_5.6.2867.36-1_amd64.deb
fi

sudo update-alternatives --config x-www-browser

