@echo off

set DOT_DIRS=.config\wezterm .config\posh
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
