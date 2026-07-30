#Requires -Version 5.1

<#
.SYNOPSIS
    Install the paste-shot hotkey on this machine.

.DESCRIPTION
    The Windows half of paste-shot: Ctrl+V in a terminal hands a screenshot to a
    Claude Code session running on a remote machine over ssh.

    Split out of setup_windows.ps1 on purpose. This is an optional add-on for
    one specific problem, not part of wiring up a machine, and the two halves
    of it -- this and setup_paste_shot.sh on the remote box -- read better as a
    pair with the same name than as two clauses buried in two larger scripts.

    Idempotent. Rerunning it updates the shortcut only if it points somewhere
    else.

    See .config/paste-shot/README.md for why any of this is needed, and for the
    remote half.

.PARAMETER Start
    Also launch the hotkey now, rather than waiting for the next login.

.EXAMPLE
    powershell -File setup_paste_shot.ps1 -Start
#>

[CmdletBinding()]
param(
    [switch]$Start
)

$ErrorActionPreference = 'Stop'

$scriptDir = Join-Path $PSScriptRoot '.config\paste-shot'
$hotkey = Join-Path $scriptDir 'paste-shot.ahk'
$link = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\paste-shot.lnk'

if (-not (Test-Path -LiteralPath $hotkey)) {
    Write-Host "not found: $hotkey"
    exit 1
}

# The winget package installs per-user; the Program Files paths are there for a
# machine-wide install done by hand.
$ahk = @(
    "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
    "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey64.exe"
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

if (-not $ahk) {
    Write-Host 'AutoHotkey v2 is not installed. Install it with:'
    Write-Host ''
    Write-Host '    winget install AutoHotkey.AutoHotkey'
    exit 1
}

Write-Host "hotkey   -> $hotkey"
Write-Host "runtime  -> $ahk"

# The shortcut runs the interpreter with the script as an argument rather than
# the .ahk directly. Launching the .ahk relies on the file association, which
# points at the UX launcher and picks an interpreter version at run time -- this
# script is v2-only and says so, so pin it here instead of finding out at boot.
$shell = New-Object -ComObject WScript.Shell
$needsWrite = $true
if (Test-Path -LiteralPath $link) {
    $existing = $shell.CreateShortcut($link)
    if ($existing.TargetPath -eq $ahk -and $existing.Arguments -eq "`"$hotkey`"") {
        Write-Host 'startup  -> already registered'
        $needsWrite = $false
    }
}

if ($needsWrite) {
    $shortcut = $shell.CreateShortcut($link)
    $shortcut.TargetPath = $ahk
    $shortcut.Arguments = "`"$hotkey`""
    $shortcut.WorkingDirectory = $scriptDir
    $shortcut.Description = 'Ctrl+V sends a screenshot to Claude Code over ssh'
    $shortcut.Save()
    Write-Host "startup  -> $link"
}

if ($Start) {
    Get-Process AutoHotkey64 -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -eq $ahk } |
        Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 300
    Start-Process -FilePath $ahk -ArgumentList "`"$hotkey`""
    Write-Host 'running  -> started (green H in the notification area)'
} else {
    Write-Host 'running  -> starts at next login. Pass -Start to run it now.'
}

Write-Host @'

The remote half has to be running too. On the machine you ssh into:

    ./setup_paste_shot.sh

That prints the LocalForward line for ~/.ssh/config. Add it under the Host you
already use, then reconnect -- a session opened before that line existed does
not carry the forward.
'@
