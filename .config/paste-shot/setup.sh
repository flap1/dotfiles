#!/bin/bash
# Install the paste-shot receiver on this machine. Optional add-on, not
# part of install.sh.

set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
UNIT_SRC="$HERE/paste-shot.service"
UNIT_DST="$HOME/.config/systemd/user/paste-shot.service"
PORT=47291
SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/paste-shot.sock"

command -v python3 >/dev/null || {
    echo "python3 is required."
    exit 1
}
command -v systemctl >/dev/null || {
    echo "systemd is required (this is a user service)."
    exit 1
}
[ -f "$UNIT_SRC" ] || {
    echo "not found: $UNIT_SRC"
    exit 1
}

mkdir -p "$(dirname "$UNIT_DST")"
ln -sfn "$UNIT_SRC" "$UNIT_DST"
echo "unit    -> $UNIT_DST"

systemctl --user daemon-reload
systemctl --user enable --now paste-shot.service
systemctl --user restart paste-shot.service

if systemctl --user is-active --quiet paste-shot.service; then
    echo "service -> active on $SOCKET"
else
    echo "service -> FAILED. journalctl --user -u paste-shot.service"
    exit 1
fi

if [ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null)" != "yes" ]; then
    echo
    echo "WARNING: lingering is off, so this stops when you log out. Fix with:"
    echo
    echo "    loginctl enable-linger $USER"
fi

cat <<EOF

Add this to ~/.ssh/config on the Windows side, under the Host you already use
for this machine:

    LocalForward 127.0.0.1:$PORT $SOCKET

Then reconnect. An ssh session opened before that line existed does not carry
the forward.
EOF
