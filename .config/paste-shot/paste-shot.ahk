#Requires AutoHotkey v2.0
#SingleInstance Force

; Hand a Windows screenshot to a Claude Code session running over ssh.
;
; Ctrl+Alt+V in Windows Terminal: types the remote path the picture is about to
; have, and uploads it in the background. Claude reads the file when you send
; the message.
;
; Why not Ctrl+V. Taking over the standard paste means every Windows Terminal
; window is affected, including the ones with no Claude in them, and a bug in
; here breaks pasting text everywhere. A chord of its own costs one extra
; modifier and cannot break anything that already works.
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
^!v:: PasteShot()
#HotIf

PasteShot() {
    global RemoteDir, PORT

    ; CF_DIB. Clipboard.GetImage on the PowerShell side would tell us the same
    ; thing, but only after paying a second to start it.
    if !DllCall("IsClipboardFormatAvailable", "UInt", 8) {
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
