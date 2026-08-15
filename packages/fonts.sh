#!/bin/bash

mkdir -p ~/.local/share/fonts; cd ~/.local/share/fonts || exit 1

if [ ! -f ~/.local/share/fonts/UDEVGothicNF-Regular.ttf ];then
  wget https://github.com/yuru7/udev-gothic/releases/download/v1.3.1/UDEVGothic_NF_v1.3.1.zip
  unzip UDEVGothic_NF_v1.3.1.zip -d ~/.local/share/fonts
  mv UDEVGothic_NF_v1.3.1/* ./; rm UDEVGothic_NF_v1.3.1/
  rm -rf UDEVGothic_NF_v1.3.1.zip
fi

# if [ ! -e ~/.local/share/fonts/UDEVGothicNF-Regular.ttf ];then
#   wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/JetBrainsMono.zip
#   rm -rf  JetBrainsMono.zip Hack-v3.003-ttf.zip
# fi

if [ ! -f ~/.local/share/fonts/Hack-Regular.ttf ];then
  wget https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip 
  # unzip JetBrainsMono.zip -d ~/.local/share/fonts
  unzip Hack-v3.003-ttf.zip -d ~/.local/share/fonts
  mv ttf/* ./; rm  -rf ttf
  rm -rf Hack-v3.003-ttf.zip
fi

# Times New Roman
if [ ! -f /usr/share/fonts/truetype/msttcorefonts/Times_New_Roman.ttf ]; then
  sudo apt -y install ttf-mscorefonts-installer
fi

# clear and regenerate your font cache and indexes
fc-cache -f -v

