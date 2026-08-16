# Sourced from the user's PowerShell profile (a one-line hook install.ps1 writes).
# Same job as the zsh post_load `dotfiles check &`: at most one fetch a day.
$cli = Join-Path $PSScriptRoot '..\..\bin\dotfiles.ps1'
if (-not (Test-Path -LiteralPath $cli)) { return }
& $cli check
