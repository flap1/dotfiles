#!/bin/bash
# The font nvim names (UDEV Gothic). No Windows core fonts: that installer
# is an EULA prompt and not what the terminal uses.

set -euo pipefail

dir="$HOME/.local/share/fonts"
mkdir -p "$dir"

if [ ! -f "$dir/UDEVGothicNF-Regular.ttf" ]; then
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/udev.zip" \
        https://github.com/yuru7/udev-gothic/releases/download/v1.3.1/UDEVGothic_NF_v1.3.1.zip
    echo "84004a3038bdf528286a113b4db076d8412bb4ca6771d02a240318473f9b9fce  $tmp/udev.zip" |
        sha256sum -c --strict
    unzip -q "$tmp/udev.zip" -d "$tmp"
    find "$tmp" -name 'UDEVGothicNF-*.ttf' -exec mv {} "$dir/" \;
    rm -r "$tmp"
fi

fc-cache -f >/dev/null
