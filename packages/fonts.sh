#!/bin/bash
# nvim names UDEV Gothic NFLG (Nerd Font, ligatures, half:full = 1:2).
# The "35" cut is 3:5. Latin is wider than two columns. Do not install it.
# No Windows core fonts: that installer is an EULA prompt and not this face.

set -euo pipefail

dir="$HOME/.local/share/fonts"
mkdir -p "$dir"

if [ ! -f "$dir/UDEVGothicNFLG-Regular.ttf" ]; then
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/udev.zip" \
        https://github.com/yuru7/udev-gothic/releases/download/v2.2.0/UDEVGothic_NF_v2.2.0.zip
    echo "45faeef7b5d8bc591bcc5887a2ca0c5fb9028066f18a5a52cd6f10b7d655ba37  $tmp/udev.zip" |
        sha256sum -c --strict
    unzip -q "$tmp/udev.zip" -d "$tmp"
    find "$tmp" -name 'UDEVGothicNFLG-*.ttf' -exec mv {} "$dir/" \;
    rm -r "$tmp"
fi

fc-cache -f >/dev/null
