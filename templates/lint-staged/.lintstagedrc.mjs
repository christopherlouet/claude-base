// lint-staged config, installed by `claude-base init --hooks`.
//
// Asks for a tool only when it is installed, and for eslint only when the
// project has configured it. A static config calling `eslint --fix` and
// `prettier --write` refused every commit on a project that had not added
// them: lint-staged fails a task whose command cannot be found, and eslint
// fails when it finds no config. A gate nobody feeds must step aside, not
// block the work. Replace this file with your own config at any time.

import { existsSync, readdirSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = dirname(fileURLToPath(import.meta.url))
const installed = (name) => existsSync(join(root, 'node_modules', '.bin', name))
const eslintConfigured = readdirSync(root).some((f) =>
  /^(eslint\.config\.[cm]?[jt]s|\.eslintrc(\.(c?js|json|ya?ml))?)$/.test(f),
)

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
// task that runs nothing: the commit goes through untouched.
export default Object.keys(config).length > 0 ? config : { '*': () => [] }
