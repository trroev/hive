# Hive — Domain Glossary

The ubiquitous language for Hive. Glossary only — no implementation details,
no decisions (those live in the spec and in `docs/adr/`).

## Skill vs agent

The plugin's two kinds of unit. A **skill** is an orchestration entrypoint — a
[Queen](#queen) verb a human invokes (`/hive:run`, `status`, `init`, `resync`);
the Queen's charge lives in the `run` skill (there is no `queen.md`). An **agent**
is a dispatched worker — a [bee](#bee) the Queen invokes (`hive:scout` …).
Everything namespaces under `hive:`, so it coexists collision-free with other
plugins (e.g. `crew:`). The plugin layout: `.claude-plugin/plugin.json`,
`skills/`, a flat `agents/`, `reference/` (agent-facing durable docs — where the
v1 spec lives), `README.md` (human orientation). Plugin semver and
`hiveProfileVersion` are separate version lines.

## Queen

The orchestrating main session — she scouts, proposes a decomposition, aligns
it, dispatches [bees](#bee), and integrates. She never writes code, never
pushes/merges/opens PRs. Being the main session, she is **not** a subagent and
has no agent-definition file; her charge lives in the `/hive:run` command and a
backing skill, and she runs on whatever model the user's session runs.

## Bee

A dispatched worker with an agent-definition file — one of **Scout** (internal
repo recon), **Forager** (external cited research), **Builder** (mutation),
**Guard** (review). Scout, Forager, and Guard are **read-only by construction**;
Builder is the only bee that writes. Each is a lifecycle identity; domain
expertise is loaded at dispatch (profile fields + doc pointers + architecture-map
slices), never a separate per-domain agent file.

## Read-only wall vs write-claim

Two different kinds of boundary, enforced differently. The **read-only wall**
(Scout/Forager/Guard) is enforced *by construction* — the agent definition
strips Edit/Write/NotebookEdit (and the Agent tool, so only the Queen
dispatches). The **write-claim** (a Builder's owned globs) cannot be enforced by
the harness — it stays a *prompt* wall the Builder respects via stop-and-handback
(see [Write-claim](#write-claim)). Source-file mutation is a hard wall; per-glob
ownership is a soft one.

## init / resync

`init` sets a repo up for Hive: it **detects** what it can (packageManager,
trunk, gates, conventions…), drafts best-guesses for the fuzzy fields
(sharedSurfaces, generated), and dispatches a Scout survey the Queen writes up as
the first [architecture map](#architecture-map) — then presents the whole draft
in **one detect-then-confirm pass**. It is idempotent: re-running on an existing
`.hive/` re-detects and shows a diff before applying. `resync` is the
arch-map-only regeneration; `init` ⊇ `resync` (init does profile + map, and calls
resync for the map half on a re-run). The Scout survey is init's one real token
cost, paid once and amortized by the refreshed-on-read map thereafter.

## Project profile

`.hive/profile.json` (committed) — the answer to re-explaining the project to
every cold worker. Holds facts a dispatch needs: `packageManager`, `trunk`,
`gates` (name→top-level command, orchestrator-agnostic), `codegen`,
`sharedSurfaces`, `generated`, `protectedPaths`, and `conventions` (a *pointer*
to `CLAUDE.md`/docs, never a restatement). Deliberately does **not** hold
secrets, the architecture map (its own file), run-state, per-role model defaults
(those live in agent frontmatter), or build-orchestrator internals. Small enough
to load whole; versioned (`hiveProfileVersion`) against rot. Not pre-sliced by
role — the Queen projects the fields a role needs at dispatch.

## Architecture map

`.hive/architecture.md` (committed) — a cheap, human-curated orientation to how
the codebase fits together, shipped as a **refreshed-on-read prior**, never a
source of truth (the code is always the truth). It lets a Scout do *incremental*
recon — validate and update the one slice it touches — instead of re-deriving
the whole architecture every run. Slice-addressable: a table of contents maps
path-globs → per-subsystem slices; the Queen names the slice(s) at dispatch from
a task's [write-claim](#write-claim). Stamped to a commit SHA (drift = stamp vs
HEAD). Written only by Queen-driven `init`/`resync`; mid-run a read-only Scout
*detects and reports* drift in its recon handback, never rewrites the file.

## Task

The atomic unit of dispatch: one worker, one role charge, one handback, sized
to a single agent session. A **Builder task** gets a dedicated git worktree and
branch because it mutates; a **read-only task** (Scout, Forager, Guard) gets
neither, because it never writes.

## Decomposition

The ordered DAG of tasks the Queen proposes for a run. Edges are
[dependencies](#dependency); tasks with no edge between them and no
[overlap](#overlap) are eligible to run concurrently.

## Write-claim (ownership)

The set of path globs a Builder task may create or modify. Everything outside
the claim is read-only to that Builder. A Builder that needs a path outside its
claim **stops and hands back** — it never edits unowned files, and never
expands its own claim. The Queen adjudicates: widen the claim and re-dispatch,
or re-decompose. Read-only tasks declare no write-claim.

## Overlap

Two tasks overlap when their write-claim globs can match a common file (glob-set
intersection). Overlapping tasks are **sequenced, never parallelized** —
worktrees prevent branch collisions, not two workers rewriting the same module.
Distinct from [dependency](#dependency).

## Dependency

An explicit ordering edge: task A depends on task B when A must not start until
B has finished (producer-before-consumer). Answers *who runs first*; overlap
answers *who cannot run together*. The two are tracked separately.

## Shared surface

A path that collides across almost any decomposition — lockfiles, generated
code, barrel files, migrations, config. The set is named in the project profile.
Any task touching a shared surface is auto-serialized (treated as overlapping
with everything); where the Queen can foresee the churn, it is hoisted into a
dedicated up-front task so downstream Builders never race it.

## Handback

What a bee returns to the Queen. It *is* the worker's final message (a subagent's
final text is its return value), shaped as a **fixed markdown envelope**: a
mandatory skeleton — Task, Outcome, Summary, Location, Gates, Assumptions,
Unknowns — invariant across every role, with a role-specific payload section
slotted in. Material the Queen needs to route is inline; bulky raw material
spills to `.hive/runs/` and is carried as a pointer. Evidence is cited by
`path:line` (code) or URL + version (external facts); the Unknowns section is
never silently empty.

## Outcome verdict

The routing signal in every handback's envelope, one of four values:
`complete`, `complete-with-doubts` (done, but flags a doubt for Guard),
`blocked` (couldn't finish inside its [write-claim](#write-claim); names what it
needs — the Queen widens the claim or re-decomposes), `failed` (hard failure
needing diagnosis or re-decomposition). `blocked` and `failed` route
differently and are never collapsed.

## Run

One invocation of `/hive:run` on a loose ask: scout → align → build → QA loop →
integrate. It ends in a **terminal state** — **landed** (all tasks merged onto a
green integration branch, handed to the human to push) or **halted** (stopped at
an escalation the human chose not to continue — or, in a
[pre-approved run](#pre-approved-run), at any escalation). The Queen closes a run with a
one-screen outcome summary, the mirror of the align checkpoint.

## Integration

How the Queen lands green worktrees. She merges each Builder branch, in
**dependency order** (shared-surface/foundational first, then smallest/lowest-
risk), into a **dedicated local integration branch** — never the trunk, never
pushed. It starts from the [integration base](#ticketed-run). Gates re-run after
each merge; a merge that breaks a
previously-green gate is rolled back and the later task re-opened through the
[QA loop](#qa-loop). The Queen executes the merges (orchestration, not
authoring) but **never resolves a code conflict herself** — that re-opens the
later Builder, rebased. **Nothing in Hive pushes**: the push / PR is the human's
alone, the one irreversible act, confirmed once on the finished batch.

## Ticketed run

A [run](#run) invoked with a ticket ID (`--ticket <id>`), whose integration
branch carries that ID. Its **integration base** — the commit the integration
branch starts from — is trunk's tip, unless the ticket's branch already exists
(e.g. a draft PR opened before the build); then the run **builds onto** that
branch, and its tip at that moment is the **opening tip**, below which the run
never moves the branch. An unticketed run's base is always trunk.

## Pre-approved run

A [run](#run) whose decomposition was approved **before** it started: an outside
caller supplies a brief someone already approved (behaviour, acceptance criteria,
out of scope), and the repo or the invocation opts in. The brief stands in for both
human gates, and any escalation **ends the run** rather than waiting for a human.
The opposite is an **interactive** run. Neither mode lets Hive push, merge to trunk,
or open a PR.

## Run state

What a [run](#run) writes to `.hive/runs/<runId>/` (gitignored) — the disk-backed
record that lets a crashed session re-adopt in-flight work and makes a detached
fleet an additive change later. Directory per run: `run.json` holds the **plan**
(the aligned decomposition — ids, goals, owns, deps, acceptance criteria,
immutable per align) and `tasks/<id>.json` holds each task's **live state**
(status, timestamps, gates, verdict, findings, worktree/branch) — no field in
both. The **Queen is the sole writer** (workers return handbacks, she persists;
Builder diffs stay in git, not here), so concurrent finishes are serialized
writes to distinct files. A task's status (`ready`/`dispatched`/`in-qa`/
`blocked`/`landed`/`failed`) plus its timestamps are the substrate for detecting
a silent (dead/hung) worker.

## Concurrency cap

The limit on how many **Builders** run at once — a fixed default (~3),
profile-set (`maxConcurrentBuilders`) with a per-run override. Read-only bees
(Scout/Forager/Guard) aren't throttled by it but still count toward the harness's
hard ceiling of 20 concurrent subagents. Because the harness has **no queue**
(a 21st dispatch errors), the Queen self-throttles: eligible tasks beyond the cap
wait in the `ready` state and she admits the next as each worker finishes. A
~16-total internal backstop guards the no-queue edge; the Builder cap is the real
governor and keeps a run far below 20. The cap is a *scheduling* knob — it shows
in the align view but never changes what the human approves.

## QA loop

The autonomous cycle after a Builder hands back: Guard reviews the worktree and
returns findings; blocking findings route back to the **same Builder**
(`SendMessage`, worktree + context intact; fresh-into-the-same-worktree as
fallback) for a fix round; Guard re-reviews. Runs AFK between two human
gates — the align checkpoint on entry, integration on exit (a pre-approved run
has neither). Bounded by a
trend-aware round cap (default ~2, profile-overridable): extended a round while
blocking findings shrink, escalated early when they don't. Escalation hands up
to the Queen to re-examine the premise and, if the task is mis-scoped,
re-decompose (a shape change → re-align). A `failed` [verdict](#outcome-verdict)
skips the loop straight to escalation. In a pre-approved run an escalation ends
the run rather than handing up to a human.

## Severity gate

How Guard's findings decide landing: **blocker** and **major** block; **minor**
and **nit** are advisory (reported, never blocking). Severity maps to
consequence — blocker = wrong/broken, major = violates a hard convention or a
stated acceptance criterion, minor/nit = would-improve. Acceptance-criteria
misses are always ≥ major. A clean result is reportable as clean: zero findings
is a valid, good outcome, and inventing nits to look useful is itself a defect.

## Acceptance criteria

The verifiable conditions a Builder task must satisfy. Mandatory on every
Builder task; it is what Guard checks against and what makes a handback
judgeable. A task too small to state a criterion for is too small to be its own
dispatch.
