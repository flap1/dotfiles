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

mkdir -p "$HOME/dotfiles/.claude/skills/ci-probe"
printf '%s\n' '---' 'name: ci-probe' 'description: probe' '---' >"$HOME/dotfiles/.claude/skills/ci-probe/SKILL.md"
plugin=$HOME/.claude/plugins/cache/ci-plug/ci-plug/1.0.0/skills/natural-japanese
mkdir -p "$plugin"
printf '%s\n' '---' 'name: natural-japanese' 'description: probe plugin' '---' >"$plugin/SKILL.md"
mkdir -p "$HOME/.claude/plugins"
cat >"$HOME/.claude/plugins/installed_plugins.json" <<EOF
{"version":2,"plugins":{"ci-plug@ci":[{"installPath":"$HOME/.claude/plugins/cache/ci-plug/ci-plug/1.0.0"}]}}
EOF

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

# --yes on a machine that only took zsh must not grow nvim.
nvim=$HOME/.config/nvim
[ -L "$nvim" ]
unlink "$nvim"
manifest=$HOME/.local/state/dotfiles/manifest
grep -vxF "$nvim" "$manifest" >"$manifest.zsh"
mv "$manifest.zsh" "$manifest"
./install.sh --yes >/tmp/subset.log 2>&1 || {
    cat /tmp/subset.log
    exit 1
}
if [ -e "$nvim" ]; then
    echo "--yes recreated nvim after it was removed from the manifest"
    exit 1
fi
[ -L "$HOME/.config/zsh" ]
./install.sh --only nvim --yes >/tmp/add-nvim.log 2>&1 || {
    cat /tmp/add-nvim.log
    exit 1
}
[ -L "$nvim" ]

[ -L "$HOME/.cursor/skills/ci-probe" ]
[ -L "$HOME/.cursor/skills/natural-japanese" ]
[ -f "$HOME/.cursor/skills/memo-ja/SKILL.md" ]
[ -f "$HOME/.cursor/skills/humanize-ja/SKILL.md" ]
