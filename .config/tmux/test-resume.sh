#!/bin/sh
# Regression check for session persistence. On a throwaway socket it recreates
# the boot conditions systemd gives (absolute tmux, sanitised PATH), runs
# save -> kill -> start -> restore, and checks what came back. The real server
# is never touched.
#
# It guards the two things the resurrect fork adds (the foreground_pgroup
# strategy, and an empty pane_title not collapsing the fields) plus the plugins
# loading under boot conditions. Everything that has broken before broke here:
# a wrong tmux format, basename taking "-zsh" for an option, panes whose
# pane_pid is the program itself being missed, and an empty title shifting
# dir.
#
# claude / agent / codex panes are not started as the real CLIs: that would
# create conversations. The hook is given stubs and processes that hold the
# same identity files the real CLIs hold open.
set -eu

sock=resume-test
tmux=$HOME/.local/bin/tmux
dir=$(mktemp -d)
conf=$dir/tmux.conf
path=$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
here=$(cd -- "$(dirname "$0")" && pwd)
hook=$here/../../bin/tmux-session-resume
fail=0

trap '"$tmux" -L "$sock" kill-server 2>/dev/null || true; rm -rf "$dir"' EXIT

cat >"$conf" <<EOF
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'flap1/tmux-resurrect'
set -g @resurrect-dir '$dir/state'
set -g @resurrect-processes '"~btop" "~tail"'
set -g @resurrect-save-command-strategy 'foreground_pgroup'
set -g @resurrect-hook-post-save-layout '$hook'
run '~/.tmux/plugins/tpm/tpm'
EOF

# claude itself is not started. The hook only reads `claude agents --json`, so
# that is stubbed and made to claim a real pid. What the hook inspects is that
# pid's process group, so a sleep exercises the same path.
stub=$dir/stub
mkdir -p "$stub"
cat >"$stub/claude" <<'EOF'
#!/bin/sh
[ "$1" = agents ] || exit 1
pid=$(cat "$(dirname "$0")/pid")
sid=$(cat "$(dirname "$0")/sid")
# The first row is the real one. The second is a claude outside any tmux pane
# and must match none. The third is a background agent, which shares its
# parent's pgid and would take the first row's pane unless filtered by kind,
# because it loads later and wins.
printf '[{"pid":%s,"kind":"interactive","sessionId":"%s"},\n' "$pid" "$sid"
printf ' {"pid":1,"kind":"interactive","sessionId":"11111111-1111-1111-1111-111111111111"},\n'
printf ' {"pid":%s,"kind":"background","sessionId":"22222222-2222-2222-2222-222222222222"}]\n' "$pid"
EOF
chmod +x "$stub/claude"
sid=33333333-3333-3333-3333-333333333333
printf '%s' "$sid" >"$stub/sid"
printf '%s' 1 >"$stub/pid" # the real pid is written once the pane exists

boot() {
    env -i HOME="$HOME" SHELL="${SHELL:-/usr/bin/zsh}" PATH="$stub:$path" TERM=xterm-256color \
        "$tmux" -L "$sock" -f "$conf" new-session -d -x 200 -y 80
    sleep 2
}

check() {
    if [ "$2" = "$3" ]; then
        echo "  ok   $1"
    else
        echo "  FAIL $1: expected [$3], got [$2]"
        fail=1
    fi
}

boot
# did the plugins load as children of the server? nothing below means anything otherwise
check "tpm loads under the boot environment" \
    "$("$tmux" -L "$sock" list-keys | grep -c resurrect)" "2"

spaced="$dir/sp dir/a b.txt"
mkdir -p "$dir/sp dir"
: >"$spaced"

"$tmux" -L "$sock" split-window -h -c /tmp             # a shell and nothing else
"$tmux" -L "$sock" split-window -v -c /var/log 'btop'  # a program started without a shell
"$tmux" -L "$sock" split-window -v "tail -f '$spaced'" # an argument containing a space
# Stands in for claude. Carries a path with a space and a flag that must be
# dropped, so one pane shows all three at once: arguments survive, spaces stay
# quoted, and anything conflicting with --resume is removed.
loop="$dir/sp dir/loop.py"
printf 'import time\ntime.sleep(99999)\n' >"$loop"
"$tmux" -L "$sock" split-window -v "python3 '$loop' --session-id zzz --continue"
# A pipeline. Saving only its head restores something that runs but is not this.
"$tmux" -L "$sock" split-window -v 'tail -f /dev/null | grep --line-buffered x'

