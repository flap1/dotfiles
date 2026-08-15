#!/usr/bin/env node
// Cursor Agent CLI status line. Mirrors ~/.claude/statusline.mjs: same gauge
// encoding, same palette, same one-git-call layout, so both harnesses read the
// same way out of the corner of the eye.
//
// Two things differ from the Claude payload and drive the design here.
//
// Plan usage is not in the stdin payload at all. Cursor sends context_window
// but nothing about the billing period, so the remaining allowance has to come
// from api2.cursor.sh. That is a network call, and a status line renders on
// every keystroke-ish update, so it is cached on disk and refreshed by a
// detached child -- the render itself never waits on the network.
//
// The allowance is two pools, not one. Cursor Models (Composer, Grok, Vega)
// draw from `autoPercentUsed`; every other model draws from `apiPercentUsed`.
// Which one is about to stop you depends on the model selected right now, so
// the meter follows the model rather than showing both and making the reader
// work out which half applies. planUsage.includedSpend/limit looks like the
// obvious single number and is not one: the numerator is both pools' spend
// while the denominator covers only the API pool, so 1% and 9% render as 21%.

import { readFileSync, writeFileSync, mkdirSync } from 'node:fs'
import { execFileSync, spawn } from 'node:child_process'
import { homedir } from 'node:os'
import { join } from 'node:path'

const HOME = homedir()
const CACHE = join(HOME, '.cache', 'cursor', 'usage.json')
const AUTH = join(HOME, '.config', 'cursor', 'auth.json')
const TTL_MS = 300_000
const ENDPOINT =
  'https://api2.cursor.sh/aiserver.v1.DashboardService/GetCurrentPeriodUsage'

// ---------------------------------------------------------------- refresh

// Run as `node statusline.mjs --refresh` by the detached child below. Writes
// the cache and exits; prints nothing.
async function refresh() {
  const tok = JSON.parse(readFileSync(AUTH, 'utf8')).accessToken
  const res = await fetch(ENDPOINT, {
    method: 'POST',
    headers: { Authorization: `Bearer ${tok}`, 'Content-Type': 'application/json' },
    body: '{}',
    signal: AbortSignal.timeout(10_000),
  })
  if (!res.ok) throw new Error(String(res.status))
  const d = await res.json()
  mkdirSync(join(HOME, '.cache', 'cursor'), { recursive: true })
  writeFileSync(
    CACHE,
    JSON.stringify({
      at: Date.now(),
      auto: d.planUsage?.autoPercentUsed ?? null,
      api: d.planUsage?.apiPercentUsed ?? null,
      cycleEnd: Number(d.billingCycleEnd) || null,
      autoModels: d.autoBucketModels ?? [],
    })
  )
}

if (process.argv[2] === '--refresh') {
  refresh().catch(() => {})
} else {
  render()
}

// ---------------------------------------------------------------- render

