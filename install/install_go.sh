#!/bin/bash

DEFAULT_GO_VERSION="1.16.3"  # デフォルトのGoバージョン
GO_INSTALL_DIR="$HOME/.go"  # Goのインストールディレクトリ

# goenvが既にインストールされているか確認
if ! command -v goenv >/dev/null 2>&1; then
  echo "goenv is not installed. Installing goenv..."
  git clone https://github.com/syndbg/goenv.git ~/.goenv || { echo "Error: Failed to clone goenv repository."; exit 1; }
  export GOENV_ROOT="$HOME/.goenv"
  export PATH="$GOENV_ROOT/bin:$PATH"
  eval "$(goenv init -)"

  # 必要な設定の表示
  echo "Please add the following lines to your shell configuration file (e.g., .bashrc, .zshrc):"
  echo ""
  echo 'export GOENV_ROOT="$HOME/.goenv"'
  echo 'export PATH="$GOENV_ROOT/bin:$PATH"'
  echo 'eval "$(goenv init -)"'
  echo ""
fi

# Check if go is installed
if ! command -v go &> /dev/null; then
    echo "go is not installed."
fi

# List installed versions
installed_versions=$(goenv versions --bare)

if [[ -z "$installed_versions" ]]; then
    echo "No versions of Go are currently installed."
else
    echo "Installed versions of Go:"
    echo "$installed_versions"
    echo ""
fi

# 最新バージョンの確認
echo "Please visit the following link to check the latest Go version:"
echo "https://golang.org/dl/"
echo "If you wish to change the Go version, enter the desired version (e.g., 1.17), or press Enter to use the default version ($DEFAULT_GO_VERSION):"
read -p "> " user_go_version

# ユーザーがバージョンを変更した場合
if [[ -n "$user_go_version" ]]; then
  GO_VERSION="$user_go_version"
else
  GO_VERSION="$DEFAULT_GO_VERSION"
fi

# 既にGoがインストールされているか確認
if [[ -d "$GO_INSTALL_DIR/$GO_VERSION" ]]; then
  echo "Go $GO_VERSION is already installed in $GO_INSTALL_DIR/$GO_VERSION."
  exit 0
fi

# Goのインストール
echo "Installing Go $GO_VERSION..."
goenv install $GO_VERSION || { echo "Error: Failed to install Go $GO_VERSION."; exit 1; }

# インストールしたGoのバージョンを取得
installed_go_version=$(goenv global)

# インストールしたGoのバージョンをグローバルに設定
echo "Setting global Go version to $GO_VERSION..."
goenv global $GO_VERSION || { echo "Error: Failed to set global Go version to $GO_VERSION."; exit 1; }

# 環境変数の設定
echo "Setting Go environment variables..."
eval "$(goenv init -)"
export PATH="$HOME/.goenv/bin:$PATH"

echo "Go $installed_go_version has been installed and configured successfully."

