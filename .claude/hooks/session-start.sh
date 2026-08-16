#!/usr/bin/env bash
# SessionStart: CLAUDE_SESSION_ID into CLAUDE_ENV_FILE for later Bash calls.
set -euo pipefail

# fail open without jq
if ! command -v jq &>/dev/null; then
    exit 0
fi

input="$(cat)"

session_id="$(echo "$input" | jq -r '.session_id // ""')"

if [[ -n $session_id ]] && [[ -n ${CLAUDE_ENV_FILE:-} ]]; then
    printf 'export CLAUDE_SESSION_ID=%s\n' "$(printf '%s' "$session_id" | jq -Rsr '@sh')" >>"$CLAUDE_ENV_FILE"
fi
