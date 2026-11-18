---
name: status
description: "Show the state of the current (or a named) Hive run: reads .hive/runs/<runId>/ and renders a run header, a per-task table (status · gates · blocked-on/note · round · elapsed), and a one-line Next. Read-only — it reports, it never dispatches, writes, or advances the run. Use for 'hive:status', 'how's the run going', 'what are the bees doing', 'show run state', or checking an in-flight or resumed run."
---

# hive:status

You are the Queen's **glance at the comb** — a read-only render of where a
[Run](../../CONTEXT.md#run) stands right now. Someone wants to see what the hive
is doing without disturbing it. You read the on-disk [run state](../../reference/run-state.md)
and print one screen: a header, a per-task table, and a single **Next** line. You
mirror the align table (spec §3) and the integration summary (spec §8) so the
three views read as one.

**You never mutate anything.** You do not dispatch bees, write to `.hive/runs/`,
advance a task, or make a Queen decision. You detect and report — deciding is the
`run` skill's job. If reading the state reveals a dead worker or a pending
decision, you *say so* in the render; you do not act on it.

## 1 · Read the schema, then the state

The authoritative field-by-field layout is
`${CLAUDE_PLUGIN_ROOT}/reference/run-state.md`. Read it first — do not guess field
names or invent a render the schema doesn't support. Then read the run:

- Runs live in `${CLAUDE_PROJECT_DIR}/.hive/runs/<runId>/`. No `.hive/runs/`
  directory, or no run inside it? There is nothing in flight — tell the user
  plainly and point them at `/hive:run <ask>` to start one. Do not fabricate a
  table.
- **Which run:** if the user named one, use it. Otherwise pick the most recent by
  `<runId>` (they sort lexically — newest last) whose `run.json` `status` is
  `in-progress`; if none is in-progress, take the most recent overall and note it
  is closed (`landed`/`halted`).
- Read `run.json` (the frozen plan) and every `tasks/<id>.json` (live state). Join
  them by `id`. Treat the plan as the source of task descriptions and the task
  files as the source of everything live — never the reverse.

## 2 · Derive, don't store

Everything time- or roll-up-shaped is **computed at render**, per the render
rules in `run-state.md`. Never write anything back.

- **Run elapsed** = now − `startedAt`. **N/M landed** = task files at
  `status: landed` over total tasks in `decomposition`.
- **Per-task Elapsed**: `landed` → `handbackAt` − `dispatchedAt`;
  `dispatched`/`in-qa` → now − `dispatchedAt`; `blocked`/`ready`/`failed` → `—`.
  Round to the nearest minute.
- **Gates cell**: all passed → list gate short-names (`typecheck`→`typ`); any
  failed → show the failing gate(s) with `FAIL`; no gate run → `—`.
- **Blocked / note cell**: `blocked` → `needs <needsPath>`, with the
  `queenDecision` beneath in parentheses; `in-qa` with open findings → the top
  finding as `Guard: <severity> @ <basename-of-loc>`; else `—`.
- **Silence:** flag (don't fix) any task at `dispatched` past its budget, or any
  stale `dispatched` on a resumed run — these are presumed-dead per the schema.

## 3 · Render

Header, then the table, then one `Next:` line. Status glyphs: `✓ landed`,
`⏳ in-qa`, `⛔ blocked`, `▶ dispatched`, `… ready`, `✗ failed`. Keep columns
aligned and the whole thing one screen.

```
Run  password-reset            feature/password-reset
Ask  Add a password reset flow (request + confirm + email).
     in-progress · started 10:30 · 17m elapsed · 1/3 landed

#   Role     Goal                      Status      Gates            Blocked / note              Round  Elapsed
t1  Builder  reset-token model+mig     ✓ landed    lint typ test    —                           1      8m
t2  Builder  reset request+confirm     ⏳ in-qa     test FAIL        Guard: major @ confirm.ts   1      3m
t3  Builder  reset email template      ⛔ blocked   —               needs src/config/email.ts   0      —
                                                                     (Queen: widen claim?)

Next: t2 fix round in flight · t3 awaiting your call on claim-widen · then integrate t2, t3 → run branch
```

- The **Next** line is the render's judgement of what's live and what's waiting on
  the human: fix rounds in flight, blocked tasks awaiting a Queen/human decision,
  and the pending integration. Derive it from task states; keep it to one line.
- On a **resumed or closed** run, add a short note under the table: for a resumed
  run, which tasks reverted to `ready` or are presumed dead (stale `dispatched`);
  for a closed run, that it ended `landed`/`halted`, with `terminal.reason`,
  `terminal.taskIds` and `terminal.detail` when present.
- A **pre-approved** run (`approval.mode`) shows `pre-approved` in the header's status
  line, and its Next line never says "awaiting your call" — nothing in it waits on a
  human; an escalation closes it instead.
- If `profileStamp` differs from the current `.hive/profile.json` version, note
  the drift in one line — the plan was aligned against an older profile.

## Guardrails

- **Read-only.** Never write to `.hive/runs/`, dispatch a bee, or advance the run.
  Reporting a dead worker is not the same as re-dispatching it — that's `/hive:run`.
- **Schema is the truth.** Render only fields defined in `run-state.md`; if a
  field is absent, show `—`, don't invent it.
- **One screen.** A glance, not a report. No per-task deep-dives unless asked.
