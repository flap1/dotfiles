#!/bin/sh
# bind-localhost.so の回帰チェック。見るのは表示上の待受アドレスではなく到達性で、
# 「loopback からは繋がり、LAN からは繋がらない」がこの .so の目的そのもの。
# v6 の dual-stack を ::1 に寄せてしまうと 127.0.0.1 が死ぬ（= ssh の転送先が死ぬ）ので、
# そこが壊れたら v4 loopback の接続が落ちて分かる。
set -eu

so=${1:-$HOME/.local/lib/bind-localhost.so}
[ -f "$so" ] || { echo "not built: $so"; exit 1; }
lan=$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1)
fail=0

check() {
	if [ "$2" = "$3" ]; then
		echo "  ok   $1"
	else
		echo "  FAIL $1: expected [$3], got [$2]"
		fail=1
	fi
}

# $1=python の family (v4|v6), $2=bind するアドレス。listen したまま pid を返す
start_listener() {
	port=$1 family=$2 addr=$3
	LD_PRELOAD="$so" python3 -c "
import socket, time
f = socket.AF_INET6 if '$family' == 'v6' else socket.AF_INET
s = socket.socket(f, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('$addr', $port))
s.listen(8)
time.sleep(6)
" &
	sleep 1
}

# 繋がれば ok、繋がらなければ refused
probe() {
	python3 -c "
import socket, sys
try:
    socket.create_connection(('$1', $2), timeout=2).close()
    print('ok')
except Exception:
    print('refused')
"
}

port=$((20000 + $$ % 10000))
start_listener "$port" v6 '::'
check "v6 wildcard: loopback reachable" "$(probe 127.0.0.1 "$port")" "ok"
if [ -n "$lan" ]; then
	check "v6 wildcard: LAN ($lan) refused" "$(probe "$lan" "$port")" "refused"
else
	echo "  skip LAN check: グローバルスコープのアドレスが無い"
fi
wait 2>/dev/null || true

port=$((port + 1))
start_listener "$port" v4 '0.0.0.0'
check "v4 wildcard: loopback reachable" "$(probe 127.0.0.1 "$port")" "ok"
[ -n "$lan" ] && check "v4 wildcard: LAN refused" "$(probe "$lan" "$port")" "refused"
wait 2>/dev/null || true

# 明示されたアドレスは触らない
port=$((port + 1))
start_listener "$port" v4 '127.0.0.2'
check "explicit address untouched" \
	"$(ss -ltnH "sport = :$port" 2>/dev/null | awk '{print $4; exit}')" "127.0.0.2:$port"
wait 2>/dev/null || true

[ "$fail" -eq 0 ] && echo "all ok" || echo "FAILED"
exit "$fail"
