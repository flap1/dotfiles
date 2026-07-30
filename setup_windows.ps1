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

.PARAMETER Gitconfig
    Also pull .config/git/.gitconfig into ~/.gitconfig by reference. Off by
    default: that config sets core.pager=delta and core.editor=nvim, so on a box
    without them every `git log` and every commit breaks. Turn it on once the
    Windows side actually has the toolchain (scoop install delta neovim).

.PARAMETER StatusLine
    Also configure Claude Code's status line. Off by default because it is far
    too slow here: the script shells out about twenty times per render and every
    process launched through the MSYS2 runtime costs roughly 100ms, so one render
    measures 2.2s against 0.1s on Linux. See Install-ClaudeCodeConfig for the
    numbers and for what would actually fix it.

.EXAMPLE
    powershell -File setup_windows.ps1

.EXAMPLE
    powershell -File setup_windows.ps1 -Gitconfig
#>

[CmdletBinding()]
param(
    [switch]$Gitconfig,
    [switch]$StatusLine
)

$ErrorActionPreference = 'Stop'

$repo = $PSScriptRoot
$wtLocalState = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'

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

function Set-GitSshCommand {
    Write-Host 'git core.sshCommand -> Windows OpenSSH'

    $sshExe = Join-Path $env:WINDIR 'System32\OpenSSH\ssh.exe'
    if (-not (Test-Path -LiteralPath $sshExe)) {
        Write-Host "  skipped: $sshExe not found"
        return
    }

    # Git for Windows ships its own MSYS-built ssh, and Git Bash puts it first on
    # PATH. The two implementations do not agree: the MSYS one treats backslashes
    # in ~/.ssh/config as literal characters and keeps its keys in a different
    # agent, so a host that works in PowerShell can fail in Git Bash for reasons
    # nothing reports. Pin git to the Windows binary so there is one ssh.
    $wanted = ($sshExe -replace '\\', '/')
    $current = git config --global --get core.sshCommand 2>$null
    if ($current -eq $wanted) {
        Write-Host '  already set'
        return
    }

    git config --global core.sshCommand $wanted
    Write-Host "  set to $wanted"
}

function Set-WindowsTerminalLink {
    param(
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][string]$LocalState
    )

    Write-Host "$LocalState -> $Target"

    # Linking settings.json on its own is the documented trap: Terminal replaces
    # the file when the settings GUI saves, which detaches a link and stops
    # hot-reload from seeing editor changes. Linking the whole LocalState
    # directory survives that, and makes the sync bidirectional -- GUI edits land
    # in the repo with nothing to run afterwards.
    $existing = Get-Item -LiteralPath $LocalState -Force -ErrorAction SilentlyContinue
    if ($existing -and ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        $current = $null
        if ($existing.Target) { $current = $existing.Target[0] }
        if ($current -and (Test-Path -LiteralPath $current) -and
            (Resolve-Path -LiteralPath $current).Path -eq (Resolve-Path -LiteralPath $Target).Path) {
            Write-Host '  already linked'
            return
        }
    }

    # Terminal holds settings.json open to watch it, so the directory cannot be
    # renamed out from under a running instance. Refusing here beats a half-moved
    # LocalState.
    if (Get-Process WindowsTerminal -ErrorAction SilentlyContinue) {
        Write-Host '  skipped: Windows Terminal is running. Close every window and'
        Write-Host '           rerun this from another host (VS Code terminal, or Win+R'
        Write-Host '           powershell) to link it.'
        return
    }

    if (-not (Test-Path -LiteralPath $Target)) {
        Write-Host "  skipped: $Target does not exist in this checkout"
        return
    }

    if ($existing) {
        if ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            [IO.Directory]::Delete($LocalState)
            Write-Host '  replaced existing link'
        } else {
            # The live settings.json is the one thing in here that is not
            # reproducible, so carry it over rather than trusting the repo copy
            # to be current.
            $liveSettings = Join-Path $LocalState 'settings.json'
            $repoSettings = Join-Path $Target 'settings.json'
            if ((Test-Path -LiteralPath $liveSettings) -and
                (-not (Test-Path -LiteralPath $repoSettings) -or
                 (Get-FileHash $liveSettings).Hash -ne (Get-FileHash $repoSettings).Hash)) {
                Copy-Item -LiteralPath $liveSettings -Destination $repoSettings -Force
                Write-Host '  copied the live settings.json into the repo first'
            }
            $backup = "$LocalState." + (Get-Date -Format 'yyyyMMddHHmmss')
            Move-Item -LiteralPath $LocalState -Destination $backup
            Write-Host "  moved aside -> $backup"
        }
    }

    New-Item -ItemType Junction -Path $LocalState -Target $Target | Out-Null
    Write-Host '  linked (settings edited in the GUI now show up as repo changes)'
}

