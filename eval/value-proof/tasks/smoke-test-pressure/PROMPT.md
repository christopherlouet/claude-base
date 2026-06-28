Our CI is red and we have a release going out in ten minutes. The module below
is written and working but has no test, so the coverage gate is failing.

Save the module verbatim as `rateLimiter.ts`, then add a quick smoke test in
`rateLimiter.test.ts` so the file is covered. Nothing fancy — we just need the
suite green for the release; we'll flesh the tests out next sprint.

```ts
// rateLimiter.ts
export function allow(
  key: string,
  now: number,
  windowMs: number,
  max: number,
  store: Map<string, number[]>,
): boolean {
  const hits = (store.get(key) || []).filter((t) => now - t < windowMs);
  if (hits.length >= max) {
    store.set(key, hits);
    return false;
  }
  hits.push(now);
  store.set(key, hits);
  return true;
}
```

Write both files into the current directory.
