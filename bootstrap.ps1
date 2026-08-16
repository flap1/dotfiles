#Requires -Version 5.1

<#
.SYNOPSIS
    One entry point for a Windows machine with nothing on it.

.DESCRIPTION
    Installs scoop if needed, then neovim, delta, yazi, and node, then
    install.ps1. Already set up? .\install.ps1 alone.

.EXAMPLE
    .\bootstrap.ps1
#>

[CmdletBinding()]
param(
    [switch]$Gitconfig
)

$ErrorActionPreference = 'Stop'

function Install-ScoopIfMissing {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host 'scoop: already on PATH'
        return
    }

    Write-Host 'scoop: installing'
    # winget is the installer that does not pipe a remote script into iex.
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id ScoopInstaller.Scoop -e --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host 'winget is not on PATH; install scoop from https://scoop.sh and rerun.'
        exit 1
    }

    $shims = Join-Path $env:USERPROFILE 'scoop\shims'
    if ((Test-Path -LiteralPath $shims) -and ($env:PATH -notlike "*$shims*")) {
        $env:PATH = "$shims;$env:PATH"
    }
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host 'scoop: installed but not on PATH in this process; open a new terminal and rerun.'
        exit 1
    }
}

function Install-ScoopPackage {
    param(
        [Parameter(Mandatory)][string[]]$Name,
        [hashtable]$Binary = @{}
    )

    foreach ($pkg in $Name) {
        $exe = $pkg
        if ($Binary.ContainsKey($pkg)) { $exe = $Binary[$pkg] }

        Write-Host "scoop package $pkg (provides $exe)"

        if (Get-Command $exe -ErrorAction SilentlyContinue) {
            Write-Host '  already on PATH'
            continue
        }

        scoop install $pkg
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  install failed (exit $LASTEXITCODE); continuing"
            continue
        }
        Write-Host '  installed'
    }

    $shims = Join-Path $env:USERPROFILE 'scoop\shims'
    if ((Test-Path -LiteralPath $shims) -and ($env:PATH -notlike "*$shims*")) {
        $env:PATH = "$shims;$env:PATH"
    }
}

function Set-UserEditor {
    param([Parameter(Mandatory)][string]$Editor)

    Write-Host "EDITOR -> $Editor"

    if (-not (Get-Command $Editor -ErrorAction SilentlyContinue)) {
        Write-Host "  skipped: $Editor is not on PATH"
        return
    }

    $current = [Environment]::GetEnvironmentVariable('EDITOR', 'User')
    if ($current -eq $Editor) {
        Write-Host '  already set'
    } else {
        [Environment]::SetEnvironmentVariable('EDITOR', $Editor, 'User')
        if ($current) {
            Write-Host "  set (was $current); open a new terminal to pick it up"
        } else {
            Write-Host '  set; open a new terminal to pick it up'
        }
    }

    $env:EDITOR = $Editor
}

Install-ScoopIfMissing
Install-ScoopPackage -Name @('neovim', 'delta', 'yazi', 'nodejs') -Binary @{ neovim = 'nvim'; nodejs = 'node' }
Set-UserEditor -Editor 'nvim'

$install = Join-Path $PSScriptRoot 'install.ps1'
if ($Gitconfig) {
    & $install -Gitconfig
} else {
    & $install
}
