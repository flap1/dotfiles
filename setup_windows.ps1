#Requires -Version 5.1

# Windows Terminal keeps its settings inside the packaged app's LocalState. A
# symlink there needs elevation or Developer Mode, neither of which is a given
# on a fresh box, and a hardlink is worse: Terminal rewrites the file whenever
# settings change in the UI, which silently detaches the link and leaves stale
# config in place with no warning. So sync by copy, and make the direction
# explicit rather than guessing which side is newer.
#
#   powershell -File setup_windows.ps1          # dotfiles -> Windows Terminal
#   powershell -File setup_windows.ps1 -Pull    # Windows Terminal -> dotfiles
#
# The -Pull direction is how UI edits get captured; without it, anything changed
# through the settings GUI is lost the next time this runs.

[CmdletBinding()]
param(
    [switch]$Pull
)

$ErrorActionPreference = 'Stop'

$repoSettings = Join-Path $PSScriptRoot '.config\windows-terminal\settings.json'
$liveSettings = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'

if ($Pull) {
    $src = $liveSettings
    $dst = $repoSettings
} else {
    $src = $repoSettings
    $dst = $liveSettings
}

if (-not (Test-Path $src)) {
    throw "Source settings not found: $src"
}

# Terminal's own LocalState only exists once the app has run at least once.
$dstParent = Split-Path $dst -Parent
if (-not (Test-Path $dstParent)) {
    throw "Destination directory not found: $dstParent (launch Windows Terminal once first?)"
}

# Refuse to propagate a file Terminal would reject, so a broken edit on one side
# cannot take out the other side too.
try {
    Get-Content $src -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null
} catch {
    throw "Source is not valid JSON, refusing to copy: $src`n$($_.Exception.Message)"
}

if (Test-Path $dst) {
    if ((Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash) {
        Write-Host "Already in sync: $dst"
        exit 0
    }
    $backup = "$dst." + (Get-Date -Format 'yyyyMMddHHmmss')
    Copy-Item $dst $backup
    Write-Host "Backed up $dst -> $backup"
}

Copy-Item $src $dst -Force
Write-Host "Copied $src -> $dst"
Write-Host 'Windows Terminal picks the change up on save; reopen a tab if not.'