# argv0 is the basename the hook classifies on. A shebang script's argv0 is
# python3, which classifies as other and leaves the launcher in the save.
# A copy of python3 named agent/codex, with no extra argv, matches the real
# CLIs. PYTHONSTARTUP opens the identity file so the path is not an argument.
# Window 1 is split vertically: window 0 has no height left. `-t 1` would
# be pane 1 of window 0; the window is `:1`.
startup=$dir/startup.py
cat >"$startup" <<'EOF'
import os, time
os.open(os.environ["HOLD_PATH"], os.O_RDWR | os.O_CREAT)
time.sleep(99999)
EOF
bin=$dir/bin
mkdir -p "$bin/chat" "$bin/blank" "$bin/worker" "$bin/tui" "$bin/sub"
# Follow the python3 symlink; a relative copy is not executable from here.
/bin/cp -L /usr/bin/python3 "$bin/chat/agent"
/bin/cp -L /usr/bin/python3 "$bin/blank/agent"
/bin/cp -L /usr/bin/python3 "$bin/worker/agent"
/bin/cp -L /usr/bin/python3 "$bin/tui/codex"
/bin/cp -L /usr/bin/python3 "$bin/sub/codex"
agent_sid=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
agent_store=$dir/chats/0123456789abcdef0123456789abcdef/$agent_sid/store.db
mkdir -p "$(dirname "$agent_store")"
: >"$agent_store"
decoy_sid=bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
decoy_store=$dir/chats/0123456789abcdef0123456789abcdef/$decoy_sid/store.db
mkdir -p "$(dirname "$decoy_store")"
: >"$decoy_store"
codex_sid=cccccccc-cccc-cccc-cccc-cccccccccccc
codex_roll=$dir/sessions/2026/08/15/rollout-2026-08-15T00-00-00-$codex_sid.jsonl
mkdir -p "$(dirname "$codex_roll")"
printf '%s\n' "{\"type\":\"session_meta\",\"payload\":{\"originator\":\"codex-tui\",\"thread_source\":\"user\",\"session_id\":\"$codex_sid\"}}" >"$codex_roll"
sub_sid=dddddddd-dddd-dddd-dddd-dddddddddddd
sub_roll=$dir/sessions/2026/08/15/rollout-2026-08-15T00-00-01-$sub_sid.jsonl
printf '%s\n' "{\"type\":\"session_meta\",\"payload\":{\"originator\":\"codex-tui\",\"thread_source\":\"subagent\",\"session_id\":\"$sub_sid\"}}" >"$sub_roll"

run_hold() {
    extra=${3-}
    "$tmux" -L "$sock" split-window -t :1 -v \
        "env HOLD_PATH=$1 PYTHONSTARTUP=$startup $2 $extra"
}

"$tmux" -L "$sock" new-window -d
run_hold "$agent_store" "$bin/chat/agent"
run_hold /dev/null "$bin/blank/agent"
# worker-server must stay in argv so classify_argv vetoes it, but it must not
# be python's script name or the pane exits and later splits shift index.
"$tmux" -L "$sock" split-window -t :1 -v \
    "env HOLD_PATH=$decoy_store PYTHONSTARTUP=$startup $bin/worker/agent -c 'import time; time.sleep(99999)' worker-server"
run_hold "$codex_roll" "$bin/tui/codex"
run_hold "$sub_roll" "$bin/sub/codex"

sleep 4
# An empty pane_title makes save.sh's `IFS=$'\t' read` collapse the run of
# tabs and shift every later field one to the left. restore.sh reads the same
# way, so dir comes back wrong.
"$tmux" -L "$sock" select-pane -t 2 -T ''
# make the stub claim the foreground process group of the claude pane
"$tmux" -L "$sock" display-message -p -t 4 '#{pane_pid}' >"$stub/pid"
"$tmux" -L "$sock" run-shell "$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh quiet"
sleep 3

cmd_of() { awk -F'\t' -v w="$1" -v i="$2" '$1 == "pane" && $3 == w && $6 == i { print substr($11, 2) }' "$dir/state/last"; }

check "idle shell saves nothing" "$(cmd_of 0 0)" ""
check "second idle shell saves nothing" "$(cmd_of 0 1)" ""
check "program as the pane itself" "$(cmd_of 0 2)" "btop"
# f8 is ":<dir>"; if the fields collapse, pane_active (0/1) lands here instead
check "empty title does not shift dir" \
    "$(awk -F'\t' '$1 == "pane" && $3 == 0 && $6 == 2 { print $8 }' "$dir/state/last")" ":/var/log"
# An argument with a space. Joined on whitespace it restores as two arguments, and sh has no printf %q.
esc=$(printf '%s' "$spaced" | sed 's/ /\\ /g')
check "argument containing a space stays one" \
    "$(cmd_of 0 3)" "tail -f $esc"
# Does the hook swap the claude pane for its sessionId, keep the other
# arguments quoted, and drop --session-id with its value and --continue?
check "claude pane resumes its own session" \
    "$(cmd_of 0 4)" "claude --resume $sid $(printf '%s' "$loop" | sed 's/ /\\ /g')"
# rows one and three share a pgid; without filtering by kind the background sessionId wins
check "background agent does not claim the pane" \
    "$(cmd_of 0 4 | grep -c 22222222)" "0"
check "cursor pane resumes its own chat" "$(cmd_of 1 1)" "agent --resume $agent_sid"
check "cursor pane without a chat is blanked" "$(cmd_of 1 2)" ""
check "cursor worker-server does not resume" \
    "$(cmd_of 1 3 | grep -c 'agent --resume')" "0"
check "codex pane resumes its own session" "$(cmd_of 1 4)" "codex resume $codex_sid"
check "codex subagent pane is blanked" "$(cmd_of 1 5)" ""
# a pipeline saves nothing rather than half of itself
check "pipeline saves nothing rather than half" "$(cmd_of 0 5)" ""
# the upstream strategy emits a line per unrelated descendant; this holds one record to one line
check "one record per line" \
    "$(awk -F'\t' '$1 != "pane" && $1 != "window" && $1 != "state" && $1 != "grouped_session"' "$dir/state/last" | wc -l)" "0"

"$tmux" -L "$sock" kill-server
sleep 1
boot
"$tmux" -L "$sock" run-shell "$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh"
sleep 6
check "restored program and its directory" \
    "$("$tmux" -L "$sock" list-panes -a -F '#{pane_current_command} #{pane_current_path}' | grep btop)" \
    "btop /var/log"

[ "$fail" -eq 0 ] && echo "all ok" || echo "FAILED"
exit "$fail"
