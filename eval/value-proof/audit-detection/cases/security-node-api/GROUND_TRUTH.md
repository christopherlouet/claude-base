# Ground truth — security-node-api

Planted vulnerabilities in `app.js` (the oracle). An arm "detects" a defect if its
report clearly names the issue at the right location/class. Two **decoys** are
benign — flagging them counts as a false positive (precision hit).

## Planted vulnerabilities (recall target = 7)

| ID | Class | Location | What |
|----|-------|----------|------|
| SEC-1 | SQL injection | `GET /notes/:id` | `"SELECT * FROM notes WHERE id = " + req.params.id` — unsanitized id concatenated into SQL. |
| SEC-2 | Reflected XSS | `GET /welcome` | `res.send("<h1>Welcome back, " + req.query.name + ...)` — user input echoed into HTML unescaped. |
| SEC-3 | Path traversal | `GET /files` | `fs.readFileSync("./uploads/" + req.query.path)` — no normalization; `?path=../../etc/passwd`. |
| SEC-4 | Command injection | `GET /ping` | `exec("ping -c 1 " + req.query.host)` — user input into a shell command. |
| SEC-5 | Weak password hashing | `POST /register` | `crypto.createHash("md5")` for passwords — unsalted, fast, broken. |
| SEC-6 | Hardcoded secret | top-level + `app.listen` log | `STRIPE_SECRET = "sk_live_..."` committed in source AND leaked to stdout. |
| SEC-7 | Broken access control | `DELETE /notes/:id` (and reads) | no authentication/authorization — any client can delete/read any note. |

## Decoys (benign — must NOT be flagged)

| ID | Location | Why it's safe |
|----|----------|---------------|
| DECOY-1 | `GET /bundle-url` `Math.random()` | a cache-buster string, not security-sensitive randomness; flagging "insecure RNG" is a false positive. |
| DECOY-2 | `GET /notes` `LIKE ?` query | the search query is **parameterized** — flagging it as SQLi is a false positive. |
