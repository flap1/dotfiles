#Requires -Version 5.1

<#
.SYNOPSIS
    Install the paste-shot hotkey on this machine.

.PARAMETER Start
    Also launch the hotkey now, rather than waiting for the next login.

.EXAMPLE
    .\setup.ps1 -Start
#>

[CmdletBinding()]
param(
    [switch]$Start
)

$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
$hotkey = Join-Path $scriptDir 'paste-shot.ahk'
$link = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\paste-shot.lnk'

if (-not (Test-Path -LiteralPath $hotkey)) {
    Write-Host "not found: $hotkey"
    exit 1
}

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

    .config/paste-shot/setup.sh

That prints the LocalForward line for ~/.ssh/config.
'@
