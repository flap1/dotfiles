#Requires -Version 5.1

<#
.SYNOPSIS
    Wire this checkout into Windows.

.DESCRIPTION
    Replaces setup_windows.bat, which had rotted in three ways: it linked
    .config\wezterm and .config\posh (neither exists in this repo any more), it
    hardcoded %UserProfile%\dotfiles instead of resolving its own location, and
    it needed elevation because `mklink /d` does.

    Design rules learned the hard way on Windows:

    - Directories are junctions, not symlinks. `mklink /d` and
      New-Item -ItemType SymbolicLink need elevation or Developer Mode; a
      junction needs neither and behaves the same for our purposes.
    - Nothing is hardlinked. A hardlink survives an in-place write but detaches
      the moment a tool replaces the file, which is exactly what git and
      Windows Terminal do on save -- leaving stale config with no warning.
    - Files that mix shared and machine-local settings are included by
      reference, never replaced. ~/.gitconfig here holds this box's git-lfs
      filter and credential helper; clobbering it to link the repo copy would
      throw those away.
    - Anything about to be displaced is moved aside with a timestamp first.

.PARAMETER Pull
    Copy Windows Terminal's live settings.json back into this repo instead of
    pushing the repo copy out, and skip everything else. This is how edits made
    through the Terminal settings GUI get captured; without it they are lost on
    the next run.

.PARAMETER Gitconfig
    Also pull .config/git/.gitconfig into ~/.gitconfig by reference. Off by
    default: that config sets core.pager=delta and core.editor=nvim, so on a box
    without them every `git log` and every commit breaks. Turn it on once the
    Windows side actually has the toolchain (scoop install delta neovim).

.EXAMPLE
    powershell -File setup_windows.ps1

.EXAMPLE
    powershell -File setup_windows.ps1 -Pull
#>

[CmdletBinding()]
param(
    [switch]$Pull,
    [switch]$Gitconfig
)

$ErrorActionPreference = 'Stop'

$repo = $PSScriptRoot
$wtSettings = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'

function New-TimestampedCopy {
    param([Parameter(Mandatory)][string]$Path)

    $backup = "$Path." + (Get-Date -Format 'yyyyMMddHHmmss')
    Copy-Item -LiteralPath $Path -Destination $backup
    return $backup
}

function Set-DirectoryJunction {
    param(
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][string]$Link
    )

    Write-Host "$Link -> $Target"

    if (-not (Test-Path -LiteralPath $Target)) {
        Write-Host "  skipped: $Target does not exist in this checkout"
        return
    }

    $existing = Get-Item -LiteralPath $Link -Force -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $current = $null
            if ($existing.Target) { $current = $existing.Target[0] }
            if ($current -and (Test-Path -LiteralPath $current) -and
                (Resolve-Path -LiteralPath $current).Path -eq (Resolve-Path -LiteralPath $Target).Path) {
                Write-Host '  already linked'
                return
            }
            # Deletes the junction itself, not what it points at.
            [IO.Directory]::Delete($Link)
            Write-Host '  replaced existing link'
        } else {
            # A real directory holds data that may only exist on this machine,
            # so it is kept rather than deleted.
            $backup = "$Link." + (Get-Date -Format 'yyyyMMddHHmmss')
            Move-Item -LiteralPath $Link -Destination $backup
            Write-Host "  moved aside -> $backup"
        }
    }

    $parent = Split-Path $Link -Parent
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    Write-Host '  linked'
}

function Add-GitconfigInclude {
    param(
        [Parameter(Mandatory)][string]$Shared,
        [Parameter(Mandatory)][string]$Gitconfig
    )

    Write-Host "$Gitconfig includes $Shared"

    if (-not (Test-Path -LiteralPath $Shared)) {
        Write-Host "  skipped: $Shared does not exist in this checkout"
        return
    }

    # git wants forward slashes here, and understands ~ for the home directory.
    $includePath = $Shared.Replace('\', '/')
    $homeDir = $env:USERPROFILE.Replace('\', '/')
    if ($includePath.StartsWith("$homeDir/", [StringComparison]::OrdinalIgnoreCase)) {
        $includePath = '~' + $includePath.Substring($homeDir.Length)
    }

    $existing = ''
    if (Test-Path -LiteralPath $Gitconfig) {
        $existing = [IO.File]::ReadAllText($Gitconfig)
        if ($existing -match [regex]::Escape($includePath)) {
            Write-Host '  already included'
            return
        }
        $backup = New-TimestampedCopy -Path $Gitconfig
        Write-Host "  backed up -> $backup"
    }

    # The include goes first on purpose: git takes the last value it sees, so
    # whatever is already in this file keeps overriding the shared defaults.
    $block = "[include]`n`tpath = $includePath`n"
    [IO.File]::WriteAllText($Gitconfig, $block + $existing, (New-Object Text.UTF8Encoding($false)))
    Write-Host '  include added at the top'
}

function Sync-WindowsTerminal {
    param(
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$Live,
        [switch]$Pull
    )

    if ($Pull) {
        $src = $Live
        $dst = $Repo
    } else {
        $src = $Repo
        $dst = $Live
    }

    Write-Host "windows-terminal: $src -> $dst"

    if (-not (Test-Path -LiteralPath $src)) {
        Write-Host "  skipped: $src not found"
        return
    }

    # LocalState only exists once Terminal has been launched at least once.
    $dstParent = Split-Path $dst -Parent
    if (-not (Test-Path -LiteralPath $dstParent)) {
        Write-Host "  skipped: $dstParent not found (launch Windows Terminal once first)"
        return
    }

    # Refuse to propagate a file Terminal would reject, so a broken edit on one
    # side cannot take out the other side too.
    try {
        Get-Content -LiteralPath $src -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null
    } catch {
        throw "Source is not valid JSON, refusing to copy: $src`n$($_.Exception.Message)"
    }

    if (Test-Path -LiteralPath $dst) {
        if ((Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash) {
            Write-Host '  already in sync'
            return
        }
        $backup = New-TimestampedCopy -Path $dst
        Write-Host "  backed up -> $backup"
    }

    Copy-Item -LiteralPath $src -Destination $dst -Force
    Write-Host '  copied (Terminal picks it up on save; reopen a tab if not)'
}

$wtRepoSettings = Join-Path $repo '.config\windows-terminal\settings.json'

if ($Pull) {
    Sync-WindowsTerminal -Repo $wtRepoSettings -Live $wtSettings -Pull
    return
}

# XDG_CONFIG_HOME is set to ~/.config on this box, so nvim reads ~/.config/nvim
# rather than the Windows-native ~/AppData/Local/nvim.
Set-DirectoryJunction -Target (Join-Path $repo '.config\nvim') -Link (Join-Path $env:USERPROFILE '.config\nvim')

if ($Gitconfig) {
    Add-GitconfigInclude -Shared (Join-Path $repo '.config\git\.gitconfig') -Gitconfig (Join-Path $env:USERPROFILE '.gitconfig')
} else {
    Write-Host 'gitconfig: skipped (pass -Gitconfig; needs delta and nvim installed)'
}

Sync-WindowsTerminal -Repo $wtRepoSettings -Live $wtSettings
