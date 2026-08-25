# The decomposition + ownership model

How the Queen splits a run into tasks and keeps two Builders from colliding. Terms
are fixed in [`CONTEXT.md`](../CONTEXT.md); the operational procedure is
[`run`](../skills/run/SKILL.md) §3–4. This is the durable summary of *why* the
model has the shape it does.

## A task, and the decomposition

A [task](../CONTEXT.md#task) is the atomic unit of dispatch: one worker, one role
charge, one handback, sized to a single session. A
[decomposition](../CONTEXT.md#decomposition) is the ordered DAG of tasks the Queen
proposes for a run. Task schema (logical; persisted per
[`run-state.md`](run-state.md)):

- **All tasks:** `id`, `goal` (one line), `role`, `deps` (task ids that must finish
  first).
- **Builder tasks also:** `owns` (write-claim globs), `gates`, `acceptanceCriteria`
  (≥ 1 — a task too small to state a criterion for is too small to be its own
  dispatch).
- **Read-only tasks** (Scout / Forager / Guard) declare **no `owns`** and no
  acceptance criteria.

## Two independent mechanisms — never overload one for the other

The model's core move is keeping *who can run together* and *who runs first* on
separate tracks:

- **[Overlap](../CONTEXT.md#overlap)** = write-claim glob-set intersection, pure path
  math computed before any code is read. Two tasks overlap when some concrete path
  satisfies a glob in each. **Overlapping tasks are sequenced, never parallelized** —
  worktrees stop branch collisions, not two workers rewriting the same module.
- **[Dependency](../CONTEXT.md#dependency)** = explicit `deps` edges, producer before
  consumer. Answers *who runs first*, not *who cannot run together*.

Glob-disjoint tasks with no dependency between them are eligible to run concurrently
(subject to the [concurrency cap](../CONTEXT.md#concurrency-cap)).

## The write-claim wall

A Builder's [write-claim](../CONTEXT.md#write-claim-ownership) is the set of globs it
may create or modify; everything else is read-only to it. This is a **prompt wall**
the harness cannot enforce — so a Builder that needs an unowned path **stops and
hands back `blocked`**, naming it. The Queen adjudicates: widen the claim and
re-dispatch (a disjoint widen is silent + logged), or re-decompose (a shape change
that re-triggers the align checkpoint). A Builder never edits an unowned file and
never widens its own claim.

## Shared surfaces — auto-serialize + hoist

A [shared surface](../CONTEXT.md#shared-surface) (lockfiles, generated code, barrel
files, migrations, config) collides across almost any decomposition. The set is
named in `profile.sharedSurfaces` (fallback: [`shared-surfaces.default.json`](shared-surfaces.default.json)).
Any task touching one is **auto-serialized** — treated as overlapping with
everything. Where the Queen can foresee the churn, she **hoists** it into a dedicated
up-front task so downstream Builders never race it.

`generated` paths are **regenerate-not-edit**: a task that must change one runs the
`codegen` (ordered, before gates), never hand-edits the file.

## The living DAG

The decomposition is living, but a **shape change re-triggers alignment**. Adding,
splitting, or re-ordering tasks, or creating a *new* overlap, bounces back to the
one-screen align checkpoint. Widening a claim *within* a task with no new overlap is
a silent, logged adjustment — no re-align.
