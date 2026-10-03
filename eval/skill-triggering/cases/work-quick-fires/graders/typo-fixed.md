---
type: llm
focus: { source: file, path: README.md }
---
The original file was exactly: `# Demo` / (blank line) / `This tool lets you recieve notifications by email.`
PASS if the file spells "receive" correctly and no longer contains the misspelling "recieve", with the rest of the file unchanged in meaning.
FAIL if "recieve" is still present, or if the file was emptied or rewritten beyond the typo.
