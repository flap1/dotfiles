#!/usr/bin/env node
// Splice SHARED tables into TARGET; leave live-only tables. Env: SHARED, TARGET.

const fs = require('fs')
const path = require('path')

function split(text) {
  const pre = []
  const sections = []
  let cur = null
  for (const line of text.split('\n')) {
    if (/^\[/.test(line)) {
      cur = { header: line.trim(), body: [] }
      sections.push(cur)
    } else if (cur) {
      cur.body.push(line)
    } else {
      pre.push(line)
    }
  }
  return { pre, sections }
}

const target = process.env.TARGET
if (fs.existsSync(target) && fs.lstatSync(target).isSymbolicLink()) {
  fs.unlinkSync(target)
  console.log('  removed the old symlink into the repo')
}

const mine = split(fs.readFileSync(process.env.SHARED, 'utf8'))
const live = fs.existsSync(target)
  ? split(fs.readFileSync(target, 'utf8'))
  : { pre: [], sections: [] }
const retired = new Set(
  process.env.RETIRED && fs.existsSync(process.env.RETIRED)
    ? fs
        .readFileSync(process.env.RETIRED, 'utf8')
        .split('\n')
        .map((line) => line.trim())
        .filter((line) => line && !line.startsWith('#'))
        .map((table) => `[${table}]`)
    : [],
)

const owned = new Set(mine.sections.map((s) => s.header))
const merged = [
  ...mine.sections,
  ...live.sections.filter((s) => !owned.has(s.header) && !retired.has(s.header)),
]

for (const s of mine.sections) {
  console.log(`  ${live.sections.some((l) => l.header === s.header) ? 'replaced' : 'added'} ${s.header}`)
}
for (const header of retired) {
  if (live.sections.some((s) => s.header === header)) console.log(`  removed ${header}`)
}

const home = path.dirname(target)
let body =
  mine.pre.join('\n').replace(/\n+$/, '') +
  '\n\n' +
  merged.map((s) => s.header + '\n' + s.body.join('\n').replace(/\n+$/, '')).join('\n\n') +
  '\n'
body = body.replace(
  /^config_file = "agents\/([^"]+)"$/gm,
  (_, file) => `config_file = ${JSON.stringify(path.join(home, 'agents', file))}`,
)

const before = fs.existsSync(target) ? fs.readFileSync(target, 'utf8') : null
if (body === before) {
  console.log('  already current')
  process.exit(0)
}
if (before !== null) {
  const backup = target + '.' + new Date().toISOString().replace(/\D/g, '').slice(0, 14)
  fs.copyFileSync(target, backup)
  console.log('  backed up -> ' + backup)
}
fs.mkdirSync(path.dirname(target), { recursive: true })
fs.writeFileSync(target, body)
console.log('  -> ' + target)
