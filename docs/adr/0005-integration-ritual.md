# Integration lands on a local branch; nothing in Hive pushes

The Queen merges green Builder branches, in dependency order, onto a **local
integration branch** — never the trunk, never pushed. Gates re-run after every
merge; a later merge that reddens a previously-green gate is **rolled back to the
last-green state** and that task is re-opened through the QA loop
(later-merge-owns-the-regression by default). Code conflicts re-open the later
Builder **rebased** — never a Queen hand-edit. The human confirms **once, on the
finished batch**, and owns the push / PR; a run is *done* = landed or halted,
closed with a one-screen outcome summary.

**Why:** "green in isolation is not green together," so the combined tree must be
proven green on a throwaway branch before anything lands. The push is the one
truly irreversible act, so it is the human's alone — running `git merge` locally
is orchestration, not code authoring, so the Queen may do that.

**Rejected:** merging straight to trunk; the Queen resolving code conflicts
herself (she never writes code); Hive pushing or opening PRs.

**Note:** the integration branch *naming* was later revised — see ADR-0011.

See `reference/lifecycle.md`.
