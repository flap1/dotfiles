#!/bin/bash
# Mirror Claude skills into ~/.cursor/skills so Cursor Agent sees the same
# trees. Personal skills, npx-installed agent skills, and plugin skills.
# Dest is a directory of symlinks, not one symlink: a user-authored Cursor
# skill beside them must keep working. Sourced from install.sh.
#
# Slash names Claude users type (/memo-ja, /humanize-ja) are not plugin
# folders. When natural-japanese is present, install writes thin English
# aliases so those names show up in Cursor's skill picker.

cursor_skills_dir() {
    printf '%s\n' "$HOME/.cursor/skills"
}

cursor_skills_from_dir() {
    local root=$1 dir name
    [ -d "$root" ] || return 0
    for dir in "$root"/*/; do
        [ -f "${dir}SKILL.md" ] || continue
        name=$(basename "$dir")
        printf '%s\t%s\n' "$name" "$(realpath "$dir")"
    done
}

cursor_skills_from_plugins() {
    command -v node >/dev/null || return 0
    [ -f "$HOME/.claude/plugins/installed_plugins.json" ] || return 0
    HOME="$HOME" node -e '
const fs = require("fs");
const path = require("path");
const p = path.join(process.env.HOME, ".claude/plugins/installed_plugins.json");
const j = JSON.parse(fs.readFileSync(p, "utf8"));
for (const arr of Object.values(j.plugins || {})) {
  if (!Array.isArray(arr) || arr.length === 0) continue;
  const root = arr[arr.length - 1].installPath;
  if (!root) continue;
  const skills = path.join(root, "skills");
  let names;
  try { names = fs.readdirSync(skills); } catch { continue; }
  for (const name of names) {
    const dir = path.join(skills, name);
    if (fs.existsSync(path.join(dir, "SKILL.md"))) {
      process.stdout.write(name + "\t" + fs.realpathSync(dir) + "\n");
    }
  }
}
' || true
}

# name<TAB>absolute-dir. Later rows win: plugins, then ~/.agents, then personal.
cursor_skills_wanted() {
    cursor_skills_from_plugins
    cursor_skills_from_dir "$HOME/.agents/skills"
    cursor_skills_from_dir "$HOME/.claude/skills"
}

write_cursor_skill_alias() {
    local dest=$1 name=$2 file dir
    dir="$dest/$name"
    file="$dir/SKILL.md"
    if [ -e "$dir" ] && [ ! -f "$dir/.dotfiles-alias" ]; then
        echo "  skip $dir (not an alias)"
        return 0
    fi
    mkdir -p "$dir"
    cat >"$file"
    : >"$dir/.dotfiles-alias"
}

sync_cursor_skill_aliases() {
    local dest=$1
    shift
    local -A have=()
    local name dir nj=natural-japanese

    for name in "$@"; do
        have["$name"]=1
    done
    if [ -z "${have[$nj]+x}" ]; then
        for dir in "$dest"/*/; do
            [ -f "${dir}.dotfiles-alias" ] || continue
            unlink "${dir}SKILL.md" 2>/dev/null || true
            unlink "${dir}.dotfiles-alias"
            rmdir "$dir" 2>/dev/null || true
        done
        return 0
    fi

    write_cursor_skill_alias "$dest" memo-ja <<'EOF'
---
name: memo-ja
description: Japanese research memo or discussion paper. Use when the user says memo-ja, asks for a research memo, or wants a discussion paper in Japanese.
---

Entry point for the natural-japanese memo doctype.

1. Read the `natural-japanese` skill, then `references/doctypes/memo.md`.
2. Quick mode unless the user asks for full.
3. Write in Japanese. Put the claim in the title and first sentence. State what this memo should decide. Label open questions and give a provisional stance on each.
EOF

    write_cursor_skill_alias "$dest" humanize-ja <<'EOF'
---
name: humanize-ja
description: Rewrite Japanese prose so it does not read as LLM output. Use when the user says humanize-ja, that text sounds like AI, or asks to strip AI-smelling Japanese.
---

Entry point for natural-japanese as a rewrite pass, not a new document type.

1. Read the `natural-japanese` skill. Prefer write/rewrite over score unless the user only wants a diagnosis.
2. Quick mode unless the user asks for full.
3. Run the lint script the skill names. Fix tells (borrowed metaphor, even sentence length, stacked headings-plus-bullets, trailing "which shows that"). Do not shorten for its own sake.
EOF

    write_cursor_skill_alias "$dest" minutes-ja <<'EOF'
---
name: minutes-ja
description: Japanese meeting minutes, including from a transcript. Use when the user says minutes-ja or asks for minutes in Japanese.
---

Read `natural-japanese` and `references/doctypes/minutes.md`. Quick mode unless asked for full. Write in Japanese.
EOF

    write_cursor_skill_alias "$dest" report-ja <<'EOF'
---
name: report-ja
description: Japanese investigation or analysis report. Use when the user says report-ja or asks for a survey report in Japanese.
---

Read `natural-japanese` and `references/doctypes/report.md`. Quick mode unless asked for full. Write in Japanese.
EOF

    write_cursor_skill_alias "$dest" guide-ja <<'EOF'
---
name: guide-ja
description: Japanese internal guide or manual. Use when the user says guide-ja or asks for an internal guide in Japanese.
---

Read `natural-japanese` and `references/doctypes/guide.md`. Quick mode unless asked for full. Write in Japanese.
EOF

    write_cursor_skill_alias "$dest" slide-ja <<'EOF'
---
name: slide-ja
description: Japanese slide outline. Use when the user says slide-ja or asks for a slide outline in Japanese.
---

Read `natural-japanese` and `references/doctypes/slide.md`. Quick mode unless asked for full. Write in Japanese.
EOF
}

sync_cursor_skills() {
    local dest name target link current
    local -A want=()
    dest=$(cursor_skills_dir)
    mkdir -p "$dest"

    while IFS=$'\t' read -r name target; do
        [ -n "$name" ] || continue
        want["$name"]=$target
    done < <(cursor_skills_wanted)

    for name in "${!want[@]}"; do
        target=${want[$name]}
        link="$dest/$name"
        if [ -L "$link" ]; then
            current=$(readlink "$link")
            if [ "$current" = "$target" ]; then
                continue
            fi
            unlink "$link"
        elif [ -e "$link" ]; then
            echo "  skip $link (not a symlink)"
            continue
        fi
        ln -s "$target" "$link"
        echo "  -> $link"
    done

    sync_cursor_skill_aliases "$dest" "${!want[@]}"

    for link in "$dest"/*; do
        [ -L "$link" ] || continue
        name=$(basename "$link")
        if [ -n "${want[$name]+x}" ]; then
            continue
        fi
        current=$(readlink "$link")
        case $current in
            "$HOME/.claude/skills"/* | "$HOME/.claude/plugins"/* | "$HOME/.agents/skills"/*) ;;
            *) continue ;;
        esac
        unlink "$link"
        echo "  removed stale $link"
    done
}
