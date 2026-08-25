# Hive design principles

The small set of rules every role and skill is an application of. When a change is
proposed, check it against these. Vocabulary is fixed in
[`CONTEXT.md`](../CONTEXT.md); the standing policy they encode is the spec's "one
fixed mode" — no autonomy modes, no per-run trust dials.

## 1 · The Queen never writes code

Orchestration and authorship are separate seats. The Queen scouts, decomposes,
aligns, dispatches, persists, throttles, and merges — all orchestration. **Mutation,
and every conflict resolution, happens only inside a Builder, only in an isolated
worktree.** This keeps every source change auditable in one place.

## 2 · Separation of find and fix

The bees that *find* problems never *fix* them. The Guard gatekeeps, the Scout recons,
the Forager researches — and all hand findings to the **Builder**, the only role that
mutates. A finder that can't quietly patch its own finding has to make the case.

## 3 · Read-only is a hard boundary, enforced two ways

A role that shouldn't change the repo can't. Scout / Forager / Guard have their write
tools stripped in frontmatter (Forager has no Bash at all); the Builder's write-claim
is a prompt wall it keeps by **stopping and handing back**. Tool-scoping is the
enforcement; prompt discipline is the first line. See
[`roles.md`](roles.md#two-walls-enforced-differently).

## 4 · Distill, don't dump

A bee exists so its raw material never reaches the Queen's context. The Scout reads the
codebase and returns structured recon; the Forager reads whole doc sites and returns a
cited brief; every bee loads only the architecture-map **slices** its task touches.
Return the conclusion and the evidence for it — not the pile it came from.

## 5 · Cite or flag — never guess

Every load-bearing claim carries evidence: `path:line` for code, `URL + version` for
external facts. A clearly flagged unknown beats a confident guess, so the handback's
**Unknowns section is never silently empty**. A clean result is reportable as clean —
inventing a nit to look useful is itself a defect.

## 6 · Humans own the irreversible

Hive never pushes, merges to trunk, or opens a PR. Integration lands on a *local*
branch the Queen hands you; **the push is yours**, confirmed once on the finished
batch. Autonomy is bounded to the reversible.

## 7 · Profile-driven, never hardcoded

The flow is universal; the project-specific knowledge (gates, trunk, conventions,
codegen, shared surfaces, protected paths) lives in a committed
[`.hive/profile.json`](profile.schema.json). No skill or agent hardcodes a command or a
convention — it reads it from the profile. This is what lets the same hive run in any
repo. A missing gate is reported, never invented; a stale gate fails loud.

## 8 · Overlap sequenced, gates re-run, deps ordered

Overlapping tasks are **sequenced, never parallelized** (worktrees stop branch
collisions, not two workers rewriting a module). Gates **re-run after every merge** —
green in isolation is not green together. These are structural, not advisory.

## 9 · Effectiveness outweighs speed

The tie-breaker. The judgment roles run at the session's model even when a cheaper one
would be faster; the QA loop reads the *trend* and re-opens the plan rather than
grinding a Builder against a wrong premise. When effectiveness and speed conflict,
effectiveness wins.
