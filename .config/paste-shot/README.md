# paste-shot

`Ctrl+V` in Windows Terminal hands a screenshot to a Claude Code session running
on the Linux box over ssh. Text pastes are untouched.

## Why this exists

Claude Code reads the OS clipboard of the machine it runs on. Over ssh that
machine cannot see the Windows clipboard, and tmux has nothing to do with it.

The clean fix would be the terminal carrying the image itself: OSC 52 for text,
OSC 5522 (the kitty clipboard protocol) for pictures. Both ends are shut.
Claude Code closed that request as not planned
([anthropics/claude-code#42712](https://github.com/anthropics/claude-code/issues/42712)),
and Windows Terminal implements only the write half of OSC 52 -- it never
answers a read, which is the same fault that made nvim hang on `p` until
`e531ae5`. No terminal that runs on Windows implements OSC 5522 today.

The fixes that do work move the interface to where the clipboard is: the Claude
Desktop app's ssh sessions, or Remote Control from a browser. Both were ruled
out here -- the terminal is the workspace and neither an extra app nor a browser
is wanted in the loop.

So this is a workaround, and it is one on purpose: the picture travels out of
band and is handed over as a path, because there is no supported way to paste it.
What follows is the part that did not have to be bad.

## What it does

```
Ctrl+V
  -> image on the clipboard, and no text?   no -> ordinary Ctrl+V, nothing else
  -> decide the name from the clock
  -> SendText the remote path into the prompt      (instant, no clipboard)
  -> upload in the background over the ssh forward (~150ms)
  -> receiver writes <name>.part, renames to <name>

Ctrl+Alt+V   same, but forced -- for when the clipboard carries both
```

Same rule VS Code uses, so there is nothing extra to remember. It is safe to
take Ctrl+V here for two reasons that are specific to this setup: Windows
Terminal already binds it to `Terminal.PasteFromClipboard`, so nothing
downstream ever saw the key and nvim's visual-block was already gone; and a
terminal cannot paste a picture, so intercepting the image case costs nothing
that worked before. Everything else is passed straight through, and with the
script not running Ctrl+V behaves exactly as it always did.

Text wins when the clipboard holds both, because copying a range out of Excel
or a table out of a browser puts an image and text there together and the text
is what you meant. Verified:

| clipboard | decision |
| --- | --- |
| image only (`Win+Shift+S`) | paste-shot |
| text only | ordinary `Ctrl+V` |
| image + text | ordinary `Ctrl+V` |
| empty | ordinary `Ctrl+V` |

The path is typed before the bytes arrive. That is safe because the receiver
renames into place: the path either does not exist yet or is a complete file,
never half of one. A tooltip reports the outcome, so a failed upload does not
leave you wondering why Claude cannot read the path you just sent.

## Why it is built this way

Each of these replaces something an earlier scp-based version documented as a
symptom to live with.

| Symptom | Cause | What is done instead |
| --- | --- | --- |
| Freezes for seconds | one ssh handshake per paste; through the cloudflared jump that is 1.2-2.5s and Windows has no working ControlMaster | ride the forward on the session that is already open: 133-206ms measured |
| Hangs waiting for a key passphrase | interactive auth inside a hidden window | no connection is opened, so no authentication happens |
| "paste it into Slack first" | the path was delivered via the clipboard, destroying the image | `SendText` types the path; the clipboard is untouched |
| Files pile up forever | no cleanup | anything older than a week is dropped on each write |
| Others cannot install it | distributed by scp from one person's 0700 home | it is in this repo; `git pull` |
| Screenshots readable by every account on the box | a 0755 directory on a shared machine | unix socket in `$XDG_RUNTIME_DIR` (0700), shots 0600 in a 0700 directory |
| Text paste breaks | Ctrl+V taken over unconditionally | intercepted only when the clipboard is an image and nothing else; every other case is passed through unchanged |
| Edit two lines in Notepad | hardcoded per person | the sender asks the receiver where shots go |

## Parts

| File | Runs on | What it is |
| --- | --- | --- |
| `receiver.py` | Linux | HTTP over a unix socket; validates the name, checks the PNG magic, writes and renames |
| `paste-shot.service` | Linux | systemd user unit for the above |
| `paste-shot.ahk` | Windows | the hotkey |
| `paste-shot.ps1` | Windows | clipboard to PNG to POST; usable on its own for debugging |

Installed by `setup.sh` (Linux) and `setup_windows.ps1` (Windows). The forward
lives in `~/.ssh/config`:

```sshconfig
Host <your host>
    LocalForward 127.0.0.1:47291 /run/user/<your uid>/paste-shot.sock
```

That uid is the one value here that is not derived, and it has to be: sshd
resolves neither `~` nor a relative path for a forwarded socket. Checked rather
than assumed -- forwards to `~/.cache/paste-shot.sock` and to
`.cache/paste-shot.sock` are both accepted by the client and then answer
nothing, while the absolute path works. `direct-streamlocal` takes an absolute
path only.

Nobody has to go looking for it though. `setup.sh` prints the finished line, and
so does this, run from the Windows side:

```sh
ssh <your host> 'echo "LocalForward 127.0.0.1:47291 ${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/paste-shot.sock"'
```

Everything else follows the account on its own: the receiver takes its socket
from `$XDG_RUNTIME_DIR`, the unit refers to `%h`, and the sender asks the
receiver where shots go rather than being told.

One prerequisite that is easy to miss: the receiver is a systemd **user**
service, so without `loginctl enable-linger <you>` it stops at logout -- and it
stops quietly, because the symptom is an absent socket, which reads as a broken
forward rather than a stopped service. `setup.sh` warns when lingering is off.

Port `47291` appears in three places -- the ssh config, the receiver's default,
and the two Windows scripts. Change all of them or none.

## When it does not work

Everything fails fast and says why; nothing hangs.

| Tooltip | Meaning |
| --- | --- |
| nothing happens, the text pastes | the clipboard had text on it too, so it was treated as a text paste. `Ctrl+Alt+V` forces the picture |
| `clipboard has no image` | from `Ctrl+Alt+V`. Copying a file in Explorer does not put an image on the clipboard; snip it |
| `no receiver on 127.0.0.1:47291` | no ssh session is up, or the forward is missing from `~/.ssh/config`, or the unit is down |
| `receiver unreachable` | the session dropped mid-upload. The path was already typed; it will not resolve |
| `receiver rejected it` | `journalctl --user -u paste-shot.service` |

Test the two halves separately. On the Linux box:

```sh
curl --unix-socket "$XDG_RUNTIME_DIR/paste-shot.sock" \
     -X POST --data-binary @shot.png http://x/20260730-143012-001.png
```

From Windows, with an image on the clipboard:

```powershell
powershell -NoProfile -STA -File paste-shot.ps1 -Name 20260730-143012-001.png
$LASTEXITCODE   # 0 sent, 1 no image, 2 unreachable, 3 rejected
```

## The real fix

Upstream support for OSC 5522, or a Windows terminal that implements it. Until
one of those exists, every route that puts a picture into a prompt over ssh is
some version of this. Worth re-filing #42712 with the Windows Terminal evidence
attached, since the original was closed without that case being made.
