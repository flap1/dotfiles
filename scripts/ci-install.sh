#!/usr/bin/env bash
# Throwaway HOME: install.sh twice, second run must change nothing.
# Needs node and jq. Does not run bootstrap.sh (that needs sudo apt).

set -euo pipefail

src=$(git rev-parse --show-toplevel)
export HOME
HOME=$(mktemp -d)
mkdir -p "$HOME"
cp -r "$src" "$HOME/dotfiles"
cd "$HOME/dotfiles"

./install.sh --yes >/tmp/first.log 2>&1 || {
    cat /tmp/first.log
    exit 1
}
find "$HOME" -path "$HOME/dotfiles" -prune -o -print | sort >/tmp/first.state

./install.sh --yes >/tmp/second.log 2>&1 || {
    cat /tmp/second.log
    exit 1
}
find "$HOME" -path "$HOME/dotfiles" -prune -o -print | sort >/tmp/second.state

if ! diff -u /tmp/first.state /tmp/second.state; then
    echo "second run changed the filesystem: install.sh is not idempotent"
    exit 1
fi
if ! grep -q 'already current' /tmp/second.log; then
    echo "second run did not report composed files already current"
    cat /tmp/second.log
    exit 1
fi
if grep -E '^[[:space:]]*hooksPath' "$HOME/.gitconfig"; then
    echo "installed gitconfig still sets core.hooksPath"
    exit 1
fi
