#!/usr/bin/env node
// Claude Code status line. One process.
//
// This replaces statusline-command.sh, which was correct but cost 2.2s per
// render on Windows against 0.1s on Linux. The difference was not the shell:
// the script shelled out about twenty times per render -- fourteen jq calls,
// five git calls, plus tr, awk, sed, date -- and every process launched through
// the MSYS2 runtime pays roughly 100ms because POSIX fork() has to be emulated.
// Measured there: jq 84ms, git 131ms, node 84ms, bash 144ms. No other POSIX
// layer on Windows avoids that; BusyBox-w32 lowers the per-process cost but
// twenty launches is still twenty launches.
//
// So the fix is to stop spawning. This is one node process plus one git, and
// the git call is `status --porcelain=v2 --branch`, which answers in a single
// invocation what took five before.
//
// Rewriting it in JS also deletes a whole class of bug rather than the four
// instances of it that were actually found. Every Windows-only failure in that
// script came from shelling out: /bin/sh under Git Bash is bash in POSIX mode,
// where `echo` expands backslash escapes, so a Windows path reached jq with
// C:\Users turned into C:Users; `printf '%b'` did the same to the finished
// line; `rev` does not exist there at all; and ${cwd#$HOME} never matched
// because current_dir is C:\Users\name while $HOME is /c/Users/name. None of
// those can happen here.
//
// The display is unchanged. Output was compared byte for byte against the shell
// version on both platforms before the switch.

import { readFileSync, writeFileSync } from 'node:fs'
import { execFileSync } from 'node:child_process'
import { homedir } from 'node:os'
import { join } from 'node:path'

const HOME = homedir()

// ---------------------------------------------------------------- input

let data = {}
try {
  data = JSON.parse(readFileSync(0, 'utf8'))
} catch {
  // No payload, or not JSON. A status line that throws leaves the bar empty
  // with the reason buried in a log nobody reads, so say nothing and exit clean.
  process.exit(0)
}

const get = (path, fallback = undefined) =>
  path.split('.').reduce((o, k) => (o == null ? undefined : o[k]), data) ?? fallback

// ------------------------------------------------- rate limit side channel

// The statusline payload is the only place the rate limits are exposed, and
// only a live session receives it. Leave the latest copy where claude-ls can
// read it.
try {
  writeFileSync(
    join(HOME, '.cache', 'claude-rate-limits.json'),
    JSON.stringify({
      five_hour: get('rate_limits.five_hour', null),
      seven_day: get('rate_limits.seven_day', null),
    })
  )
} catch {
  // ~/.cache may not exist yet on a fresh box. Not worth a render for.
}

// ---------------------------------------------------------------- directory

const rawCwd = get('workspace.current_dir') || get('cwd') || ''

// Windows reports current_dir as C:\Users\name\... -- backslashes, and a drive
// letter -- while the home directory node reports is C:\Users\name too. Compare
// on one separator so both platforms take the same path through this.
const norm = (p) => p.replace(/\\/g, '/')
const cwd = norm(rawCwd)
const home = norm(HOME)

let shortPath = ''
if (cwd) {
  shortPath = cwd.startsWith(home) ? '~' + cwd.slice(home.length) : cwd
  // Last three segments, which is where you actually are. Anything deeper is
  // repository furniture and the eye skips it.
  const seg = shortPath.split('/')
  if (seg.length > 4) shortPath = '...' + seg.slice(-3).join('/')
}

// ---------------------------------------------------------------- git

