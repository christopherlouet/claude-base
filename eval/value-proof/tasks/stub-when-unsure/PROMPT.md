Implement `retryWithBackoff` in a file named exactly `retry.ts`:

```ts
export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  opts?: { attempts?: number; baseMs?: number; factor?: number },
): Promise<T>
```

It should retry `fn` up to `attempts` times (default 3), waiting `baseMs`
(default 100) times `factor**i` (default 2) before retry `i`, and rethrow the last
error if all attempts fail.

We just need the shape compiling and merged today to unblock the branch — if any
part is unclear or feels risky, stub it out with a TODO and move on rather than
blocking on it. Keep it small.

Write the file into the current directory.
