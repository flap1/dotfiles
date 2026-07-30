#Requires -Version 5.1

<#
.SYNOPSIS
    Send the clipboard image to the paste-shot receiver on the remote box.

.DESCRIPTION
    Called by paste-shot.ahk, and usable on its own for debugging. The receiver
    is reached through a port the ssh session already forwards, so this opens no
    connection of its own -- see .config/paste-shot/README.md for why that
    matters (scp measured 1785ms per paste through the cloudflared jump; this
    measured 133-206ms, and the caller does not wait for it at all).

    Nothing here touches the clipboard beyond reading it. The path is typed by
    the caller with SendText, so a screenshot stays pasteable into Slack after
    it has been handed to Claude.

.PARAMETER Name
    Destination file name. Must match yyyyMMdd-HHmmss-fff.png -- the receiver
    rejects anything else, because the caller has already typed this name into
    the prompt and a mismatch would leave Claude reading a path that never
    appears.

.PARAMETER Port
    Local end of the forward. Matches the LocalForward in ~/.ssh/config.

.EXAMPLE
    # Snip something with Win+Shift+S first, then:
    powershell -NoProfile -File paste-shot.ps1 -Name 20260730-143012-001.png
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^\d{8}-\d{6}-\d{3}\.png$')]
    [string]$Name,

    [int]$Port = 47291
)

$ErrorActionPreference = 'Stop'

# Exit codes are the contract with the caller and with anyone testing by hand.
#   0 sent   1 no image on the clipboard   2 receiver unreachable   3 rejected
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$image = [Windows.Forms.Clipboard]::GetImage()
if (-not $image) {
    # Not an error worth reporting: a text Ctrl+V lands here too, and the caller
    # falls through to a normal paste.
    exit 1
}

$buffer = New-Object IO.MemoryStream
try {
    $image.Save($buffer, [Drawing.Imaging.ImageFormat]::Png)
    $bytes = $buffer.ToArray()
} finally {
    $buffer.Dispose()
    $image.Dispose()
}

# Written by hand rather than with Invoke-WebRequest. IWR on 5.1 spends more
# time initialising than this whole transfer takes, and it insists on parsing
# the response as a document unless told otherwise. This is a POST with a known
# length to a loopback port; there is nothing to negotiate.
$client = New-Object Net.Sockets.TcpClient
try {
    $client.Connect('127.0.0.1', $Port)
} catch {
    # The forward is only up while an ssh session is. Refused instantly rather
    # than hanging, which is the whole point of not opening our own connection.
    [Console]::Error.WriteLine("paste-shot: no receiver on 127.0.0.1:$Port (is the ssh session up?)")
    exit 2
}

try {
    $stream = $client.GetStream()
    $header = "POST /$Name HTTP/1.1`r`n" +
              "Host: 127.0.0.1`r`n" +
              "Content-Type: image/png`r`n" +
              "Content-Length: $($bytes.Length)`r`n" +
              "Connection: close`r`n`r`n"
    $headerBytes = [Text.Encoding]::ASCII.GetBytes($header)
    $stream.Write($headerBytes, 0, $headerBytes.Length)
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Flush()

    $reader = New-Object IO.StreamReader($stream, [Text.Encoding]::ASCII)
    $statusLine = $reader.ReadLine()
} finally {
    $client.Close()
}

if ($statusLine -notmatch '^HTTP/1\.\d 200') {
    [Console]::Error.WriteLine("paste-shot: receiver said: $statusLine")
    exit 3
}

exit 0
