#Requires -Version 5.1

<#
.SYNOPSIS
    One entry point for a Windows machine with nothing on it.

.DESCRIPTION
    Installs Git and mise with winget, installs the pinned mise toolset, then
    runs install.ps1. Already set up? .\install.ps1 alone.

.EXAMPLE
    .\bootstrap.ps1
#>

[CmdletBinding()]
param(
    [switch]$Gitconfig
)

$ErrorActionPreference = 'Stop'

$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -eq 'Restricted' -or $policy -eq 'Undefined') {
    Write-Host 'ExecutionPolicy CurrentUser -> RemoteSigned'
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
}

function Install-WingetPackage {
    param([Parameter(Mandatory)][string]$Id)

    winget list --id $Id -e --accept-source-agreements | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "winget package ${Id}: already installed"
        return
    }
    winget install --id $Id -e --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) { throw "winget install failed: $Id" }
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

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget is required (install App Installer from Microsoft Store)'
}

Install-WingetPackage -Id 'Git.Git'
Install-WingetPackage -Id 'jdx.mise'
# Desktop apps have no mise backend, so winget is the source.
Install-WingetPackage -Id 'Google.GoogleDrive'

# winget changes the persistent PATH, not this process.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$env:PATH = "$userPath;$machinePath"
if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
    throw 'mise was installed but is not on PATH; open a new terminal and rerun'
}

$miseConfig = Join-Path $PSScriptRoot '.config\mise'
mise trust $miseConfig
mise -C $miseConfig install
if ($LASTEXITCODE -ne 0) { throw 'mise install failed' }

$miseShims = Join-Path $env:LOCALAPPDATA 'mise\shims'
if (($userPath -split ';') -notcontains $miseShims) {
    [Environment]::SetEnvironmentVariable('Path', "$miseShims;$userPath", 'User')
}
$env:PATH = "$miseShims;$env:PATH"
Set-UserEditor -Editor 'nvim'

# install.ps1 composes ~/.claude/settings.json (statusline, usage gauges) with
# node and skips quietly without it, so a missing node has to stop here.
if (-not (Get-Command node.exe -ErrorAction SilentlyContinue)) {
    throw 'node is not on PATH after mise install; the Claude settings would be skipped'
}

function Install-AgentCli {
    Write-Host 'Cursor CLI (agent)'
    if (Get-Command agent -ErrorAction SilentlyContinue) {
        Write-Host '  already on PATH'
    } else {
        # The Windows tarball is not a public hashed URL (403). The vendor
        # path is irm | iex, which this repository does not run.
        Write-Host '  skipped: no hashed Windows package; see https://cursor.com/docs/cli/installation'
    }
}

Install-AgentCli

& (Join-Path $PSScriptRoot 'packages\fonts.ps1')

$install = Join-Path $PSScriptRoot 'install.ps1'
if ($Gitconfig) {
    & $install -Gitconfig
} else {
    & $install
}

$claudeSettings = Join-Path $env:USERPROFILE '.claude\settings.json'
$wired = (Test-Path -LiteralPath $claudeSettings) -and
    ((Get-Content -LiteralPath $claudeSettings -Raw) -match '"statusLine"')
if (-not $wired) { throw "statusLine is missing from $claudeSettings; rerun .\install.ps1" }
Write-Host 'Claude statusline: wired'
