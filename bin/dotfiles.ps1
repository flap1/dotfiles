#Requires -Version 5.1
# State of this repository on this machine. Same verbs as bin/dotfiles.

$ErrorActionPreference = 'Stop'

$Repo = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Split-Path -Parent $PSScriptRoot }
if ($env:LOCALAPPDATA) {
    $State = Join-Path $env:LOCALAPPDATA 'dotfiles'
} else {
    $xdg = if ($env:XDG_STATE_HOME) { $env:XDG_STATE_HOME } else { Join-Path $HOME '.local\state' }
    $State = Join-Path $xdg 'dotfiles'
}
$Stamp = Join-Path $State 'last-update-check'
$Manifest = Join-Path $State 'manifest'

function Write-Tinted {
    param(
        [ValidateSet('Red', 'Yellow', 'Green', 'DarkGray', 'Gray')]
        [string]$Color = 'Gray',
        [Parameter(Mandatory)][string]$Text
    )
    if ([Console]::IsOutputRedirected) {
        Write-Host $Text
    } else {
        Write-Host $Text -ForegroundColor $Color
    }
}

function Invoke-RepoGit {
    git -C $Repo @args
}

function Save-Stamp {
    New-Item -ItemType Directory -Path $State -Force | Out-Null
    Set-Content -LiteralPath $Stamp -Value ([DateTimeOffset]::Now.ToUnixTimeSeconds()) -NoNewline
}

function Get-FastForward {
    $script:Before = (Invoke-RepoGit rev-parse HEAD).Trim()
    Invoke-RepoGit pull --ff-only --quiet origin main
    if ($LASTEXITCODE -ne 0) { return $false }
    $script:After = (Invoke-RepoGit rev-parse HEAD).Trim()
    Save-Stamp
    return $true
}

function Show-Usage {
    @'
usage: dotfiles <command>

  status   what is out of sync, in both directions
  pull     fast-forward to origin/main (git only)
  update   pull, then apply (install.ps1 when linked or composed files moved)
  doctor   check that this machine still matches what install.ps1 installed
  check    quiet; prints one line if origin is ahead. For shell startup.
'@
}

function Invoke-Status {
    $dirty = @(Invoke-RepoGit status --porcelain | Where-Object { $_ }).Count
    Invoke-RepoGit fetch --quiet origin 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Tinted Yellow 'origin unreachable; counts are from the last fetch'
    }
    $counts = Invoke-RepoGit rev-list --left-right --count origin/main...HEAD 2>$null
    if (-not $counts) { $counts = '0 0' }
    $behind, $ahead = ($counts -split '\s+')[0, 1]
    if ($dirty -gt 0) { Write-Tinted Yellow "$dirty uncommitted file(s)" }
    if ([int]$ahead -gt 0) { Write-Tinted Yellow "$ahead commit(s) not pushed" }
    if ([int]$behind -gt 0) { Write-Tinted Red "$behind commit(s) on origin not pulled  -> dotfiles update" }
    if ($dirty -eq 0 -and [int]$ahead -eq 0 -and [int]$behind -eq 0) {
        Write-Tinted Green 'in sync with origin'
    }
}

function Invoke-Pull {
    if (-not (Get-FastForward)) {
        Write-Tinted Red 'not a fast-forward; resolve by hand'
        exit 1
    }
    if ($script:Before -eq $script:After) {
        Write-Tinted Green 'already up to date'
        return
    }
    $n = (Invoke-RepoGit rev-list --count "$($script:Before)..$($script:After)").Trim()
    Write-Tinted Green "pulled $n commit(s)"
}

function Test-Changed {
    param([string[]]$Files, [string]$Pattern)
    foreach ($f in $Files) {
        if ($f -match $Pattern) { return $true }
    }
    return $false
}

function Invoke-Apply {
    param([string]$Before, [string]$After)
    $files = @(Invoke-RepoGit diff --name-only $Before $After)

    # Keep in sync with bin/dotfiles cmd_apply.
    if (Test-Changed $files '^\.config/mise/') {
        Write-Tinted Yellow 'mise catalog changed -- Windows uses scoop; rerun .\bootstrap.ps1 if you want those tools'
    }

    if (Test-Changed $files '^(install\.sh|install\.ps1|lib/|\.claude/|\.cursor/|\.codex/|\.config/|\.zshenv$)') {
        Write-Tinted DarkGray 'installed files changed'
        & (Join-Path $Repo 'install.ps1')
    }

    if (Test-Changed $files '^packages/cursor-agent\.sh$') {
        Write-Tinted Yellow 'cursor-agent pin changed -- no hashed Windows package; see https://cursor.com/docs/cli/installation'
    }

    if (Test-Changed $files '^(bootstrap\.sh|bootstrap\.ps1|packages/(system|tmux|fonts)\.sh)') {
        Write-Tinted Yellow 'bootstrap files changed -- rerun .\bootstrap.ps1'
    }
}

