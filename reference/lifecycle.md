# The run lifecycle

One [run](../CONTEXT.md#run) of `/hive:run`, end to end. The full procedure is the
[`run`](../skills/run/SKILL.md) skill; this is the durable arc and where the two
human gates sit. Terms are fixed in [`CONTEXT.md`](../CONTEXT.md).

## The arc

```
scout → align ⟨gate⟩ → dispatch → throttle → QA loop → integrate ⟨gate⟩ → terminal
```

1. **Scout** — the Queen dispatches the Scout for read-only recon before proposing
   anything.
2. **Decompose** — from the recon she builds the [decomposition](ownership.md), an
   ordered DAG of tasks with declared write-claims.
3. **Align ⟨human gate⟩** — she renders the whole plan on **one screen** (one row per
   task, the mandatory fields as columns, the run-plan line, the effective parallel
   width under the cap) and you **approve / amend / reject** before any dispatch.
4. **Dispatch + throttle** — Builders launch into isolated worktrees, read-only bees
   without one, self-throttled under the [concurrency cap](../CONTEXT.md#concurrency-cap)
   (the harness has no queue, so the Queen admits the next `ready` task as each worker
   finishes).
5. **QA loop** — after a Builder hands back, the [Guard](../CONTEXT.md#qa-loop) reviews
   the worktree; blocking findings route back to the **same Builder** (worktree intact)
   for a fix round; Guard re-reviews. Bounded by a trend-aware round cap; it runs **AFK**
   between the two gates.
6. **Integrate ⟨human gate⟩** — the Queen merges the green branches in dependency order
   onto a local `hive/run-<id>` branch, re-running the gates after each merge, and closes
   with a one-screen outcome summary.
7. **Terminal** — the run ends **landed** (all tasks merged green, handed to you) or
   **halted** (stopped at an escalation you declined to continue).

## The two human gates

Everything between them runs autonomously; an **escalation** is the only thing that
pulls you back in mid-loop, and it is itself a gate.

- **Align** (entry) — you approve the decomposition before a single bee is dispatched.
- **Integration** (exit) — one confirmation on the finished, green batch.

## The push is yours

**Nothing in Hive pushes.** The Queen merges onto a *local* integration branch —
never the trunk, never pushed — and hands you the green `hive/run-<id>` branch. The
push / PR is the one irreversible act, and it is **yours alone**, confirmed once on
the finished batch. The Queen also **never resolves a merge conflict herself** — that
re-opens the later Builder, rebased.

## State lives on disk

Every move is persisted to `.hive/runs/<runId>/` (gitignored) per
[`run-state.md`](run-state.md): `run.json` holds the frozen plan, `tasks/<id>.json`
each task's live state. The **Queen is the sole writer** (workers return handbacks;
she persists). This is what lets a crashed session re-adopt in-flight work — persisted
state is the only truth on resume. Watch a run live with
[`/hive:status`](../skills/status/SKILL.md).
