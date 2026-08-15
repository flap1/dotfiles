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
# claude panes are not checked: that would need a real claude with a sessionId,
# which creates a conversation.
set -eu

sock=resume-test
tmux=$HOME/.local/bin/tmux
dir=$(mktemp -d)
conf=$dir/tmux.conf
path=$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
fail=0

trap '"$tmux" -L "$sock" kill-server 2>/dev/null || true; rm -rf "$dir"' EXIT

cat >"$conf" <<EOF
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'flap1/tmux-resurrect'
set -g @resurrect-dir '$dir/state'
set -g @resurrect-processes '"~btop" "~tail"'
set -g @resurrect-save-command-strategy 'foreground_pgroup'
set -g @resurrect-hook-post-save-layout '$HOME/bin/tmux-claude-resume'
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
sleep 4
# An empty pane_title makes save.sh's `IFS=$'\t' read` collapse the run of
# tabs and shift every later field one to the left. restore.sh reads the same
# way, so dir comes back wrong.
"$tmux" -L "$sock" select-pane -t 2 -T ''
# make the stub claim the foreground process group of the claude pane
"$tmux" -L "$sock" display-message -p -t 4 '#{pane_pid}' >"$stub/pid"
"$tmux" -L "$sock" run-shell "$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh quiet"
sleep 3

cmd_of() { awk -F'\t' -v i="$1" '$1 == "pane" && $6 == i { print substr($11, 2) }' "$dir/state/last"; }

check "idle shell saves nothing" "$(cmd_of 0)" ""
check "second idle shell saves nothing" "$(cmd_of 1)" ""
check "program as the pane itself" "$(cmd_of 2)" "btop"
# f8 is ":<dir>"; if the fields collapse, pane_active (0/1) lands here instead
check "empty title does not shift dir" \
    "$(awk -F'\t' '$1 == "pane" && $6 == 2 { print $8 }' "$dir/state/last")" ":/var/log"
# An argument with a space. Joined on whitespace it restores as two arguments, and sh has no printf %q.
esc=$(printf '%s' "$spaced" | sed 's/ /\\ /g')
check "argument containing a space stays one" \
    "$(cmd_of 3)" "tail -f $esc"
# Does the hook swap the claude pane for its sessionId, keep the other
# arguments quoted, and drop --session-id with its value and --continue?
check "claude pane resumes its own session" \
    "$(cmd_of 4)" "claude --resume $sid $(printf '%s' "$loop" | sed 's/ /\\ /g')"
# rows one and three share a pgid; without filtering by kind the background sessionId wins
check "background agent does not claim the pane" \
    "$(cmd_of 4 | grep -c 22222222)" "0"
# a pipeline saves nothing rather than half of itself
check "pipeline saves nothing rather than half" "$(cmd_of 5)" ""
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
