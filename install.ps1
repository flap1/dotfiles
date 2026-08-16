#Requires -Version 5.1

<#
.SYNOPSIS
    Wire this checkout into Windows. No software.

.DESCRIPTION
    Junctions and composed config. Software comes from bootstrap.ps1 (scoop).
    Already set up? this script alone is enough.

    Directories are junctions: a symlink needs elevation or Developer Mode, and
    a hardlink detaches the moment git or Windows Terminal replaces a file.

    Claude, Cursor, and Codex compose through the same node scripts as Linux.

.PARAMETER Gitconfig
    Include the shared gitconfig even when nvim or delta is not on PATH.
    Without them `git log` and every commit break, so the default is to wait.

.EXAMPLE
    .\install.ps1

.EXAMPLE
    .\install.ps1 -Gitconfig
#>

[CmdletBinding()]
param(
    [switch]$Gitconfig
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
            [IO.Directory]::Delete($Link)
            Write-Host '  replaced existing link'
        } else {
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

    $wanted = ($sshExe -replace '\\', '/')
    $current = git config --global --get core.sshCommand 2>$null
    if ($current -eq $wanted) {
        Write-Host '  already set'
        return
    }

    git config --global core.sshCommand $wanted
    Write-Host "  set to $wanted"
}

function Restore-WindowsTerminalOwnership {
    param(
        [Parameter(Mandatory)][string]$RepoLocalState,
        [Parameter(Mandatory)][string]$LocalState
    )

    Write-Host 'Windows Terminal LocalState'

    $existing = Get-Item -LiteralPath $LocalState -Force -ErrorAction SilentlyContinue
    $isLink = $existing -and ($existing.Attributes -band [IO.FileAttributes]::ReparsePoint)
    if (-not $isLink) {
        Write-Host '  already a real directory (or absent)'
        return
    }

    $current = $null
    if ($existing.Target) { $current = $existing.Target[0] }
    $pointsAtRepo = $false
    if ($current) {
        $a = $current.TrimEnd('\')
        $b = $RepoLocalState.TrimEnd('\')
        $pointsAtRepo = [string]::Equals($a, $b, [StringComparison]::OrdinalIgnoreCase)
    }
    if (-not $pointsAtRepo) {
        Write-Host '  linked, but not to this repo; leaving it'
        return
    }

    if (Get-Process WindowsTerminal -ErrorAction SilentlyContinue) {
        Write-Host '  skipped: close every Windows Terminal window and rerun to'
        Write-Host '           unhook LocalState from the repository.'
        return
    }

    $backup = Join-Path $env:TEMP ('wt-settings-' + (Get-Date -Format 'yyyyMMddHHmmss') + '.json')
    $fromRepo = Join-Path $RepoLocalState 'settings.json'
    $fromLive = Join-Path $LocalState 'settings.json'
    if (Test-Path -LiteralPath $fromLive) {
        Copy-Item -LiteralPath $fromLive -Destination $backup -Force
    } elseif (Test-Path -LiteralPath $fromRepo) {
        Copy-Item -LiteralPath $fromRepo -Destination $backup -Force
    }

    [IO.Directory]::Delete($LocalState)
    New-Item -ItemType Directory -Path $LocalState | Out-Null
    if (Test-Path -LiteralPath $backup) {
        Copy-Item -LiteralPath $backup -Destination (Join-Path $LocalState 'settings.json') -Force
        Write-Host '  unhooked; settings copied to a real LocalState'
    } else {
        Write-Host '  unhooked; Terminal will write a new settings.json on next launch'
    }
}

function Invoke-Compose {
    param(
        [Parameter(Mandatory)][string]$Script,
        [Parameter(Mandatory)][hashtable]$EnvVars
    )

    $node = (Get-Command node.exe -ErrorAction SilentlyContinue).Source
    if (-not $node) {
        Write-Host "  skipped: node is not on PATH (run bootstrap.ps1)"
        return
    }
    $js = Join-Path $repo "lib\$Script"
    if (-not (Test-Path -LiteralPath $js)) {
        Write-Host "  skipped: $js missing"
        return
    }

    foreach ($key in $EnvVars.Keys) {
        Set-Item -Path "Env:$key" -Value $EnvVars[$key]
    }
    & $node $js
    foreach ($key in $EnvVars.Keys) {
        Remove-Item -Path "Env:$key" -ErrorAction SilentlyContinue
    }
}

Set-DirectoryJunction -Target (Join-Path $repo '.config\nvim') -Link (Join-Path $env:USERPROFILE '.config\nvim')
Set-DirectoryJunction -Target (Join-Path $repo '.config\yazi') -Link (Join-Path $env:APPDATA 'yazi\config')

Set-GitSshCommand
Restore-WindowsTerminalOwnership -RepoLocalState (Join-Path $repo '.config\windows-terminal\LocalState') -LocalState $wtLocalState

Set-DirectoryJunction -Target (Join-Path $repo '.claude\skills') -Link (Join-Path $env:USERPROFILE '.claude\skills')
Set-DirectoryJunction -Target (Join-Path $repo '.claude\hooks') -Link (Join-Path $env:USERPROFILE '.claude\hooks')

$statusline = Join-Path $repo '.claude\statusline.mjs'
$node = (Get-Command node.exe -ErrorAction SilentlyContinue).Source
$claudeEnv = @{
    SHARED = (Join-Path $repo '.claude\settings.json')
    WINDOWS = (Join-Path $repo '.claude\settings.windows.json')
    LOCAL  = (Join-Path $repo '.claude\settings.local.json')
    TARGET = (Join-Path $env:USERPROFILE '.claude\settings.json')
}
if ($node -and (Test-Path -LiteralPath $statusline)) {
    $claudeEnv['STATUSLINE_CMD'] = 'node "{0}"' -f ($statusline -replace '\\', '/')
}
Write-Host 'Claude settings'
Invoke-Compose -Script 'compose-claude.js' -EnvVars $claudeEnv

Write-Host 'Cursor settings'
Invoke-Compose -Script 'compose-cursor.js' -EnvVars @{
    SHARED = (Join-Path $repo '.cursor\cli-config.json')
    LOCAL  = (Join-Path $repo '.cursor\cli-config.local.json')
    TARGET = (Join-Path $env:USERPROFILE '.cursor\cli-config.json')
}

$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
Set-DirectoryJunction -Target (Join-Path $repo '.codex\agents') -Link (Join-Path $codexHome 'agents')
Write-Host 'Codex settings'
Invoke-Compose -Script 'compose-codex.js' -EnvVars @{
    SHARED = (Join-Path $repo '.codex\config.toml')
    TARGET = (Join-Path $codexHome 'config.toml')
}

$editorReady = [bool](Get-Command nvim -ErrorAction SilentlyContinue)
$pagerReady = [bool](Get-Command delta -ErrorAction SilentlyContinue)

if ($Gitconfig -or ($editorReady -and $pagerReady)) {
    Add-GitconfigInclude -Shared (Join-Path $repo '.config\git\.gitconfig') -Gitconfig (Join-Path $env:USERPROFILE '.gitconfig')
} else {
    $missing = @()
    if (-not $editorReady) { $missing += 'nvim' }
    if (-not $pagerReady) { $missing += 'delta' }
    Write-Host "gitconfig: skipped, not on PATH: $($missing -join ', ') (pass -Gitconfig to force)"
}
