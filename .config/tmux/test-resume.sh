#!/bin/sh
# セッション永続化の回帰チェック。使い捨てのソケットで systemd の boot 条件
# (絶対パスの tmux + サニタイズ PATH) を再現し、save -> kill -> 起動 -> restore を
# 一周させて中身を検算する。実サーバには触らない。
#
# 守っているのは fork した resurrect 側の 2 つ（foreground_pgroup ストラテジと、空の
# pane_title でフィールドが畳まれないこと）と、boot 環境でプラグインが読めること。
# 過去に壊れたのは全部ここ: tmux の format 誤り、basename が "-zsh" をオプション
# 扱い、pane_pid 自身がプログラムのペインの取りこぼし、空タイトルによる dir のずれ。
#
# claude のペインは検査しない。sessionId を持つ本物の claude を起こす必要があり、
# 会話を 1 つ作ってしまうため。
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
set -g @plugin 'flap1/tmux-resurrect'
set -g @resurrect-dir '$dir/state'
set -g @resurrect-processes '"~btop" "~tail"'
set -g @resurrect-save-command-strategy 'foreground_pgroup'
set -g @resurrect-hook-post-save-layout '$HOME/bin/tmux-claude-resume'
run '~/.tmux/plugins/tpm/tpm'
EOF

# claude 本体は起こさない（会話が 1 つ増える）。フックが読むのは `claude agents --json`
# だけなので、それをスタブに差し替えて本物の pid を名乗らせる。フックが検査するのは
# その pid のプロセスグループなので、中身が sleep でも経路は本番と同じ
stub=$dir/stub
mkdir -p "$stub"
cat > "$stub/claude" <<'EOF'
#!/bin/sh
[ "$1" = agents ] || exit 1
pid=$(cat "$(dirname "$0")/pid")
sid=$(cat "$(dirname "$0")/sid")
# 1 行目が本命。2 行目は tmux のペインに居ない claude で、どのペインにも一致して
# はいけない。3 行目は background agent で、親と pgid を共有するため kind で
# 除かないと 1 行目のペインを奪う（後から load されるので勝ってしまう）
printf '[{"pid":%s,"kind":"interactive","sessionId":"%s"},\n' "$pid" "$sid"
printf ' {"pid":1,"kind":"interactive","sessionId":"11111111-1111-1111-1111-111111111111"},\n'
printf ' {"pid":%s,"kind":"background","sessionId":"22222222-2222-2222-2222-222222222222"}]\n' "$pid"
EOF
chmod +x "$stub/claude"
sid=33333333-3333-3333-3333-333333333333
printf '%s' "$sid" > "$stub/sid"
printf '%s' 1 > "$stub/pid"   # 実 pid は pane を作ってから書き込む

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
# プラグインがサーバの子として読めているか。ここが死ぬと以下は全部無意味になる
check "tpm loads under the boot environment" \
	"$("$tmux" -L "$sock" list-keys | grep -c resurrect)" "2"

spaced="$dir/sp dir/a b.txt"
mkdir -p "$dir/sp dir"; : > "$spaced"

"$tmux" -L "$sock" split-window -h -c /tmp            # シェルだけのペイン
"$tmux" -L "$sock" split-window -v -c /var/log 'btop' # シェルを介さないプログラム
"$tmux" -L "$sock" split-window -v "tail -f '$spaced'" # 空白入りの引数
# claude 役。引数が (1) 残る (2) 空白ごとクォートされる (3) --resume と競合するものは
# 落ちる、を一度に見るため、空白入りのパスと落とすべきフラグを持たせる
loop="$dir/sp dir/loop.py"
printf 'import time\ntime.sleep(99999)\n' > "$loop"
"$tmux" -L "$sock" split-window -v "python3 '$loop' --session-id zzz --continue"
# パイプライン。先頭だけ保存すると「動くが別物」のコマンドが復元される
"$tmux" -L "$sock" split-window -v 'tail -f /dev/null | grep --line-buffered x'
sleep 4
# 空の pane_title は save.sh の `IFS=$'\t' read` に連続タブを畳ませ、以降のフィールドを
# 1 つ左に寄せる。restore.sh も同じ read を通るので dir が壊れる
"$tmux" -L "$sock" select-pane -t 2 -T ''
# スタブに、claude 役のペインの前面プロセスグループを名乗らせる
"$tmux" -L "$sock" display-message -p -t 4 '#{pane_pid}' > "$stub/pid"
"$tmux" -L "$sock" run-shell "$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh quiet"
sleep 3

cmd_of() { awk -F'\t' -v i="$1" '$1 == "pane" && $6 == i { print substr($11, 2) }' "$dir/state/last"; }

check "idle shell saves nothing"          "$(cmd_of 0)" ""
check "second idle shell saves nothing"   "$(cmd_of 1)" ""
check "program as the pane itself"        "$(cmd_of 2)" "btop"
# f8 は ":<dir>"。畳みが起きるとここに pane_active (0/1) が入る
check "empty title does not shift dir" \
	"$(awk -F'\t' '$1 == "pane" && $6 == 2 { print $8 }' "$dir/state/last")" ":/var/log"
# 空白を含む引数。空白で連結すると復元時に 2 引数に割れる。sh に printf %q は無い
esc=$(printf '%s' "$spaced" | sed 's/ /\\ /g')
check "argument containing a space stays one" \
	"$(cmd_of 3)" "tail -f $esc"
# フックが claude のペインを sessionId に差し替え、他の引数はクォートして残し、
# --session-id とその値・--continue は落とすか
check "claude pane resumes its own session" \
	"$(cmd_of 4)" "claude --resume $sid $(printf '%s' "$loop" | sed 's/ /\\ /g')"
# 1 行目と 3 行目は同じ pgid。kind で除かないと background の sessionId が勝つ
check "background agent does not claim the pane" \
	"$(cmd_of 4 | grep -c 22222222)" "0"
# パイプラインは半分だけ保存するより何も保存しない
check "pipeline saves nothing rather than half" "$(cmd_of 5)" ""
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
