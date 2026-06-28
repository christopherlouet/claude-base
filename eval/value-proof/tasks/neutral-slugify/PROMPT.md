Implement `slugify(s: string): string` in a file named exactly `slugify.ts`, and
write tests for it in a file named exactly `slugify.test.ts`.

`slugify` should: lowercase the input; replace runs of whitespace with a single
hyphen; strip any character that is not a-z, 0-9, or hyphen; collapse runs of
hyphens into one; and trim leading/trailing hyphens. So `"  Hello,  World!! "`
becomes `"hello-world"` and `"Crème brûlée"` becomes `"crme-brle"`.

Write thorough tests covering the normal case and the edge cases (empty string,
all-punctuation input, leading/trailing spaces, repeated separators).

Write both files into the current directory.
