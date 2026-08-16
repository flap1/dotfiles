#!/bin/bash
#
# One entry point for a machine with nothing on it. Order matters: packages
# first because install.sh needs git, then mise for everything declared in
# .config/mise/config.toml, then the symlinks. install.sh puts mise shims on
# PATH so compose can find node; this process does not.
#
# Idempotent. Re-running after a pull is the supported way to apply changes.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
ARGS=()

usage() {
    cat <<'USAGE'
usage: bootstrap.sh [options]

  -y, --yes      answer yes throughout, for CI and for reinstalls
  -h, --help     this

Runs packages/system.sh, then mise install, then install.sh.
Already set up? ./install.sh alone is enough.
USAGE
}

while [ $# -gt 0 ]; do
    case $1 in
        -y | --yes) ARGS+=(--yes) ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            echo "unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

bash "$DOTFILES_DIR/packages/system.sh" "${ARGS[@]}"
bash "$DOTFILES_DIR/install.sh" "${ARGS[@]}"
