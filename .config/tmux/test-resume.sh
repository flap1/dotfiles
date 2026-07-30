#!/bin/sh
# bin/tmux-claude-resume の回帰チェック。使い捨てのソケットで systemd の boot 条件
# (絶対パスの tmux + サニタイズ PATH) を再現し、save -> kill -> 起動 -> restore を
# 一周させて中身を検算する。実サーバには触らない。
#
# claude のペインは検査しない。sessionId を持つ本物の claude を起こす必要があり、
# 会話を 1 つ作ってしまうため。ここが守るのは「どのプロセスがそのペインのものか」の
# 判定で、過去に壊れたのは全部そこ（tmux の format 誤り、basename が "-zsh" を
# オプション扱い、pane_pid 自身がプログラムのペインの取りこぼし）。
set -eu

sock=resume-test
tmux=$HOME/.local/bin/tmux
dir=$(mktemp -d)
conf=$dir/tmux.conf
path=$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
fail=0

trap '"$tmux" -L "$sock" kill-server 2>/dev/null || true; rm -rf "$dir"' EXIT

cat > "$conf" <<EOF
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @resurrect-dir '$dir/state'
set -g @resurrect-processes '"~btop"'
set -g @resurrect-hook-post-save-layout '$HOME/bin/tmux-claude-resume'
run '~/.tmux/plugins/tpm/tpm'
EOF

boot() {
	env -i HOME="$HOME" SHELL="${SHELL:-/usr/bin/zsh}" PATH="$path" TERM=xterm-256color \
		"$tmux" -L "$sock" -f "$conf" new-session -d
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
# プラグインがサーバの子として読めているか。ここが死ぬと以下は全部無意味になる
check "tpm loads under the boot environment" \
	"$("$tmux" -L "$sock" list-keys | grep -c resurrect)" "2"

"$tmux" -L "$sock" split-window -h -c /tmp            # シェルだけのペイン
"$tmux" -L "$sock" split-window -v -c /var/log 'btop' # シェルを介さないプログラム
sleep 4
"$tmux" -L "$sock" run-shell "$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh quiet"
sleep 3

cmd_of() { awk -F'\t' -v i="$1" '$1 == "pane" && $6 == i { print substr($11, 2) }' "$dir/state/last"; }

check "idle shell saves nothing"          "$(cmd_of 0)" ""
check "second idle shell saves nothing"   "$(cmd_of 1)" ""
check "program as the pane itself"        "$(cmd_of 2)" "btop"
# 上流のストラテジは無関係な子孫の cmdline を複数行吐く。1 レコード 1 行を守れているか
check "one record per line" \
	"$(awk -F'\t' '$1 != "pane" && $1 != "window" && $1 != "state" && $1 != "grouped_session"' "$dir/state/last" | wc -l)" "0"

"$tmux" -L "$sock" kill-server; sleep 1
boot
"$tmux" -L "$sock" run-shell "$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh"
sleep 6
check "restored program and its directory" \
	"$("$tmux" -L "$sock" list-panes -a -F '#{pane_current_command} #{pane_current_path}' | grep btop)" \
	"btop /var/log"

[ "$fail" -eq 0 ] && echo "all ok" || echo "FAILED"
exit "$fail"
