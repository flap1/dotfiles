#!/usr/bin/env bash
# Full-history secret scan. Same binary lefthook uses (mise gitleaks).
# Run from the repository root.

set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"

gitleaks detect --source . --verbose --redact --no-banner
