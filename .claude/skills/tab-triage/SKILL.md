---
name: tab-triage
description: Take stock of every open Chrome tab and propose what to close and how to group the rest. Use when asked what is open, why there are so many tabs, to clean up or organise tabs, or to find duplicates. Windows + Chrome, via the `ctab` CLI.
---

## Tab triage

Report what is open, then propose closures and groupings. **Never close or
regroup anything before the user picks from the proposal.** `Ctrl+Shift+T`
undoes one close, which is no help after a batch.

### Survey

```bash
ctab health                 # abort and report if this fails
ctab --json list            # the working set
ctab dupes                  # exact-URL repeats
ctab groups                 # existing structure, often empty
```

If `ctab health` reports the host is down, say so and stop. The usual causes:
Chrome is not running, the extension is disabled, or the MV3 service worker was
torn down (a 30s alarm revives it — retry once before concluding anything).

### Judge from titles and URLs first

This is normally enough, and it costs nothing. Sort candidates into:

- **Exact duplicates** — straight from `ctab dupes`. Say which one survives and
  why (pinned > active > leftmost is what `ctab dedupe` would do).
- **Near duplicates** — `ctab dupes` compares whole URLs, so the same page still
  shows up twice when a tracking or preview parameter differs (`?via=…`,
  Google's `rlz=`/`gs_lcrp=`, `utm_*`). Compare paths yourself.
- **Dead pages** — titles like "Page not found", "503", "Sign in", "Service
  Unavailable"; `status` other than `complete`.
- **Spent lookups** — search-result pages, status/outage checks, store listings,
  docs for a decision already made.
- **Keep** — the active tab, anything pinned or audible, local dev servers,
  conversations and documents with real titles, open PRs.

Present the closures as a table of id → reason, then one `ctab close` line
holding every id, so the user can delete the ids they disagree with and run it.

### When titles are not enough

`ctab read ID` extracts a page's text, but only after page reading is turned on
from the ctab toolbar icon — Chrome accepts that grant from a click, never from
the CLI. Check with `ctab perms`.

Use it sparingly and say why a given tab needs it. **Anything read leaves the
browser and enters the conversation**, so never read a tab that looks like mail,
calendar, banking, or an internal admin page just to decide whether it is stale;
its title already tells you it is not disposable. `ctab revoke` turns reading
back off, and that one does work from the CLI.

### Then propose structure

Tabs sprawl because nothing groups them, not because there are too many. After
the closures, propose groups over what is left:

- `openerTabId` in the JSON says which tab spawned which. That reconstructs the
  chain a piece of research actually followed and beats grouping by domain.
- Otherwise cluster by site, by project, or by `file://` origin.
- Aim for a handful of groups with plain names. Suggest a colour per group.

```bash
ctab group ID ID ID --title "name" --color blue
ctab group-update G --collapsed
```

Colours: grey, blue, red, yellow, green, pink, purple, cyan, orange.

### Do not

- Do not trust the age column right after a Chrome restart. Restoring a session
  stamps every tab as just-accessed, so `sweep-stale` and any "untouched for
  days" reasoning are meaningless until the timestamps have aged.
- Do not propose `ctab dedupe` as the first move when duplicates carry different
  state (two Gmail views, two of the same dev server where one failed to load).
  Pick the survivor deliberately instead.
- Do not suggest Vimium-style single-key bindings. They stop working the moment
  a page takes keyboard focus. Chrome's own `Ctrl+Tab`, `Ctrl+1`–`8`,
  `Ctrl+Shift+PgUp`/`PgDn` and `Ctrl+Shift+A` are modifier-based and always fire,
  and ctab's shortcuts go through `chrome.commands` for the same reason.
