#!/bin/bash
# Compose CLI config that must not be a symlink. Sourced from install.sh.
# Relies on: DOTFILES_DIR, ask (same shell).

compose_claude_settings() {
    local shared="$DOTFILES_DIR/.claude/settings.json"
    local target="$HOME/.claude/settings.json"

    [ -f "$shared" ] || {
        echo "Skipped [AI: Claude Code settings]: $shared missing."
        return
    }
    command -v node >/dev/null || {
        echo "Skipped [AI: Claude Code settings]: no node."
        return
    }

    ask claude-settings || return 0

    SHARED="$shared" \
        LINUX="$DOTFILES_DIR/.claude/settings.linux.json" \
        LOCAL="$DOTFILES_DIR/.claude/settings.local.json" \
        TARGET="$target" \
        node "$DOTFILES_DIR/lib/compose-claude.js"
}

compose_cursor_settings() {
    local shared="$DOTFILES_DIR/.cursor/cli-config.json"
    local dir
    local -a targets

    [ -f "$shared" ] || {
        echo "Skipped [AI: Cursor settings]: $shared missing."
        return
    }
    command -v node >/dev/null || {
        echo "Skipped [AI: Cursor settings]: no node."
        return
    }

    if [ -n "${CURSOR_CONFIG_DIR:-}" ]; then
        dir="$CURSOR_CONFIG_DIR"
    elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
        dir="$XDG_CONFIG_HOME/cursor"
    else
        dir="$HOME/.cursor"
    fi

    targets=("$dir/cli-config.json")
    if [ "$dir" != "$HOME/.cursor" ]; then
        targets+=("$HOME/.cursor/cli-config.json")
    fi

    ask cursor-settings || return 0

    local target
    for target in "${targets[@]}"; do
        echo "  $target"
        SHARED="$shared" \
            LOCAL="$DOTFILES_DIR/.cursor/cli-config.local.json" \
            TARGET="$target" \
            node "$DOTFILES_DIR/lib/compose-cursor.js"
    done
}

compose_codex_settings() {
    local shared="$DOTFILES_DIR/.codex/config.toml"
    local target="${CODEX_HOME:-$HOME/.codex}/config.toml"

    [ -f "$shared" ] || {
        echo "Skipped [AI: Codex settings]: $shared missing."
        return
    }
    command -v node >/dev/null || {
        echo "Skipped [AI: Codex settings]: no node."
        return
    }

    ask codex-settings || return 0

    SHARED="$shared" TARGET="$target" node "$DOTFILES_DIR/lib/compose-codex.js"
}