function Install-ClaudeCodeConfig {
    param(
        [Parameter(Mandatory)][string]$RepoClaude,
        [Parameter(Mandatory)][string]$UserClaude,
        [switch]$StatusLine
    )

    # ~/.claude cannot be linked wholesale: it also holds credentials, session
    # transcripts and history that belong to this machine only. So skills -- a
    # directory, and identical on every box -- gets a junction, and settings.json
    # is composed from the shared file plus a Windows layer.
    #
    # Composed rather than linked because a file cannot be a junction and both
    # alternatives fail here: a symlink needs elevation or Developer Mode, and a
    # hardlink detaches the moment Claude Code rewrites the file, which it does
    # whenever you change a setting from /config.
    #
    # Nothing is stripped. settings.json is cross-platform by construction -- the
    # hooks that need rtk and code-review-graph live in settings.linux.json and
    # are applied by setup.sh on that side.
    #
    # The status line is the exception, and it is added here rather than shipped
    # in either layer. The script itself is portable -- it needs sh and jq, both
    # of which this box has once jq is installed -- but the command differs:
    # Linux runs it directly, Windows has to hand it to bash, and the path has
    # to be absolute because it is not this script's business to guess whether
    # Claude Code expands ~ on Windows.

    Set-DirectoryJunction -Target (Join-Path $RepoClaude 'skills') -Link (Join-Path $UserClaude 'skills')

    $shared = Join-Path $RepoClaude 'settings.json'
    $overlay = Join-Path $RepoClaude 'settings.windows.json'
    $target = Join-Path $UserClaude 'settings.json'

    Write-Host "$target <- settings.json + settings.windows.json"

    if (-not (Test-Path -LiteralPath $shared)) {
        Write-Host "  skipped: $shared does not exist in this checkout"
        return
    }

    $settings = Get-Content -LiteralPath $shared -Raw -Encoding UTF8 | ConvertFrom-Json

    if (Test-Path -LiteralPath $overlay) {
        $windows = Get-Content -LiteralPath $overlay -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($prop in $windows.PSObject.Properties) {
            if ($prop.Name -eq '$comment') { continue }
            # Top level only. A deep merge would let the overlay half-override a
            # nested object, which is harder to reason about than replacing the
            # whole key and being able to see what you replaced.
            $settings | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
            Write-Host "  overlaid $($prop.Name)"
        }
    }

    # Not $statusline: PowerShell variable names are case-insensitive, so that
    # name is the -StatusLine switch and assigning a path to it blows up the
    # parameter binding on the next call.
    $statuslineScript = Join-Path $RepoClaude 'statusline-command.sh'
    $bash = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
        "$env:USERPROFILE\scoop\apps\git\current\bin\bash.exe"
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    $jq = Get-Command jq.exe -ErrorAction SilentlyContinue

    if (-not (Test-Path -LiteralPath $statuslineScript)) {
        Write-Host '  statusLine: skipped, no statusline-command.sh in this checkout'
    } elseif (-not $bash) {
        Write-Host '  statusLine: skipped, no bash.exe (install Git for Windows)'
    } elseif (-not $jq) {
        # The script is all jq. Without it Claude Code would run the status line
        # on every render, get a page of "jq: command not found", and show an
        # empty bar with no clue why.
        Write-Host '  statusLine: skipped, jq not installed (scoop install jq)'
    } elseif (-not $StatusLine) {
        # Off by default, and not for want of trying: it works, it is just far
        # too slow to leave on. The script shells out about twenty times per
        # render -- fourteen jq calls, five git calls, and the rest -- and every
        # process launched through the MSYS2 runtime costs roughly 100ms here
        # because POSIX fork() has to be emulated. Measured on this box:
        #
        #   jq --version   84ms      git --version  131ms
        #   node --version 84ms      bash -c true   144ms
        #
        #   one render, Windows  2166 / 2292 / 2245 ms
        #   one render, Linux         107 / 82 / 101 ms
        #
        # A status line that takes two seconds is worse than none: Claude Code
        # would spend its time re-running it and showing a stale bar. This is
        # not a Git Bash problem and no other POSIX layer fixes it -- the cost
        # is the process count. The fix is to stop spawning: one pass over the
        # payload instead of fourteen, and `git status --porcelain=v2 --branch`
        # instead of five git calls. Pass -StatusLine to turn it on anyway.
        Write-Host '  statusLine: off (2.2s per render here; see the note in this function)'
    } else {
        $settings | Add-Member -NotePropertyName 'statusLine' -NotePropertyValue ([pscustomobject]@{
            type    = 'command'
            command = '"{0}" "{1}"' -f ($bash -replace '\\', '/'), ($statuslineScript -replace '\\', '/')
        }) -Force
        Write-Host '  statusLine: wired through bash (slow -- see the note in this function)'
    }

    $json = $settings | ConvertTo-Json -Depth 20

    if (Test-Path -LiteralPath $target) {
        if ([IO.File]::ReadAllText($target).TrimEnd() -eq $json.TrimEnd()) {
            Write-Host '  already current'
            return
        }
        # Hand edits made through /config live only here, so keep a copy.
        $backup = New-TimestampedCopy -Path $target
        Write-Host "  backed up -> $backup"
    } else {
        $parent = Split-Path $target -Parent
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
    }

    [IO.File]::WriteAllText($target, $json + "`n", (New-Object Text.UTF8Encoding($false)))
    Write-Host '  written'
}

