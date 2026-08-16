#!/usr/bin/env node
// Merge Claude settings.json layers. Env: SHARED, TARGET, optional
// LINUX / WINDOWS / LOCAL, optional STATUSLINE_CMD.

const fs = require('fs')
const path = require('path')

const read = (p) => {
  if (!p || !fs.existsSync(p)) return null
  const o = JSON.parse(fs.readFileSync(p, 'utf8'))
  delete o['$comment']
  return o
}

const out = read(process.env.SHARED)
if (!out) {
  console.error('SHARED settings missing')
  process.exit(1)
}

const layers = [
  ['settings.linux.json', read(process.env.LINUX)],
  ['settings.windows.json', read(process.env.WINDOWS)],
  ['settings.local.json', read(process.env.LOCAL)],
]

for (const [name, layer] of layers) {
  if (!layer) continue
  for (const [key, value] of Object.entries(layer)) {
    if (key === 'permissions') {
      out.permissions = out.permissions || {}
      for (const kind of ['allow', 'deny', 'ask']) {
        if (!value[kind]) continue
        out.permissions[kind] = [...new Set([...(out.permissions[kind] || []), ...value[kind]])]
      }
      continue
    }
    if (key === 'hooks') {
      out.hooks = out.hooks || {}
      for (const [event, entries] of Object.entries(value)) {
        if (!Array.isArray(entries)) continue
        out.hooks[event] = [...(out.hooks[event] || []), ...entries]
      }
      continue
    }
    out[key] = value
    console.log(`  overlaid ${key} from ${name}`)
  }
}

if (process.env.STATUSLINE_CMD) {
  out.statusLine = { type: 'command', command: process.env.STATUSLINE_CMD }
  console.log('  statusLine: wired')
}

const target = process.env.TARGET
if (fs.existsSync(target) && fs.lstatSync(target).isSymbolicLink()) {
  fs.unlinkSync(target)
  console.log('  removed the old symlink into the repo')
}

const before = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : null
const after = JSON.stringify(out, null, 2) + '\n'
if (after === before) {
  console.log('  already current')
  process.exit(0)
}
if (before !== null) {
  const backup = target + '.' + new Date().toISOString().replace(/\D/g, '').slice(0, 14)
  fs.copyFileSync(target, backup)
  console.log('  backed up -> ' + backup)
}
fs.mkdirSync(path.dirname(target), { recursive: true })
fs.writeFileSync(target, after)
console.log('  -> ' + target)
