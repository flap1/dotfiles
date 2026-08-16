#!/usr/bin/env bash
# Fail if the tree carries a state this repository has ruled out.
# Run from the repository root. No network.

set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
fail=0

while IFS= read -r path || [ -n "$path" ]; do
    case "$path" in
        '' | \#*) continue ;;
    esac
    if git ls-files --error-unmatch "$path" >/dev/null 2>&1; then
        echo "tracked but retired: $path"
        fail=1
    fi
done <scripts/retired-paths.txt

if git grep -qE '\bzinit\b' -- ':!scripts/policy.sh'; then
    echo "zinit must not remain in tracked files"
    fail=1
fi

if git grep -q 'approvalMode.: .unrestricted' -- .cursor/cli-config.json; then
    echo "Cursor approvalMode unrestricted must not be in the shared config"
    fail=1
fi

if git grep -q 'Bash(git push' -- .claude/settings.json; then
    echo "git push must not be allowed in the shared Claude settings"
    fail=1
fi

if git grep -qE '95\.216\.27\.150' -- .; then
    echo "CI host address must not be tracked"
    fail=1
fi

if git grep -qE '^[[:space:]]*hooksPath[[:space:]]*=' -- .config/git/.gitconfig; then
    echo "core.hooksPath must not be set in the shared gitconfig"
    fail=1
fi

if git ls-files '.claude/skills/hallmark/**' | grep -q .; then
    echo "vendored hallmark is tracked; it belongs in gitignore"
    fail=1
fi

if git grep -qE "alias[[:space:]]+(cat|less|df|ps|top|mkdir)=" -- .config/zsh; then
    echo "aliases must not shadow Unix verbs whose grammar they do not keep"
    fail=1
fi

if git grep -qE '\bgdrive\b' -- ':!.claude/skills/**' ':!scripts/policy.sh'; then
    echo "machine-local path gdrive must not be in tracked files"
    fail=1
fi

if git grep -q 'mise.run' -- ':!scripts/policy.sh'; then
    echo "mise must not be installed by piping mise.run to a shell"
    fail=1
fi

if git grep -qiE '\bsyntopic\b' -- ':!scripts/policy.sh' ':!scripts/retired-paths.txt'; then
    echo "employer/project host names must not be in tracked files"
    fail=1
fi

# Every tracked .config/<name> is either linked by install.sh or an optional
# add-on with its own setup script.
python3 - <<'PY' || fail=1
import pathlib, subprocess, sys
root = pathlib.Path(".")
install = (root / "install.sh").read_text()
allow = {"paste-shot"}
dirs = set()
for f in subprocess.check_output(["git", "ls-files", ".config"], text=True).splitlines():
    parts = pathlib.Path(f).parts
    if len(parts) >= 2:
        dirs.add(parts[1])
missing = sorted(d for d in dirs if d not in allow and d not in install)
if missing:
    print("tracked .config dirs not named in install.sh:", ", ".join(missing))
    sys.exit(1)
PY

cjk=$(
    python3 - <<'PY'
import pathlib, re, subprocess
root = pathlib.Path(".")
pat = re.compile(r"[\u3040-\u30ff\u3400-\u9fff]")
allow = {".config/nvim/lua/core/keymaps.lua"}
files = subprocess.check_output(["git", "ls-files"], text=True).splitlines()
hits = []
for f in files:
    if f in allow:
        continue
    p = root / f
    try:
        text = p.read_text(encoding="utf-8")
    except (UnicodeDecodeError, IsADirectoryError, FileNotFoundError, OSError):
        continue
    if pat.search(text):
        hits.append(f)
print("\n".join(hits))
PY
)
if [ -n "$cjk" ]; then
    echo "CJK in tracked files (not allowed except nvim IME maps):"
    echo "$cjk"
    fail=1
fi

exit "$fail"