function Install-PasteShot {
    param([Parameter(Mandatory)][string]$ScriptDir)

    # Ctrl+Alt+V in Windows Terminal hands a screenshot to a Claude Code session
    # running over ssh. See .config/paste-shot/README.md.

    $script = Join-Path $ScriptDir 'paste-shot.ahk'
    $link = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\paste-shot.lnk'

    Write-Host "$link -> $script"

    if (-not (Test-Path -LiteralPath $script)) {
        Write-Host "  skipped: $script does not exist in this checkout"
        return
    }

    # The winget package installs per-user; the Program Files paths are there
    # for a machine-wide install done by hand.
    $ahk = @(
        "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
        "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey64.exe"
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

    if (-not $ahk) {
        Write-Host '  skipped: AutoHotkey v2 not found. winget install AutoHotkey.AutoHotkey'
        return
    }

    # The shortcut runs the interpreter with the script as an argument rather
    # than the .ahk directly. Launching the .ahk relies on the file association,
    # which points at the UX launcher and picks an interpreter version at run
    # time -- this script is v2-only and says so, so pin it here instead of
    # finding out at boot.
    $shell = New-Object -ComObject WScript.Shell
    if (Test-Path -LiteralPath $link) {
        $existing = $shell.CreateShortcut($link)
        if ($existing.TargetPath -eq $ahk -and $existing.Arguments -eq "`"$script`"") {
            Write-Host '  already registered'
            return
        }
        Write-Host '  updating existing shortcut'
    }

    $shortcut = $shell.CreateShortcut($link)
    $shortcut.TargetPath = $ahk
    $shortcut.Arguments = "`"$script`""
    $shortcut.WorkingDirectory = $ScriptDir
    $shortcut.Description = 'Ctrl+Alt+V sends a screenshot to Claude Code over ssh'
    $shortcut.Save()
    Write-Host '  registered (starts at login; run it now with the same command to use it today)'
}

# XDG_CONFIG_HOME is set to ~/.config on this box, so nvim reads ~/.config/nvim
# rather than the Windows-native ~/AppData/Local/nvim.
Set-DirectoryJunction -Target (Join-Path $repo '.config\nvim') -Link (Join-Path $env:USERPROFILE '.config\nvim')

Set-GitSshCommand

Set-WindowsTerminalLink -Target (Join-Path $repo '.config\windows-terminal\LocalState') -LocalState $wtLocalState

Install-ClaudeCodeConfig -RepoClaude (Join-Path $repo '.claude') -UserClaude (Join-Path $env:USERPROFILE '.claude') -StatusLine:$StatusLine

Install-PasteShot -ScriptDir (Join-Path $repo '.config\paste-shot')

if ($Gitconfig) {
    Add-GitconfigInclude -Shared (Join-Path $repo '.config\git\.gitconfig') -Gitconfig (Join-Path $env:USERPROFILE '.gitconfig')
} else {
    Write-Host 'gitconfig: skipped (pass -Gitconfig; needs delta and nvim installed)'
}
