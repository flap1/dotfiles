#!/usr/bin/env bash
# Parse the PowerShell entry points. Needs pwsh.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
exec pwsh -NoProfile -File "$root/scripts/ci-pwsh.ps1"
