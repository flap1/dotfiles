#!/bin/bash
# claude, codex and agent (Cursor) through each vendor's own installer. They
# update themselves; mise or a pinned tarball would be a second updater on
# the same binary, and stale copies pile up behind the newer one on PATH.
# Each installer is saved to a file before it runs so a failed download
# never reaches the interpreter half-read.

set -euo pipefail

ASSUME_YES=0
while [ $# -gt 0 ]; do
    case $1 in
        -y | --yes) ASSUME_YES=1 ;;
        -h | --help)
            echo "usage: agent-clis.sh [-y|--yes]"
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
    read -rp "Install Claude Code, Codex and Cursor CLI? (y/n): " yn
    case $yn in
        [Yy]*) ;;
        *)
            echo "Skipped agent CLIs."
            exit 0
            ;;
    esac
fi

tmp=$(mktemp -d)
trap 'rm -r "$tmp"' EXIT

# install_cli <command> <installer url> <interpreter>
install_cli() {
    local cmd=$1 url=$2 shell=$3
    if [ -x "$HOME/.local/bin/$cmd" ]; then
        echo "$cmd: already installed (it updates itself)"
        return 0
    fi
    curl -fsSL -o "$tmp/$cmd.sh" "$url"
    "$shell" "$tmp/$cmd.sh"
}

install_cli claude https://claude.ai/install.sh bash
CODEX_NON_INTERACTIVE=true install_cli codex https://chatgpt.com/codex/install.sh sh
install_cli agent https://cursor.com/install bash