function Invoke-Update {
    if (-not (Get-FastForward)) {
        Write-Tinted Red 'not a fast-forward; resolve by hand'
        exit 1
    }
    if ($script:Before -eq $script:After) {
        Write-Tinted Green 'already up to date'
        return
    }
    $n = (Invoke-RepoGit rev-list --count "$($script:Before)..$($script:After)").Trim()
    Write-Tinted Green "pulled $n commit(s)"
    Invoke-Apply -Before $script:Before -After $script:After
}

function Test-ComposedKey {
    param([string]$Live, [string]$Layer, [string]$Name)
    if (-not (Test-Path -LiteralPath $Live)) {
        Write-Tinted Yellow "  absent     $Name"
        return $false
    }
    $liveObj = Get-Content -LiteralPath $Live -Raw | ConvertFrom-Json
    $layerObj = Get-Content -LiteralPath $Layer -Raw | ConvertFrom-Json
    $drifted = @()
    foreach ($p in $layerObj.PSObject.Properties) {
        if ($p.Name -eq 'permissions') { continue }
        $left = $liveObj.$($p.Name) | ConvertTo-Json -Compress
        $right = $p.Value | ConvertTo-Json -Compress
        if ($left -ne $right) { $drifted += $p.Name }
    }
    if ($drifted.Count -gt 0) {
        Write-Tinted Yellow ("  drifted    {0}: {1} -- rerun .\install.ps1" -f $Name, ($drifted -join ','))
        return $false
    }
    Write-Tinted Green "  ok         $Name"
    return $true
}

function Invoke-Doctor {
    $problems = 0

    Write-Tinted DarkGray 'junctions'
    if (-not (Test-Path -LiteralPath $Manifest)) {
        Write-Tinted Yellow '  no manifest  run .\install.ps1 once to record what is installed'
        $problems++
    } else {
        foreach ($link in @(Get-Content -LiteralPath $Manifest | Where-Object { $_ })) {
            $item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
            if (-not $item) {
                Write-Tinted Yellow "  missing    $link"
                $problems++
            } elseif (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
                Write-Tinted Yellow "  replaced   $link"
                $problems++
            }
        }
        if ($problems -eq 0) {
            $n = @(Get-Content -LiteralPath $Manifest | Where-Object { $_ }).Count
            Write-Tinted Green "  ok         $n junction(s)"
        }
    }

    Write-Tinted DarkGray 'composed files'
    $claudeLive = Join-Path $env:USERPROFILE '.claude\settings.json'
    $claudeLayer = Join-Path $Repo '.claude\settings.json'
    if (-not (Test-ComposedKey $claudeLive $claudeLayer 'claude')) { $problems++ }

    $cursorLive = Join-Path $env:USERPROFILE '.cursor\cli-config.json'
    $cursorLayer = Join-Path $Repo '.cursor\cli-config.json'
    if (-not (Test-ComposedKey $cursorLive $cursorLayer 'cursor')) { $problems++ }

    Write-Tinted DarkGray 'vendored skills'
    $vendor = Join-Path $Repo '.claude\skills\VENDOR'
    if (-not (Test-Path -LiteralPath $vendor)) {
        Write-Tinted Yellow '  absent     no VENDOR manifest'
        $problems++
    } else {
        $missing = $false
        foreach ($line in @(Get-Content -LiteralPath $vendor)) {
            if ($line -match '^\s*#' -or $line -notmatch '\S') { continue }
            $name = ($line -split '\t')[0]
            $dir = Join-Path $Repo ".claude\skills\$name"
            if (-not (Test-Path -LiteralPath $dir)) {
                Write-Tinted Yellow "  missing    $name -- npx skills update -g"
                $missing = $true
            }
        }
        if (-not $missing) {
            Write-Tinted Green '  ok         vendored'
        }
    }

    Write-Host ''
    if ($problems -eq 0) { Write-Tinted Green 'no problems found' }
    else { Write-Tinted Yellow "$problems problem(s)" }
}

function Invoke-Check {
    $now = [DateTimeOffset]::Now.ToUnixTimeSeconds()
    $last = 0
    if (Test-Path -LiteralPath $Stamp) {
        $raw = Get-Content -LiteralPath $Stamp -Raw
        [void][int]::TryParse($raw, [ref]$last)
    }
    if (($now - $last) -lt 86400) { return }

    Invoke-RepoGit fetch --quiet origin 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { return }
    Save-Stamp
    $behind = (Invoke-RepoGit rev-list --count 'HEAD..origin/main' 2>$null)
    if (-not $behind) { $behind = '0' }
    if ([int]$behind -gt 0) {
        Write-Tinted Yellow "dotfiles: $behind commit(s) on origin  -> dotfiles update"
    }
}

$cmd = $args[0]
switch ($cmd) {
    'status' { Invoke-Status }
    'pull' { Invoke-Pull }
    'update' { Invoke-Update }
    'doctor' { Invoke-Doctor }
    'check' { Invoke-Check }
    { $_ -in @('-h', '--help', 'help', $null, '') } { Show-Usage }
    default {
        Write-Host "unknown command: $cmd"
        Show-Usage
        exit 1
    }
}
