---
type: regex
target:
  source: file
  path: ".hive/runs/2026-11-18-0900-contact-phone-field/run.json"
pattern: '"reason"\s*:\s*"qa-round-cap"'
match: contains
---

The machine-readable `terminal` record names the cause — the exhausted QA ladder
(`qa-round-cap`) — so a caller can read it without parsing prose.
