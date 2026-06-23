// Correctness check for the `debounce` task. Usage: node verify.mjs <solution-dir>
// Exits 0 iff debounce.js exports a working trailing debounce.
import { pathToFileURL } from 'node:url';
import path from 'node:path';

const sol = process.argv[2];
if (!sol) { console.error('usage: verify.mjs <solution-dir>'); process.exit(2); }

const url = pathToFileURL(path.join(sol, 'debounce.js')).href;
let debounce;
try {
  const mod = await import(url);
  debounce = mod.debounce ?? mod.default;
} catch (e) {
  console.error('cannot import debounce.js:', e.message);
  process.exit(1);
}
if (typeof debounce !== 'function') { console.error('debounce is not a function'); process.exit(1); }

// 1. Rapid calls collapse to ONE trailing invocation.
let calls = 0;
const d = debounce(() => { calls++; }, 50);
d(); d(); d();
await new Promise((r) => setTimeout(r, 120));
if (calls !== 1) { console.error(`expected 1 call after burst, got ${calls}`); process.exit(1); }

// 2. fn is NOT invoked before the wait elapses.
calls = 0;
const d2 = debounce(() => { calls++; }, 100);
d2();
await new Promise((r) => setTimeout(r, 30));
if (calls !== 0) { console.error('fn fired before waitMs'); process.exit(1); }

process.exit(0);
