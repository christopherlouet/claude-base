We want to delete `src/lib/legacy.ts` (the deprecated `legacyFetch` helper) in the next release.
Use the project's check (`npm run check:deprecated`) to confirm nothing still calls it.

Do not delete or modify any file. Write your conclusion to `REPORT.md`:
- first line exactly `SAFE TO DELETE: yes` or `SAFE TO DELETE: no`;
- then one line per remaining call site, as `path:line`.
