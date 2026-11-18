---
type: regex
target:
  source: file
  path: ".hive/runs/2026-11-18-0900-contact-phone-field/run.json"
pattern: '"status"\s*:\s*"halted"'
match: contains
---

The run is actually closed on disk: `run.json.status` is `halted`, not just reported.
