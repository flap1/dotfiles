#!/usr/bin/env node
// Live file is the base. SHARED then LOCAL overlay. Env: SHARED, LOCAL, TARGET.

const fs = require('fs')
const path = require('path')

const read = (p) => {
  if (!p || !fs.existsSync(p)) return null
  const o = JSON.parse(fs.readFileSync(p, 'utf8'))
  delete o['$comment']
  return o
}

const target = process.env.TARGET
if (fs.existsSync(target) && fs.lstatSync(target).isSymbolicLink()) {
  fs.unlinkSync(target)
  console.log('  removed the old symlink into the repo')
}

const out = read(target) || {}

for (const [name, layer] of [
  ['cli-config.json', read(process.env.SHARED)],
  ['cli-config.local.json', read(process.env.LOCAL)],
]) {
  if (!layer) continue
  for (const [key, value] of Object.entries(layer)) {
    if (key === 'permissions') {
      out.permissions = out.permissions || {}
      for (const kind of ['allow', 'deny']) {
        if (!value[kind]) continue
        out.permissions[kind] = [...new Set([...(out.permissions[kind] || []), ...value[kind]])]
      }
      continue
    }
    out[key] = value
    console.log(`  overlaid ${key} from ${name}`)
  }
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
