# Run state — the on-disk record of a run

This is the schema the `run` skill (the Queen) **writes** and the `status` skill
**reads**. It is the disk-backed memory of a [Run](../CONTEXT.md): the thing that
lets a crashed session re-adopt in-flight work, and the seam that makes a
detached fleet an additive change later rather than a rewrite. Everything here is
machine-readable state; the human-facing narration is rendered from it, never
stored as prose.

A run is a hive at work. The **Queen** holds the comb and is the only one who
writes to it; the **bees** forage and return, and she records what each brings
back. Nothing a bee does reaches disk except through her.

## Where it lives

```
.hive/runs/<runId>/
  run.json           the plan   — the aligned decomposition, frozen at align
  tasks/<id>.json    live state — one file per task, rewritten as it moves
  artifacts/<id>-*.md  overflow — handbacks and findings too bulky to inline
```

`.hive/runs/` is **gitignored** (see `.gitignore`). It is per-machine working
state, not a committed artifact — the profile and architecture map are what get
committed, run-state is not.

`<runId>` is `<UTC-date>-<HHMM>-<slug>`, e.g. `2026-08-25-1030-password-reset` —
sortable, unique per invocation, and the key for `.hive/runs/`. The integration
branch is named separately from `profile.integrationBranchTemplate` (git-flow
default, e.g. `feature/password-reset`) and stored in `run.json.integrationBranch`.
A ticketed run (`--ticket <id>`) names it from `profile.ticketBranchTemplate`
instead (e.g. `feature/PROJ-42-password-reset`) and, if that branch already
exists, builds onto it; `run.json.integrationBase` records which.

## The plan / live-state split — no field in both

The single most important rule of this layout: **`run.json` and `tasks/<id>.json`
never carry the same field.** They answer different questions and change at
different rates.

- `run.json` is the **plan** — what was aligned. It is written once at the align
  checkpoint and then frozen; its `decomposition` never changes without a
  re-align (a shape change re-triggers the align gate — see spec §3). The one
  exception is the run-level `status`, which flips once to a terminal value when
  the run closes.
- `tasks/<id>.json` is the **live state** — what has happened to a task since
  dispatch. It is rewritten every time the task moves (dispatched → in-qa →
  landed, gate results, findings, verdict).

A task's descriptive fields — `goal`, `role`, `deps`, `owns`,
`acceptanceCriteria` — live **only** in `run.json`'s `decomposition`. The task
file never restates them. The two are joined by `id`: the task file is named
`<id>.json` and carries `id` as its self-describing key, and that key is the only
thing that appears on both sides. `id` is a join key, not duplicated content.

Why the split: the plan is immutable and small, so it is read once and cached;
the live state churns and is what concurrent finishes rewrite. Keeping them apart
means a task-file write never risks the plan, and the plan can be trusted as the
frozen record of what the human approved.

> The prototype under `prototypes/08-run-state/.hive-runs-EXAMPLE/` predates this
> split — it still repeats `goal`/`role`/`owns`/`deps`/`acceptanceCriteria` in
> both files and carries derived `landed`/`halted` lists in `run.json`. Those
> duplications were removed by the design reaction; the schema below is
> authoritative, not that example's field set.

## `run.json` — the plan

```jsonc
{
  "runId": "2026-08-25-1030-password-reset",
  "ask": "Add a password reset flow (request + confirm + email).",
  "status": "in-progress",              // in-progress | landed | halted
  "integrationBranch": "feature/password-reset",
  "ticketId": "PROJ-42",                // optional — only when invoked with --ticket
  "integrationBase": {                  // where the integration branch starts
    "mode": "new",                      // new (branch from trunk) | existing (build onto it)
    "ref": "main",                      // trunk, or the existing <branch> / <remote>/<branch>
    "sha": "a1b9f30"                    // its tip at align; Builders start here
  },
  "startedAt": "2026-08-25T10:30:04Z",  // UTC ISO-8601, Z-suffixed
  "profileStamp": "a1b9f30",            // .hive/profile.json version/SHA aligned against

  "decomposition": [
    {
      "id": "t1",
      "goal": "reset-token model + migration",
      "role": "Builder",                       // Builder | Scout | Forager | Guard
      "deps": [],                              // task ids that must finish first
      "owns": ["src/auth/tokens/**", "db/migrations/**"],  // write-claim (Builder only)
      "acceptanceCriteria": [                  // Builder only, ≥ 1
        "ResetToken model with 30-min expiry",
        "forward + down migration",
        "unit tests for expiry"
      ],
      "runs": "sequenced (shared: migrations)" // optional align-view scheduling note
    }
  ]
}
```

