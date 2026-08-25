# Run state lives on disk: plan/state split, Queen sole writer

Every run persists to `.hive/runs/<runId>/` (gitignored): `run.json` holds the
immutable **plan** (the aligned decomposition), `tasks/<id>.json` holds each
task's **live state** (status, timestamps, gates, verdict, findings, location) —
**no field in both**. The **Queen is the sole writer** (temp-file + atomic
rename), so several bees finishing at once become serialized writes to distinct
files, never a torn read. The task status enum (`ready`/`dispatched`/`in-qa`/
`blocked`/`landed`/`failed`) plus timestamps are the **silence-detection
substrate**: a `dispatched` task with no handback past its budget is presumed
dead.

**Why:** state on disk (not in the Queen's context) is what lets a crashed
session re-adopt in-flight work, and it makes a future detached/durable fleet an
*additive* change rather than a rewrite. A single writer plus file-per-task makes
the atomic-write story fall out for free.

**Rejected:** state held only in the Queen's context; a shared mutable file
multiple writers touch; storing derivable roll-ups (`landed`/`halted` lists are
computed from task statuses, never stored).

See `reference/run-state.md`.
