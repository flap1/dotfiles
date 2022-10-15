@echo off

set DOT_DIRS=.config\wezterm .config\posh .config\nvim
for %%d in (%DOT_DIRS%) do (
	if exist %UserProfile%\%%d (
		rd /s %UserProfile%\%%d
	) 
	mklink /d %UserProfile%\%%d %UserProfile%\dotfiles\%%d
)

if exist C:\Powershell (
	rd C:\Powershell
)
mklink /d C:\Powershell %UserProfile%\dotfiles\.config\posh

if exist %UserProfile%\.gitconfig (
	del %UserProfile%\.gitconfig
)
mklink /h %UserProfile%\.gitconfig %UserProfile%\dotfiles\.config\git\.gitconfig
