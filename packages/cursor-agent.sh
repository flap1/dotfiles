#!/bin/bash
# Cursor CLI (`agent`). Not in mise's registry; the official path is
# curl | bash. This downloads the same tarball with a pinned digest.

set -euo pipefail

ASSUME_YES=0
while [ $# -gt 0 ]; do
    case $1 in
        -y | --yes) ASSUME_YES=1 ;;
        -h | --help)
            echo "usage: cursor-agent.sh [-y|--yes]"
            exit 0
            ;;
        *)
            echo "unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

if [ "$ASSUME_YES" != 1 ]; then
    read -rp "Install Cursor CLI (agent)? (y/n): " yn
    case $yn in
        [Yy]*) ;;
        *)
            echo "Skipped Cursor CLI."
            exit 0
            ;;
    esac
fi

VERSION=2026.08.11-e8db854

os=$(uname -s)
arch=$(uname -m)
case "$os" in
    Linux) os=linux ;;
    Darwin) os=darwin ;;
    *)
        echo "Cursor CLI tarball is not pinned for $os; install from https://cursor.com/docs/cli/installation" >&2
        exit 1
        ;;
esac
case "$arch" in
    x86_64 | amd64) arch=x64 ;;
    aarch64 | arm64) arch=arm64 ;;
    *)
        echo "Cursor CLI tarball is not pinned for $arch" >&2
        exit 1
        ;;
esac

spec="$os/$arch"
case "$spec" in
    linux/x64) want=bfff4bf6f4e9dd30c1d0ef0a70b6077b074015dd2948e4c50685d53afdcfce5a ;;
    linux/arm64) want=ea13f92e295f523a99ce8d8f57d6894d21e5d1e2d030ffad718ccd5955ca2eed ;;
    darwin/arm64) want=46044d6d7bcbd7b49a0cf1cd01aa4ca79aaa2ea5f2c7a32965fc0ebe29841790 ;;
    darwin/x64) want=d5c1ce96dd36469e0231d818d4ccf390caac52d94e607c56ebeecc247cab2b1b ;;
    *)
        echo "no digest for $spec" >&2
        exit 1
        ;;
esac

dest="$HOME/.local/share/cursor-agent/versions/$VERSION"
link="$HOME/.local/bin/agent"

if [ -x "$dest/cursor-agent" ] && [ -L "$link" ] && [ "$(readlink "$link")" = "$dest/cursor-agent" ]; then
    echo "agent: $VERSION already linked"
    exit 0
fi

tmp=$(mktemp -d)
cleanup() { rm -r "$tmp"; }
trap cleanup EXIT

url="https://downloads.cursor.com/lab/${VERSION}/${spec}/agent-cli-package.tar.gz"
curl -fsSL -o "$tmp/agent.tgz" "$url"
echo "$want  $tmp/agent.tgz" | sha256sum -c --strict
tar -xzf "$tmp/agent.tgz" -C "$tmp"
mkdir -p "$(dirname "$dest")" "$HOME/.local/bin"
if [ -d "$dest" ]; then
    rm -r "$dest"
fi
mv "$tmp/dist-package" "$dest"
ln -sfn "$dest/cursor-agent" "$link"
echo "agent -> $link ($VERSION)"
