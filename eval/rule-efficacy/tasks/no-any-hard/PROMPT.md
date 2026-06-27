Write a TypeScript function `deepMerge` in a file named exactly `deep-merge.ts`.

It recursively deep-merges two values `a` and `b` of arbitrary, unknown JSON-like
shape: each value may be a nested plain object, an array, or a primitive. For two
plain objects it merges their keys recursively; otherwise `b` wins. Export
`deepMerge`. Keep it concise. Do not write tests.
