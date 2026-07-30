#!/usr/bin/env python3
"""Receive a screenshot from the Windows side and drop it where Claude Code can read it.

Why this exists at all: Claude Code reads the OS clipboard of the machine it
runs on, so a session over ssh cannot see the Windows clipboard. The terminal
protocol that would fix that properly -- OSC 5522, the kitty image clipboard --
is unimplemented in Claude Code (anthropics/claude-code#42712, closed as not
planned) and in Windows Terminal, which answers OSC 52 reads with silence. So
the picture has to travel out of band and be handed over as a path. This is a
workaround by necessity; what follows is the part that does not have to be bad.

Why a socket instead of scp: every scp is a fresh ssh handshake, and through
the cloudflared ProxyJump that is 1.2-2.5s measured. The usual fix, connection
multiplexing, does not exist on Windows -- Win32-OpenSSH ignores ControlMaster
and the MSYS build fails to create the socket. So instead of opening a
connection per paste, this listens on the connection that is already open: the
`ssh syntopic` session forwards a local port to this socket, and an upload
costs one round trip.

Why a unix socket and not 127.0.0.1: this is a shared machine, and loopback is
shared too -- any local account could POST to a TCP port here. The socket sits
in $XDG_RUNTIME_DIR, which is 0700, so it is reachable by this user only.
ssh -L supports a remote unix socket as the forward target, so the Windows side
still talks to a plain TCP port and neither end has to care.
"""

from __future__ import annotations

import http.server
import os
import re
import socket
import socketserver
import sys
import time
from pathlib import Path

SOCKET_PATH = Path(
    os.environ.get("PASTE_SHOT_SOCKET")
    or Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")) / "paste-shot.sock"
)
SHOT_DIR = Path(os.environ.get("PASTE_SHOT_DIR") or Path.home() / ".cache" / "claude-shots")

# The sender builds this name from its own clock and types the matching path
# before the upload finishes, so the two have to agree exactly. Anchored, and
# no separators, so a name can never escape SHOT_DIR.
NAME_RE = re.compile(r"^[0-9]{8}-[0-9]{6}-[0-9]{3}\.png$")

MAX_BYTES = 64 * 1024 * 1024
KEEP_SECONDS = 7 * 24 * 60 * 60


def prune() -> None:
    """Drop shots older than a week.

    Done here, on write, rather than in a timer: a timer is one more unit to
    install and to notice has stopped, and this costs a directory listing at
    exactly the moment the directory is known to be growing.
    """
    cutoff = time.time() - KEEP_SECONDS
    for old in SHOT_DIR.glob("*.png"):
        try:
            if old.stat().st_mtime < cutoff:
                old.unlink()
        except OSError:
            pass


class Handler(http.server.BaseHTTPRequestHandler):
    server_version = "paste-shot/1"
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt: str, *args) -> None:
        # journald already stamps the time and the unit.
        sys.stderr.write((fmt % args) + "\n")

    def _fail(self, code: int, why: str) -> None:
        body = (why + "\n").encode()
        self.send_response(code)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 - name fixed by BaseHTTPRequestHandler
        """Tell the sender where shots land, so it never has to be told.

        The sender has to type the remote path into the prompt before the upload
        finishes, which means it needs to know the remote home directory. Asking
        for it here keeps that out of the Windows-side config: nothing to edit
        per person, and it follows the remote account rather than a copy of it
        that silently goes stale.
        """
        body = (str(SHOT_DIR) + "\n").encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self) -> None:  # noqa: N802 - name fixed by BaseHTTPRequestHandler
        name = self.path.lstrip("/")
        if not NAME_RE.match(name):
            self._fail(400, f"bad name: {name!r}")
            return

        try:
            length = int(self.headers.get("Content-Length", ""))
        except ValueError:
            self._fail(411, "Content-Length required")
            return
        if not 0 < length <= MAX_BYTES:
            self._fail(413, f"length {length} out of range")
            return

        data = self.rfile.read(length)
        if len(data) != length:
            self._fail(400, "short read")
            return
        # Cheap sanity check. A truncated or non-PNG upload is worth rejecting
        # here, because the path was already typed into the prompt and Claude
        # will try to read it.
        if not data.startswith(b"\x89PNG\r\n\x1a\n"):
            self._fail(415, "not a PNG")
            return

        SHOT_DIR.mkdir(parents=True, exist_ok=True, mode=0o700)
        final = SHOT_DIR / name
        # Written under a temporary name and renamed, because the sender types
        # the path before the bytes arrive: without this, Claude can open the
        # file mid-upload and see half an image. rename is atomic within a
        # filesystem, so the path either does not exist or is complete.
        tmp = SHOT_DIR / (name + ".part")
        with open(tmp, "wb") as fh:
            fh.write(data)
            fh.flush()
            os.fsync(fh.fileno())
        os.chmod(tmp, 0o600)
        os.replace(tmp, final)

        prune()

        body = (str(final) + "\n").encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
        self.log_message("%s (%d bytes)", final, length)


class UnixHTTPServer(socketserver.ThreadingUnixStreamServer):
    # BaseHTTPRequestHandler reaches for these; UnixStreamServer has neither.
    server_name = "paste-shot"
    server_port = 0
    daemon_threads = True
    allow_reuse_address = False

    def get_request(self):
        conn, _ = super().get_request()
        # BaseHTTPRequestHandler formats client_address into log lines and
        # expects something indexable. AF_UNIX hands back an empty string.
        return conn, ("local", 0)


def main() -> int:
    SHOT_DIR.mkdir(parents=True, exist_ok=True, mode=0o700)
    SOCKET_PATH.parent.mkdir(parents=True, exist_ok=True)

    # A socket file left behind by a killed process makes bind fail with
    # EADDRINUSE, which reads like "another copy is running" and is not.
    # Connecting to it is the only way to tell the two apart.
    if SOCKET_PATH.exists():
        probe = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        try:
            probe.connect(str(SOCKET_PATH))
        except OSError:
            SOCKET_PATH.unlink()
        else:
            probe.close()
            print(f"already serving on {SOCKET_PATH}", file=sys.stderr)
            return 1
        finally:
            probe.close()

    server = UnixHTTPServer(str(SOCKET_PATH), Handler)
    # $XDG_RUNTIME_DIR is already 0700, so this is belt and braces -- but the
    # socket may be relocated with PASTE_SHOT_SOCKET, and the default umask
    # would otherwise leave it group- and world-readable there.
    os.chmod(SOCKET_PATH, 0o600)
    print(f"listening on {SOCKET_PATH}, writing to {SHOT_DIR}", file=sys.stderr)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
        SOCKET_PATH.unlink(missing_ok=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
