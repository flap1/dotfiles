#Requires -Version 7
$ErrorActionPreference = 'Stop'
$root = (git rev-parse --show-toplevel).Trim()
Set-Location $root
$fail = $false

$parse = @(
    'bootstrap.ps1',
    'install.ps1',
    'bin/dotfiles.ps1',
    '.config/powershell/profile.ps1',
    '.config/paste-shot/setup.ps1'
)
foreach ($f in $parse) {
    Write-Host "parse $f"
    $errs = $null
    $path = Join-Path $root $f
    [void][System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$errs)
    if ($errs) {
        $errs | ForEach-Object { Write-Host $_ }
        $fail = $true
    }
}
if ($fail) { exit 1 }

# Same contract as scripts/ci-dotfiles.sh, against bin/dotfiles.ps1.
$tmp = Join-Path ([IO.Path]::GetTempPath()) ('dotfiles-pwsh-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    $src = Join-Path $tmp 'src'
    New-Item -ItemType Directory -Path $src | Out-Null
    git -C $root ls-files | ForEach-Object {
        $dest = Join-Path $src $_
        $parent = Split-Path $dest -Parent
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        $from = Join-Path $root $_
        if (Test-Path -LiteralPath $from) {
            Copy-Item -LiteralPath $from -Destination $dest
        }
    }

    git -C $src init --quiet -b main
    git -C $src config user.email ci@example.com
    git -C $src config user.name ci
    git -C $src add -A
    git -C $src commit --quiet -m seed

    $origin = Join-Path $tmp 'origin.git'
    git clone --quiet --bare $src $origin
    $dot = Join-Path $tmp 'dotfiles'
    git clone --quiet $origin $dot

    $env:DOTFILES_DIR = $dot
    $env:LOCALAPPDATA = Join-Path $tmp 'appdata'
    New-Item -ItemType Directory -Path $env:LOCALAPPDATA | Out-Null
    $cli = Join-Path $dot 'bin\dotfiles.ps1'

    $out = & $cli update | Out-String
    if ($out -notmatch 'already up to date') {
        Write-Host "update on a current clone did not say already up to date:`n$out"
        exit 1
    }

    git -C $dot remote set-url origin (Join-Path $tmp 'missing.git')
    $stamp = Join-Path $env:LOCALAPPDATA 'dotfiles\last-update-check'
    if (Test-Path -LiteralPath $stamp) { Remove-Item -LiteralPath $stamp }
    & $cli check
    if (Test-Path -LiteralPath $stamp) {
        Write-Host 'check stamped after a failed fetch'
        exit 1
    }
    git -C $dot remote set-url origin $origin

    $push = Join-Path $tmp 'push'
    git clone --quiet $origin $push
    git -C $push config user.email ci@example.com
    git -C $push config user.name ci
    Add-Content -LiteralPath (Join-Path $push 'README.md') -Value 'extra'
    git -C $push add README.md
    git -C $push commit --quiet -m 'ci: origin ahead'
    git -C $push push --quiet origin HEAD:main

    if (Test-Path -LiteralPath $stamp) { Remove-Item -LiteralPath $stamp }
    $msg = & $cli check | Out-String
    if ($msg -notmatch 'dotfiles update') {
        Write-Host "check did not hint update:`n$msg"
        exit 1
    }

    $out = & $cli update | Out-String
    if ($out -notmatch 'pulled 1 commit') {
        Write-Host "update did not pull:`n$out"
        exit 1
    }
    if ($out -match 'installed files changed') {
        Write-Host "README-only commit reran install.ps1:`n$out"
        exit 1
    }
} finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host 'ok'
