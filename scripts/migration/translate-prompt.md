## Role

You are translating a single file from French to English in the `claude-socle` repository. This is a meta-project: a configuration template for Claude Code CLI. Your translation will be merged into a public open-source repository whose audience is international developers.

## Hard rules — NEVER violate

1. **NEVER translate slash commands** — they are identifiers, not text.
   Examples (keep verbatim): `/work:work-explore`, `/dev:dev-tdd`, `/qa:qa-loop`, `/ops:ops-deploy`
2. **NEVER translate file paths** — they refer to actual files.
   Examples (keep verbatim): `docs/guides/PROMPTING-GUIDE.md`, `.claude/rules/typescript.md`, `scripts/hooks/prompt-context.sh`
3. **NEVER translate code blocks** — content inside ``` fences stays as-is, with one exception: inline comments (`//`, `#`, `<!--`) inside code blocks may be translated (Option C from the spec).
4. **NEVER translate frontmatter keys** — `name:`, `type:`, `description:`, `paths:`, `model:`, `tools:` stay verbatim. **VALUES** of `description:` and `name:` and similar narrative fields ARE translated; **VALUES** of technical fields (paths, identifiers, lists of file globs) are NOT.
5. **NEVER translate identifiers in backticks** — `userPrenom`, `getUserById`, `MY_ENV_VAR` stay as-is. Variable/function names are not translated.
6. **NEVER translate filenames in markdown links** — `[link](./Bouton.tsx)` keeps `Bouton.tsx`. The link text may be translated.
7. **NEVER add or remove sections, headings, code blocks, or list items** — the structural skeleton is preserved exactly.
8. **NEVER translate items in the BLACKLIST below.**

## Soft rules — translate carefully

- **Code comment exception (Option C)** : inline comments inside code blocks (`//`, `#`, `<!--`) ARE translated when they convey explanation. Comments that act as code (e.g., `// @ts-ignore`) are kept.
- **Filenames in prose** : if a sentence says "Le composant Bouton.tsx affiche...", translate to "The Button.tsx component displays..." — but only if the file is a **purely illustrative example** (not referenced elsewhere). When in doubt, keep the original filename.
- **Tone** : preserve the original voice. The socle uses a direct, terse, sometimes humorous tone. Do not formalize or pad.
- **Terminology** : strictly follow the GLOSSARY below. If a French term is in the glossary, use the canonical English translation. Never invent a synonym.

## Glossary (canonical translations)

Apply strictly. If you encounter a term not in the glossary that recurs in the file, prefer the most direct translation and note it for review.

```yaml
{{GLOSSARY_YAML}}
```

## Blacklist (intraduisibles)

Items in this list MUST appear character-for-character identical in the output:

```
{{BLACKLIST}}
```

## Structural preservation

Your output MUST satisfy:

- Same number of `#` H1 headings as input
- Same number of `##` H2 headings as input
- Same number of `###` H3 headings as input
- Same number of code fences (``` or ~~~) as input
- Same number of markdown tables as input
- Same number of bullet points (top-level) as input
- Frontmatter (between `---` delimiters) keys identical, values translated only for narrative fields

## Output format

Return ONLY the translated file content, nothing else. No preamble, no postamble, no "Here is the translation:" — just the file content.

If a section CANNOT be translated safely (e.g., ambiguous code block, suspicious link, etc.), leave it in French and add a single comment line: `<!-- TRANSLATION-WARNING: <reason> -->`. The validator will catch these and trigger human review.

## Input

File path: `{{FILE_PATH}}`

File content (everything strictly between the BEGIN and END markers below — these markers are not part of the file and must not appear in your output):

<<<BEGIN_SOURCE_FILE>>>
{{FILE_CONTENT}}
<<<END_SOURCE_FILE>>>

## Self-check before output

Mentally verify:
- [ ] All slash commands intact?
- [ ] All file paths intact?
- [ ] All code blocks intact (only inline comments may be translated)?
- [ ] Frontmatter keys intact?
- [ ] Glossary terms used canonically?
- [ ] No structural changes (heading count, code fence count, table count)?
- [ ] No blacklisted items modified?

If any answer is "no", revise before output.
