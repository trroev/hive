# The handback is a markdown envelope with a four-value outcome verdict

A bee's **handback** is its final message (a subagent's final text *is* its
return value): a **fixed markdown envelope** — Task · Outcome · Summary ·
Location · Gates · Assumptions · Unknowns — invariant across every role, with a
role-specific payload slotted in. The **Outcome verdict** is one of four values —
`complete` / `complete-with-doubts` / `blocked` / `failed` — and is the Queen's
routing signal. Evidence cites `path:line` or URL+version; the Unknowns section
is never silently empty. Material the Queen needs to route stays inline; bulky
raw material spills to `.hive/runs/` by pointer.

**Why:** the Queen reasons in prose and reads handbacks at the status/align
checkpoints, so a structured-but-readable envelope beats JSON (unroutable by
glance) and free prose (unparseable). `blocked` (a boundary problem the Queen
fixes by adjusting the decomposition) and `failed` (the work itself broke) route
to different recoveries and are never collapsed.

**Rejected:** JSON handbacks; free-prose handbacks; pointer-first (forcing a file
read just to decide the next move).

See `reference/handback.md`.
