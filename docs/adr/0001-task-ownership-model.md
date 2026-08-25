# Tasks own file-glob write-claims; overlap sequences, dependencies order

A decomposition is the Queen's highest-stakes artifact — three bees build on it
before anyone notices it was wrong. We model a **task** as one dispatch carrying
a **write-claim** (the path globs it may create or modify). Two mechanisms are
tracked **separately**: *overlap* = write-claim glob-set intersection → those
tasks are **sequenced, never parallelized**; *dependency* = explicit edges →
producer before consumer. A Builder that needs a path outside its claim **stops
and hands back** (`blocked`, naming the path); it never widens its own claim.

**Why:** silent claim-widening is exactly how two Builders end up rewriting the
same module — which isolated worktrees do *not* prevent. Overlap and dependency
answer different questions ("who can't run together" vs "who runs first") and
overloading one to do both loses information.

**Rejected:** harness-enforced per-glob ownership — the harness can't police it,
so the write-claim stays a *prompt* wall (distinct from the read-only wall in
ADR-0002, which is enforced by construction). Shared surfaces (lockfiles,
generated code, migrations) auto-serialize as a special case.

See `CONTEXT.md`, `reference/ownership.md`.
