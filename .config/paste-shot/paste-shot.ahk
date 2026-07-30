#Requires AutoHotkey v2.0
#SingleInstance Force

; Hand a Windows screenshot to a Claude Code session running over ssh.
;
; Ctrl+V in Windows Terminal: if the clipboard holds a picture and nothing else,
; the remote path it is about to have is typed and the upload runs in the
; background. Anything else is an ordinary paste. Same rule VS Code uses, so
; there is nothing extra to remember.
;
; Taking over Ctrl+V is safe here specifically because Windows Terminal already
; binds it to Terminal.PasteFromClipboard -- nothing downstream ever sees the
; key, so nvim's visual-block is not being taken away; it was already gone. And
; a terminal cannot paste a picture anyway, so intercepting the image case
; costs nothing that worked before. Every other case is passed straight
; through: if this script is not running, or errors, Ctrl+V behaves exactly as
; it does today.
;
; Text wins when the clipboard holds both. Copying a range out of Excel or a
; table out of a browser puts an image and text on the clipboard together, and
; in a terminal the text is what you meant. Ctrl+Alt+V forces the picture for
; the times that guess is wrong.
;
; Why the path is typed before the upload finishes. The upload takes about a
; second, almost all of it PowerShell starting; the transfer itself is ~150ms.
; Waiting for it would put that second between your keypress and any feedback,
; every time. Instead the name is decided here, typed immediately, and sent to
; the receiver, which writes under a temporary name and renames -- so the path
; either does not exist yet or is a complete file, never half of one. The
; tooltip tells you which.
;
; See .config/paste-shot/README.md for why this exists rather than Ctrl+V
; working on its own.

; Must match the LocalForward in ~/.ssh/config and the receiver's default.
PORT := 47291

; Where the shots land on the remote box. Asked for once, rather than written
; down here, so there is nothing to edit per person and nothing to go stale if
; the remote account moves.
global RemoteDir := ""

#HotIf WinActive("ahk_exe WindowsTerminal.exe")
; $ so the pass-through Send below cannot re-trigger this hotkey.
$^v:: PasteOrShot()
; Force the picture even when the clipboard also carries text.
^!v:: PasteShot()
#HotIf

PasteOrShot() {
    if (HasImage() && !HasText()) {
        PasteShot()
        return
    }
    ; Byte-for-byte what Windows Terminal would have done on its own.
    Send("^v")
}

; CF_DIB and CF_DIBV5. Asking the clipboard directly costs microseconds;
; Clipboard.GetImage on the PowerShell side would answer the same question
; only after paying a second to start.
HasImage() => DllCall("IsClipboardFormatAvailable", "UInt", 8)
            || DllCall("IsClipboardFormatAvailable", "UInt", 17)

; CF_UNICODETEXT.
HasText() => DllCall("IsClipboardFormatAvailable", "UInt", 13)

PasteShot() {
    global RemoteDir, PORT

    if !HasImage() {
        ; Reachable only through Ctrl+Alt+V; the Ctrl+V path has already checked.
        Flash("clipboard has no image")
        return
    }

    if (RemoteDir = "") {
        RemoteDir := AskRemoteDir(PORT)
        if (RemoteDir = "") {
            Flash("no receiver on 127.0.0.1:" PORT " -- is the ssh session up?")
            return
        }
    }

    name := FormatTime(A_Now, "yyyyMMdd-HHmmss") "-" Format("{:03}", A_MSec)
    name .= ".png"

    ; SendText, not the clipboard. Routing the path through the clipboard is
    ; what forces "paste it into Slack first" on anyone who wants the picture in
    ; two places; the screenshot stays on the clipboard this way.
    SendText(RemoteDir "/" name)

    ps := A_ComSpec ' /c powershell -NoProfile -STA -ExecutionPolicy Bypass -File "'
        . A_ScriptDir '\paste-shot.ps1" -Name ' name

    Flash("uploading " name, 0)
    ; Off the hotkey thread: RunWait here would freeze the keyboard for the
    ; duration of the upload, which is the exact failure the old scp version
    ; documented as a symptom.
    SetTimer(() => Upload(ps, name), -1)
}

Upload(command, name) {
    ; The exit codes are paste-shot.ps1's contract, so a failure says which of
    ; the three things went wrong rather than "it did not work".
    code := RunWait(command, , "Hide")
    switch code {
        case 0: Flash("sent " name)
        case 1: Flash("clipboard lost its image before the upload")
        case 2: Flash("receiver unreachable -- the path just typed will not resolve")
        default: Flash("receiver rejected it (exit " code ")")
    }
}

Flash(text, timeout := 2500) {
    ToolTip(text)
    if (timeout > 0)
        SetTimer(() => ToolTip(), -timeout)
}

AskRemoteDir(port) {
    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        ; Resolve, connect, send, receive. A refused loopback port answers at
        ; once; these caps only matter if something is listening and wedged.
        http.SetTimeouts(1000, 1000, 1000, 3000)
        http.Open("GET", "http://127.0.0.1:" port "/", false)
        http.Send()
        if (http.Status != 200)
            return ""
        return Trim(http.ResponseText, " `t`r`n")
    } catch {
        return ""
    }
}
