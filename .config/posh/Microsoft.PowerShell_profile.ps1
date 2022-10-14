$ENV:Path+=";C:\Program Files\nvim\bin"
$ENV:ComSpec+=";C:\Program Files\PowerShell\7\pwsh.exe"
$ENV:Profile="C:\PowerShell\Microsoft.PowerShell_profile.ps1"

Set-Alias vim nvim
Set-Alias vi nvim
Set-Alias v nvim

oh-my-posh init pwsh --config './oh-my-posh/themes/powerlevel10k_lean.omp.json' | Invoke-Expression