Field notes:

- `status` — the **run-level roll-up**, one authoritative value. `in-progress`
  until the run reaches a [terminal state](../CONTEXT.md#run); then `landed` (all
  tasks merged green) or `halted` (stopped at an escalation the human declined to
  continue). This is the *only* mutable field in `run.json`.
- `profileStamp` — the profile version the decomposition was reasoned against, so
  a resumed Queen (or `status`) can flag profile drift since align.
- `decomposition` — the aligned [DAG](../CONTEXT.md#decomposition). Per-task
  fields mirror the task schema (spec §3): `id`/`goal`/`role`/`deps` mandatory
  for all; `owns`/`acceptanceCriteria` mandatory for Builders; read-only tasks
  declare no `owns`. `runs` is an optional human-readable scheduling annotation
  from the align view (`parallel` / `after t1` / `sequenced (shared: …)`), not
  load-bearing state.
- **Derived, never stored.** There are no `landed`/`halted` *lists* here. Which
  tasks have landed is computed from the task files' `status`, so there is one
  source of truth and no reconciliation risk.

## `tasks/<id>.json` — live state

```jsonc
{
  "id": "t2",                              // join key back to run.json
  "status": "in-qa",                       // see enum below
  "dispatchedAt": "2026-08-25T10:44:40Z",  // set when the worker is dispatched
  "handbackAt": "2026-08-25T10:46:02Z",    // set when the handback is persisted; null until then
  "landedAt": null,                        // set when merged onto the integration branch
  "qaRounds": 1,                           // Guard review rounds run so far
  "outcome": "complete-with-doubts",       // latest handback's verdict; null until first handback
  "location": {                            // Builder only (a worktree task); null for read-only bees
    "worktree": ".claude/worktrees/hive-t2",
    "branch": "hive/t2-reset-routes",
    "commits": ["c21be80"]
  },
  "gates": { "lint": "pass", "typecheck": "pass", "test": "fail" },  // gateName → pass|fail; {} until run
  "guardVerdict": "blocks",                // advisory | blocks | null (not yet reviewed)
  "openFindings": [                        // blocking + unresolved findings from the latest Guard round
    { "severity": "major", "loc": "src/routes/auth/reset-confirm.ts:42",
      "note": "no rate-limit on confirm; token brute-forceable" }
  ],
  "deferredFindings": [],                  // minor/nit carried forward, advisory
  "blockedReason": null,                   // when status=blocked: why it stopped
  "needsPath": null,                       // when status=blocked: the path outside its write-claim
  "queenDecision": null,                   // pending adjudication note (widen claim / re-decompose)
  "artifacts": ["artifacts/t2-guard-findings.md"]  // pointers to overflow, relative to the run dir
}
```

Only the fields relevant to a task's current state need be present; absent
optional fields read as null/empty. Read-only bees (Scout/Forager/Guard) omit
`location`, `owns`, and gate/finding machinery they don't produce.

### Status enum

Exactly one of six values, and the substrate for silence detection:

| status | meaning | key timestamps |
| --- | --- | --- |
| `ready` | admitted to the run, eligible or waiting under the [concurrency cap](../CONTEXT.md#concurrency-cap); not yet dispatched. Also the state an unpersisted in-flight worker **reverts to on resume**. | none |
| `dispatched` | a worker is running (Builder building, or a read-only bee working); no handback yet. | `dispatchedAt` set, `handbackAt` null |
| `in-qa` | Builder handed back; Guard is reviewing or a fix round is in flight. | `handbackAt` set |
| `blocked` | worker handed back `blocked` — needs a path outside its claim or a decision; awaiting Queen adjudication. | `handbackAt` set, `blockedReason`/`needsPath` set |
| `landed` | merged onto the integration branch with gates green — terminal (success). | `landedAt` set |
| `failed` | hard failure, or a silence-detected death — terminal, needs escalation. | — |

Timestamps are UTC ISO-8601 with a `Z` suffix. Elapsed and duration are always
**derived** from them at render time, never stored.

## Atomic writes — the Queen is the sole writer

Workers never touch `.hive/runs/`. A bee's only output is its
[Handback](../CONTEXT.md#handback) (its final message); the **Queen persists it**.
This is what makes concurrency safe: with one writer there is no multi-writer
contention to coordinate, and two bees finishing at the same instant become two
serialized writes by the Queen to two *distinct* files (`tasks/t2.json` and
`tasks/t3.json`).

Every write is **temp-file + atomic rename**:

1. Write the full new content to a temp file in the **same directory**
   (e.g. `tasks/.t2.json.tmp` — same filesystem, so rename is atomic).
2. `rename()` it over the destination.

A reader (`status`, a resuming Queen) therefore only ever sees a complete old
file or a complete new one — **never a torn, half-written file**, even if it
reads mid-write. `run.json` is written this way too, but only twice: created at
align, and rewritten once when `status` flips to a terminal value. Builder
**diffs never come here** — they live in git on the Builder's branch; run-state
holds indices and modest markdown artifacts only.

## Failure detection — reading silence

A dead or hung worker doesn't announce itself. The status enum plus timestamps
are how the Queen infers it:

- **Silence during a run.** A task sitting at `dispatched` with no `handbackAt`
  past its budget is silence. The Queen marks it `failed` and escalates. The
  budget is the optional per-task wall-clock timeout (a profile field, default
  none — see spec §9); `maxTurns` per agent (profile, spec §4) guards a runaway
  worker, not a silent one.
- **A stale `dispatched` on resume is presumed dead.** When a crashed session
  resumes, any task still at `dispatched` with no persisted handback had its live
  worker (and its `SendMessage` handle) die with the old session. It is
  **presumed dead** → re-dispatch or escalate. In-flight work that never reached
  disk is simply gone; that task **reverts to `ready`** and runs again. Persisted
  state is the only truth on resume.

## What a resumed Queen reconstructs — and what's lost

From these files alone, a fresh Queen rebuilds the entire run:

- **Reconstructed:** the whole DAG and per-task `status` from `run.json` +
  `tasks/`; each task's worktree, branch, and commits; gate results; open and
  deferred findings; and exactly where to resume — which tasks need a fix round,
  which need a claim decision, which are `ready` to admit.
- **Lost:** the live subagent instances — the `SendMessage` handles to workers
  still running when the session died. Anything not yet persisted as a handback
  is gone; those tasks revert to `ready` (or, if left `dispatched`, are presumed
  dead per above). This is the one deliberate loss, and it is exactly the seam
  that makes a durable/detached fleet an additive change later.

## Render rules (used by `status`)

`status` computes, never stores, these from the files above:

- **Run elapsed** = now − `startedAt`.
- **N/M landed** = count of task files at `status: landed` over total tasks in
  `decomposition`.
- **Per-task Elapsed**: `landed` → `handbackAt` − `dispatchedAt` (build
  duration); `dispatched`/`in-qa` → now − `dispatchedAt`; `blocked`/`ready`/
  `failed` → `—`. Rounded to the nearest minute.
- **Gates cell**: if every gate passed, list the gate short-names
  (`typecheck`→`typ`); if any failed, show the failing gate(s) with `FAIL`; `—`
  if no gate has run.
- **Blocked / note cell**: for `blocked`, `needs <needsPath>` with the
  `queenDecision` beneath; for `in-qa` with open findings, the top finding as
  `Guard: <severity> @ <loc-basename>`; else `—`.
