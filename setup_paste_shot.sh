#!/bin/bash
#
# Install the paste-shot receiver on this machine.
#
# Split out of setup.sh on purpose. This is an optional add-on for one specific
# problem -- handing a Windows screenshot to a Claude Code session running here
# over ssh -- not part of wiring up a shell. Someone setting up a new box should
# not have to answer a question about it, and someone who only wants this should
# not have to run everything else and say no fourteen times.
#
# Idempotent. Rerunning it re-links the unit, restarts the service, and prints
# the ssh config line again.
#
# See .config/paste-shot/README.md for why any of this is needed.

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
UNIT_SRC="$DOTFILES_DIR/.config/paste-shot/paste-shot.service"
UNIT_DST="$HOME/.config/systemd/user/paste-shot.service"
PORT=47291
SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/paste-shot.sock"

command -v python3 >/dev/null || { echo "python3 is required."; exit 1; }
command -v systemctl >/dev/null || { echo "systemd is required (this is a user service)."; exit 1; }
[ -f "$UNIT_SRC" ] || { echo "not found: $UNIT_SRC"; exit 1; }

mkdir -p "$(dirname "$UNIT_DST")"
# Symlinked rather than copied: a `git pull` that changes the unit should only
# need a daemon-reload, not a rerun of this script.
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

# The receiver dies with the last login session unless lingering is on, and it
# dies quietly: the socket is simply not there next time, which reads as "the
# forward is broken" rather than "the service is not running".
if [ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null)" != "yes" ]; then
    echo
    echo "WARNING: lingering is off, so this stops when you log out. Fix with:"
    echo
    echo "    loginctl enable-linger $USER"
fi

# Printed rather than left to be worked out. sshd resolves neither ~ nor a
# relative path for a forwarded socket -- direct-streamlocal takes an absolute
# path only, verified -- so this line has to name the uid, and nobody should
# have to go looking for it.
cat <<EOF

Add this to ~/.ssh/config on the Windows side, under the Host you already use
for this machine:

    LocalForward 127.0.0.1:$PORT $SOCKET

Then reconnect. An ssh session opened before that line existed does not carry
the forward.
EOF
