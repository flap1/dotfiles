#!/bin/bash

# 追加パッケージのインストール可否を尋ねる
read -p "Do you want to install go additional packages? (y/n): " install_packages

if [[ "$install_packages" == "y" ]]; then
  echo "Installing additional packages..."
  go install github.com/jessfraz/gmailfilters@latest
  # 他の追加パッケージのインストールコマンドをここに追加する
fi

echo "Setup completed."