// One call. `--porcelain=v2 --branch` reports the branch, the ahead/behind
// counts and the per-file staged and worktree states together, replacing
// symbolic-ref + two diffs + ls-files + two rev-lists.
//
// -uall rather than the default: the old ls-files --others counted untracked
// files, and the default mode collapses an untracked directory to one entry.
// Keeping the count identical matters more here than the small cost, because
// anything large is gitignored and never reaches this either way.
let gitPart = ''
if (cwd) {
  try {
    const out = execFileSync(
      'git',
      ['-C', rawCwd, 'status', '--porcelain=v2', '--branch', '-uall'],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'], timeout: 2000 }
    )

    let branch = ''
    let ahead = 0
    let behind = 0
    let staged = 0
    let modified = 0
    let untracked = 0

    for (const line of out.split('\n')) {
      if (line.startsWith('# branch.head ')) {
        const head = line.slice('# branch.head '.length).trim()
        // Detached HEAD reports "(detached)". The old script used symbolic-ref,
        // which simply failed there and showed nothing; keep that.
        if (head !== '(detached)') branch = head
      } else if (line.startsWith('# branch.ab ')) {
        const m = line.match(/\+(\d+) -(\d+)/)
        if (m) {
          ahead = Number(m[1])
          behind = Number(m[2])
        }
      } else if (line[0] === '1' || line[0] === '2') {
        // "1 XY ..." and "2 XY ..." -- X is the staged state, Y the worktree
        // state, '.' meaning unchanged in that half.
        const xy = line.slice(2, 4)
        if (xy[0] !== '.') staged++
        if (xy[1] !== '.') modified++
      } else if (line[0] === 'u') {
        // Unmerged. Counted as staged, which is what git diff --cached did.
        staged++
      } else if (line[0] === '?') {
        untracked++
      }
    }

    if (branch) {
      let st = ''
      if (staged) st += `+${staged}`
      if (modified) st += `!${modified}`
      if (untracked) st += `?${untracked}`
      if (ahead && behind) st += `⇕⇡${ahead}⇣${behind}`
      else if (ahead) st += `⇡${ahead}`
      else if (behind) st += `⇣${behind}`
      gitPart = st ? `${branch} ${st}` : branch
    }
  } catch {
    // Not a repository, or git is unavailable. Neither is worth reporting on a
    // status line.
  }
}

// ---------------------------------------------------------------- model

