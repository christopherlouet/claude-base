// Zero-dependency test runner: runs every tests/*.test.js (each exports
// { "case name": () => { ... assert ... } }) and exits non-zero on any failure.
const fs = require("fs");
const path = require("path");

const dir = path.join(__dirname, "tests");
let passed = 0;
let failed = 0;

for (const f of fs.readdirSync(dir).filter((x) => x.endsWith(".test.js"))) {
  let cases;
  try {
    cases = require(path.join(dir, f));
  } catch (e) {
    failed++;
    console.error(`FAIL ${f} (load): ${e.message}`);
    continue;
  }
  for (const [name, fn] of Object.entries(cases)) {
    try {
      fn();
      passed++;
    } catch (e) {
      failed++;
      console.error(`FAIL ${f} > ${name}: ${e.message}`);
    }
  }
}

console.log(`${passed} passed, ${failed} failed`);
process.exit(failed ? 1 : 0);
