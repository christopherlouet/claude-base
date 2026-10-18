// lint-staged config, installed by `claude-base init --hooks`.
//
// Asks for a tool only when it is installed, and for eslint only when the
// project has configured it. A static config calling `eslint --fix` and
// `prettier --write` refused every commit on a project that had not added
// them: lint-staged fails a task whose command cannot be found, and eslint
// fails when it finds no config. A gate nobody feeds must step aside, not
// block the work. Replace this file with your own config at any time.

import { existsSync, readFileSync, readdirSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = dirname(fileURLToPath(import.meta.url))
const installed = (name) => existsSync(join(root, 'node_modules', '.bin', name))
const readJson = (path) => {
  try {
    const value = JSON.parse(readFileSync(join(root, path), 'utf8'))
    return value !== null && typeof value === 'object' ? value : {}
  } catch {
    return {}
  }
}

// eslint 9+ reads only a flat eslint.config.*; a legacy .eslintrc* or an
// "eslintConfig" key counts only below 9, where eslint still reads them —
// queueing eslint 9 on a leftover .eslintrc would fail every commit.
const eslintMajor = Number.parseInt(readJson('node_modules/eslint/package.json').version, 10)
const files = readdirSync(root)
const flatConfig = files.some((f) => /^eslint\.config\.[cm]?[jt]s$/.test(f))
const legacyConfig =
  files.some((f) => /^\.eslintrc(\.(c?js|json|ya?ml))?$/.test(f)) ||
  'eslintConfig' in readJson('package.json')
const eslintConfigured = flatConfig || (eslintMajor < 9 && legacyConfig)

const eslint = installed('eslint') && eslintConfigured ? ['eslint --fix'] : []
const prettier = installed('prettier') ? ['prettier --write'] : []

const config = Object.fromEntries(
  Object.entries({
    '*.{js,jsx,ts,tsx}': [...eslint, ...prettier],
    '*.{json,md,yml,yaml}': prettier,
    '*.{css,scss}': prettier,
  }).filter(([, tasks]) => tasks.length > 0),
)

// lint-staged rejects an empty config, so with no tool installed it gets a
// glob no file matches: lint-staged then exits 0 at once, without the stash
// and re-stage cycle a catch-all '*' no-op still pays on every commit.
export default Object.keys(config).length > 0 ? config : { '.claude-base-no-lint-tools': () => [] }