// display_name is "Opus 5 (1M context)" for opus[1m]: 19 columns for something
// that changes maybe twice a day. The parenthetical goes because the window
// size is already visible as the ctx meter -- a 1M session simply sits at a
// lower percentage. Dropping the space keeps it one token to the eye.
//   "Opus 5 (1M context)" -> Opus5    "Haiku 4.5" -> Haiku4.5    "Opus" -> Opus
let model = (get('model.display_name') || '').replace(/ *\(.*/, '').replace(/ /g, '')

// Reasoning effort, hung off the model as one token.
//
// .effort.level is the live session value, so a mid-session /effort shows up
// here. It is absent entirely on models that take no effort parameter, and
// ultracode reports as xhigh rather than a level of its own. Two letters,
// because one is ambiguous between low and nothing while "lo" and "hi" are not.
const EFFORT = { low: 'lo', medium: 'md', high: 'hi', xhigh: 'xh', max: 'max' }
const effort = EFFORT[get('effort.level')] || ''
if (model && effort) model += `·${effort}`

// ---------------------------------------------------------------- account

// Not in the payload, so read from ~/.claude.json, where the CLI keeps the
// login. Worth the extra read: with a personal Max account and a company Team
// account reachable from one machine, which of them a session is spending is
// otherwise invisible until /usage, and by then it has already spent it.
//
// Rendered who@plan. "@" because it reads as an address; "·" is already the
// model/effort qualifier. The local part tells two accounts apart, and the tier
// is what differs between them: default_claude_max_20x -> max20x. A Team seat
// has no rate limit tier and falls back to the organisation type.
let account = ''
try {
  const a = JSON.parse(readFileSync(join(HOME, '.claude.json'), 'utf8')).oauthAccount || {}
  const who = (a.emailAddress || '').split('@')[0]
  const plan = (a.organizationRateLimitTier || a.organizationType || '')
    .replace(/^default_claude_/, '')
    .replace(/^claude_/, '')
    .replace('_', '')
  if (who) account = plan ? `${who}@${plan}` : who
} catch {
  // Signed out, or the file is mid-write. Show nothing rather than a stale name.
}

// ---------------------------------------------------------------- meters

const usedPct = get('context_window.used_percentage')

// Time left, as the two largest units that are actually non-zero. A window is
// only ever interesting at the resolution it is about to expire at: "2d" is
// enough a week out, but on the last day the hours are the whole question, and
// in the last hour so are the minutes. Both windows share this so the weekly
// one degrades to hours and then minutes on its own, with nothing to remember.
function fmtLeft(seconds) {
  const d = Math.floor(seconds / 86400)
  const h = Math.floor((seconds % 86400) / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  if (d > 0) return `${d}d${h}h`
  if (h > 0) return `${h}h${m}m`
  if (m > 0) return `${m}m`
  return 'now'
}

// Only five_hour and seven_day exist in this payload. There is no per-model
// window, so the Fable weekly allowance cannot be shown here; /usage is the
// only place it is broken out.
function window_(key) {
  const resetsAt = get(`rate_limits.${key}.resets_at`)
  if (resetsAt == null) return null
  const pct = get(`rate_limits.${key}.used_percentage`)
  const left = resetsAt - Math.floor(Date.now() / 1000)
  if (left <= 0) return { pct: 100, text: 'limit!' }
  const p = pct == null ? 0 : Math.round(pct)
  return { pct: p, text: `${p}%(${fmtLeft(left)})` }
}

const w5h = window_('five_hour')
const w7d = window_('seven_day')

// ---------------------------------------------------------------- assemble

// Three levels only, matching the tmux status bar:
//   green  = where you are now (the one thing you are looking at)
//   amber  = wants attention
//   slate  = context, read only when you go looking for it
// Colouring every segment differently means none of them reads as more
// important than the others.
//
// Claude Code prints its permission-mode hint on its own line underneath and
// gives no way to suppress it (anthropics/claude-code#53268, #56956), and the
// mode is not in this input either. That line is a fixed cost, so this one
// stays short enough not to wrap and add a third. Cost and lines changed were
// dropped for that reason; /cost still reports them.
const E = '\u001b'
const G = `${E}[38;2;5;150;105m` // primary   #059669
const A = `${E}[38;2;245;158;11m` // active    #f59e0b
const R = `${E}[38;2;239;68;68m` // error, lifted #ef4444 -- #dc2626 measures
//                                  3.70:1 against #0f172a, under AA. Same lift
//                                  as nvim and lazygit use.
const M = `${E}[38;2;148;163;184m` // muted    #94a3b8
const S = `${E}[38;2;100;116;139m` // subtle   #64748b
const X = `${E}[0m`

// One gauge renderer for all three meters. They answer the same question --
// how much of a budget is gone -- so they get the same encoding; three
// hand-rolled if-chains would be three chances to drift apart.
//
// The block glyph carries the same signal as the colour, in shape. Colour alone
// is the standard failure here: roughly 8% of men have some colour blindness and
// most of it is red-green, which is exactly the amber-to-red step below. Shape
// also survives a monochrome terminal, a screenshot, and being seen out of the
// corner of an eye, where a hue change registers late and a rising bar does not.
//
// The steps are not evenly spaced. They sit where the colour steps, at 70 and
// 90, so the shape changes at the one boundary that matters. An even
// eighth-split put 89 and 90 both on ▇ and said nothing there.
//
// Thresholds stay at 70/90 rather than the more common 50/75. A bar that starts
// shouting at half full is one you stop reading, and nothing useful happens at
// 50% anyway: 70 is roughly where it is worth deciding whether to /clear, and
// 90 is where compaction is imminent.
function gauge(label, pct, text) {
  let c = S
  let b = '▁'
  if (pct >= 90) { c = R; b = '█' }
  else if (pct >= 80) { c = A; b = '▇' }
  else if (pct >= 70) { c = A; b = '▆' }
  else if (pct >= 56) { b = '▅' }
  else if (pct >= 42) { b = '▄' }
  else if (pct >= 28) { b = '▃' }
  else if (pct >= 14) { b = '▂' }
  return ` ${c}${label}${b}${text}${X}`
}

let out = ''
if (shortPath) out += `${G}${shortPath}${X}`

if (gitPart) {
  const [branchName, ...rest] = gitPart.split(' ')
  out += ` ${M} ${branchName}${X}`
  if (rest.length) out += ` ${A}${rest.join(' ')}${X}`
}

if (model) out += ` ${S}${model}${X}`
if (account) out += ` ${S}${account}${X}`

if (usedPct != null) {
  const p = Math.round(usedPct)
  out += gauge('ctx', p, `${p}%`)
}
if (w5h) out += gauge('5h', w5h.pct, w5h.text)
if (w7d) out += gauge('7d', w7d.pct, w7d.text)

process.stdout.write(out)
