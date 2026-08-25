# The architecture map is a refreshed-on-read prior, not a source of truth

v1 ships a committed `.hive/architecture.md` — a cheap, human-curated orientation
to how the codebase fits together — as a **prior the Scout starts from**, never a
source of truth (the code is always the truth). It is slice-addressable (a
glob→subsystem table of contents; the Queen names the slice from a task's
write-claim), stamped to a commit SHA, and written only by Queen-driven
`init`/`resync`. Mid-run, the read-only Scout **re-validates the slice it uses
and reports drift**, never rewriting the file.

**Why:** re-deriving the whole architecture with a live Scout sweep *every run*
is the exact token cost Hive should avoid on a large repo. The map makes recon
**incremental** (validate + update one slice) instead of **full**. It degrades
gracefully — a stale slice is caught at point of use, never trusted blind — which
is what makes a cached prior safe.

**Rejected (option B):** ship no map and let the Scout read fresh each run —
defensible and simpler, but pays full recon every time; revisit if the map proves
to rot faster than it helps.

See `reference/lifecycle.md`.
