#Requires -Version 5.1

<#
.SYNOPSIS
    Install UDEV Gothic NFLG for the current user.

.DESCRIPTION
    Same face as nvim's guifont. Half:full = 1:2.
    The "35" cut is 3:5, so Latin is wider than two columns. That face is not installed.
#>

$ErrorActionPreference = 'Stop'

$version = 'v2.2.0'
$url = "https://github.com/yuru7/udev-gothic/releases/download/$version/UDEVGothic_NF_$version.zip"
$sha256 = '45FAEEF7B5D8BC591BCC5887A2CA0C5FB9028066F18A5A52CD6F10B7D655BA37'
$fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$marker = Join-Path $fontDir 'UDEVGothicNFLG-Regular.ttf'

$faces = [ordered]@{
    'UDEVGothicNFLG-Regular.ttf'    = 'UDEV Gothic NFLG Regular (TrueType)'
    'UDEVGothicNFLG-Bold.ttf'       = 'UDEV Gothic NFLG Bold (TrueType)'
    'UDEVGothicNFLG-Italic.ttf'     = 'UDEV Gothic NFLG Italic (TrueType)'
    'UDEVGothicNFLG-BoldItalic.ttf' = 'UDEV Gothic NFLG BoldItalic (TrueType)'
}

New-Item -ItemType Directory -Path $fontDir -Force | Out-Null

if (-not (Test-Path -LiteralPath $marker)) {
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ("udev-gothic-" + [guid]::NewGuid().ToString('n'))
    New-Item -ItemType Directory -Path $tmp | Out-Null
    try {
        $zip = Join-Path $tmp 'udev.zip'
        Write-Host "download $url"
        Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
        $got = (Get-FileHash -Algorithm SHA256 -LiteralPath $zip).Hash
        if ($got -ne $sha256) {
            throw "sha256 mismatch: $got"
        }
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $archive = [IO.Compression.ZipFile]::OpenRead($zip)
        try {
            foreach ($entry in $archive.Entries) {
                $name = [IO.Path]::GetFileName($entry.FullName)
                if (-not $faces.Contains($name)) { continue }
                $dest = Join-Path $fontDir $name
                [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
            }
        } finally {
            $archive.Dispose()
        }
    } finally {
        Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$missing = @($faces.Keys | Where-Object { -not (Test-Path -LiteralPath (Join-Path $fontDir $_)) })
if ($missing.Count -gt 0) {
    throw "font extract missed: $($missing -join ', ')"
}

$reg = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
foreach ($name in $faces.Keys) {
    $path = Join-Path $fontDir $name
    New-ItemProperty -Path $reg -Name $faces[$name] -Value $path -PropertyType String -Force | Out-Null
}

Write-Host "UDEV Gothic NFLG -> $fontDir"

Add-Type -Namespace Win32 -Name FontNotify -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("gdi32.dll", CharSet = System.Runtime.InteropServices.CharSet.Unicode)]
public static extern int AddFontResourceW(string lpszFilename);
[System.Runtime.InteropServices.DllImport("user32.dll", CharSet = System.Runtime.InteropServices.CharSet.Auto)]
public static extern System.IntPtr SendMessage(System.IntPtr hWnd, uint Msg, System.IntPtr wParam, System.IntPtr lParam);
'@
foreach ($name in $faces.Keys) {
    [Win32.FontNotify]::AddFontResourceW((Join-Path $fontDir $name)) | Out-Null
}
[Win32.FontNotify]::SendMessage([IntPtr]0xffff, 0x001D, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
