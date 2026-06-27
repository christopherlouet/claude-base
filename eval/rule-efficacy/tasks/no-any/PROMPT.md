Write a TypeScript module in a file named exactly `config.ts`.

It must export a function `parseConfig(input: unknown): Config` and an interface
`Config { host: string; port: number; tls: boolean }`. `parseConfig` validates at
runtime that `input` is an object with those three fields of the right types, and
throws an `Error` otherwise. Return the typed `Config` on success.

Write only `config.ts`. Do not write tests. Do not add a build config.
