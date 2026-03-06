#!/usr/bin/env bash
# parse-tmux-keymaps.sh
# Outputs tmux keymaps as TSV: table\tprefix\tkey\tmods\tdesc\taction
# Usage: bash scripts/parse-tmux-keymaps.sh

set -euo pipefail

TMUX_CONF="${HOME}/.config/tmux/.tmux.conf"

# Check if tmux is running (list-keys requires a server)
if tmux info &>/dev/null 2>&1; then
  echo "--- Prefix keys (require Prefix before key) ---"
  echo "prefix_required	key	action"
  tmux list-keys -T prefix 2>/dev/null | while IFS= read -r line; do
    # format: bind-key -T prefix KEY ACTION
    key=$(echo "$line" | awk '{print $4}')
    action=$(echo "$line" | awk '{$1=$2=$3=$4=""; print $0}' | sed 's/^ *//')
    echo -e "yes\t${key}\t${action}"
  done

  echo ""
  echo "--- Root keys (no Prefix required) ---"
  echo "prefix_required	key	action"
  tmux list-keys -T root 2>/dev/null | while IFS= read -r line; do
    key=$(echo "$line" | awk '{print $4}')
    action=$(echo "$line" | awk '{$1=$2=$3=$4=""; print $0}' | sed 's/^ *//')
    echo -e "no\t${key}\t${action}"
  done
else
  echo "tmux server not running, parsing config file directly..."
  # Fallback: parse bind lines from config
  if [ -f "$TMUX_CONF" ]; then
    grep -E '^\s*(bind|bind-key)\s' "$TMUX_CONF" | while IFS= read -r line; do
      echo "$line"
    done
  fi
fi
