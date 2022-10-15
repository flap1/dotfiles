$ENV:Path+=";$($env:ProgramFiles)\nvim\bin"
$ENV:ComSpec+=";$($env:ProgramFiles)\PowerShell\7\pwsh.exe"
$ENV:Profile="C:\PowerShell\Microsoft.PowerShell_profile.ps1"
$ENV:XDG_CONFIG_HOME="$($env:UserProfile)\.config"

Set-Alias vim nvim
Set-Alias vi nvim
Set-Alias v nvim

oh-my-posh init pwsh --config ~/.config/posh/oh-my-posh/themes/powerlevel10k_lean.omp.json | Invoke-Expression
