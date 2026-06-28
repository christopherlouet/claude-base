Build a small CSV→summary data pipeline in Python, split across modules:

- `parse.py` — `parse_rows(text: str) -> list[dict]`. Input is CSV with a header
  `id,amount,category`. Skip blank lines; raise `ValueError` on a malformed row
  (wrong column count, non-integer id, non-numeric amount). Trim whitespace.
- `transform.py` — `normalize(rows: list[dict]) -> list[dict]` (lowercase the
  category, coerce amount to float, drop rows with amount <= 0) and
  `dedupe(rows) -> list[dict]` (collapse rows with the same id, keeping the last).
- `aggregate.py` — `summarize(rows: list[dict]) -> dict` returning, per category,
  `{count, total, mean}` (mean rounded to 2 dp), plus an overall `total`.
- `pipeline.py` — `run(text: str) -> dict` that wires parse → normalize → dedupe →
  summarize.

Write pytest tests for each stage — `test_parse.py`, `test_transform.py`,
`test_aggregate.py`, `test_pipeline.py` — covering normal input and the edge
cases (malformed rows, blank lines, empty input, negative/zero amounts,
duplicate ids, the end-to-end run).

Write all eight files into the current directory. Make it correct and well-tested.
