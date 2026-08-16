#Requires -Version 7
$ErrorActionPreference = 'Stop'
$root = git rev-parse --show-toplevel
Set-Location $root
$fail = $false
foreach ($f in @('bootstrap.ps1', 'install.ps1', '.config/paste-shot/setup.ps1')) {
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