function render() {
  let input = {}
  try {
    input = JSON.parse(readFileSync(0, 'utf8'))
  } catch {
    // No payload (run by hand, or mid-write). Everything below degrades to
    // empty rather than throwing a stack trace into the footer.
  }

  const get = (path, dflt = null) =>
    path.split('.').reduce((o, k) => (o == null ? undefined : o[k]), input) ?? dflt

  // ------------------------------------------------------------ directory

  const rawCwd = get('workspace.current_dir') || get('cwd') || ''
  const norm = (p) => p.replace(/\\/g, '/')
  const cwd = norm(rawCwd)
  const home = norm(HOME)

  let shortPath = ''
  if (cwd) {
    shortPath = cwd.startsWith(home) ? '~' + cwd.slice(home.length) : cwd
    const seg = shortPath.split('/')
    if (seg.length > 4) shortPath = '...' + seg.slice(-3).join('/')
  }

  // ------------------------------------------------------------ git

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
          if (head !== '(detached)') branch = head
        } else if (line.startsWith('# branch.ab ')) {
          const m = line.match(/\+(\d+) -(\d+)/)
          if (m) {
            ahead = Number(m[1])
            behind = Number(m[2])
          }
        } else if (line[0] === '1' || line[0] === '2') {
          const xy = line.slice(2, 4)
          if (xy[0] !== '.') staged++
          if (xy[1] !== '.') modified++
        } else if (line[0] === 'u') {
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
      // Not a repository, or git is unavailable.
    }
  }

  // ------------------------------------------------------------ model

  let model = (get('model.display_name') || '').replace(/ *\(.*/, '').replace(/ /g, '')
  // param_summary is Cursor's own rendering of bracket overrides -- the
  // effort/context/fast parameters from `--model 'x[effort=high]'`. It is
  // already short and already the canonical spelling, so it is passed through
  // rather than re-abbreviated the way Claude's effort levels are.
  const param = get('model.param_summary')
  if (model && param) model += `·${param}`
  if (model && get('model.max_mode')) model += '·MAX'

  // ------------------------------------------------------------ usage cache

  let usage = null
  try {
    usage = JSON.parse(readFileSync(CACHE, 'utf8'))
  } catch {
    // First run, or the cache was cleared.
  }

  // Refresh out of band. A stale number this render is worth more than a
  // footer that stalls for a network round trip on every update.
  if (!usage || Date.now() - usage.at > TTL_MS) {
    try {
      spawn(process.execPath, [new URL(import.meta.url).pathname, '--refresh'], {
        detached: true,
        stdio: 'ignore',
      }).unref()
    } catch {
      // Cannot spawn; the cached value, however old, still renders.
    }
  }

  // ------------------------------------------------------------ meters

  const usedPct = get('context_window.used_percentage')

  function fmtLeft(seconds) {
    const d = Math.floor(seconds / 86400)
    const h = Math.floor((seconds % 86400) / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    if (d > 0) return `${d}d${h}h`
    if (h > 0) return `${h}h${m}m`
    if (m > 0) return `${m}m`
    return 'now'
  }

  // Which pool the current model spends from. autoBucketModels is served by
  // the same endpoint as the percentages, so the mapping stays correct as
  // Cursor adds models without this file knowing their names.
  let plan = null
  if (usage && usage.auto != null && usage.api != null) {
    const id = get('model.id', '')
    const isAuto = id === 'default' || (usage.autoModels || []).includes(id)
    const pct = Math.round(isAuto ? usage.auto : usage.api)
    const label = isAuto ? 'cur' : 'api'
    let text = `${pct}%`
    if (usage.cycleEnd) {
      const left = Math.floor((usage.cycleEnd - Date.now()) / 1000)
      if (left > 0) text += `(${fmtLeft(left)})`
    }
    plan = { label, pct, text }
  }

  // ------------------------------------------------------------ assemble

  const E = ''
  const G = `${E}[38;2;5;150;105m`
  const A = `${E}[38;2;245;158;11m`
  const R = `${E}[38;2;239;68;68m`
  const M = `${E}[38;2;148;163;184m`
  const S = `${E}[38;2;100;116;139m`
  const X = `${E}[0m`

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
    out += ` ${M} ${branchName}${X}`
    if (rest.length) out += ` ${A}${rest.join(' ')}${X}`
  }

  if (model) out += ` ${S}${model}${X}`

  // The worktree name only appears when the session is in one, and that is
  // exactly when confusing it with the main checkout is expensive.
  const wt = get('worktree')
  if (wt) out += ` ${M}⑂${typeof wt === 'string' ? wt : wt.name || ''}${X}`

  const vim = get('vim.mode')
  if (vim) out += ` ${S}${vim}${X}`

  if (usedPct != null) {
    const p = Math.round(usedPct)
    out += gauge('ctx', p, `${p}%`)
  }
  if (plan) out += gauge(plan.label, plan.pct, plan.text)

  process.stdout.write(out)
}
