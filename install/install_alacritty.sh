#!/bin/bash

cd ~
if [ ! -d ~/alacritty ]; then
    git clone https://github.com/alacritty/alacritty.git
fi
cd alacritty
# rustup update
rustup override set stable
rustup update stable
# 必要パッケージ
sudo apt install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3
# build
cargo build --release
# terminfoのチェック
infocmp alacritty
# ↑でエラーがでた場合terminfoの登録
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
# desktop entryの追加
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
# manualの追加
sudo mkdir -p /usr/local/share/man/man1
gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
# x-terminal-emulatorのalacrittyの優先度を60に
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/alacritty 60
# 設定状況確認
sudo update-alternatives --display x-terminal-emulator
rm -rf ~/alacritty

