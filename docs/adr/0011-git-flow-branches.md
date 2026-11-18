# Integration branches use git-flow names; commits follow Conventional Commits

Status: refines ADR-0005 (integration). Extended by ADR-0014 (ticket-aware branches).

Integration branches derive from a configurable `profile.integrationBranchTemplate`
(default `{type}/{slug}`, where `{type}` — feature/fix/hotfix/chore — is inferred
from the ask), yielding names like `feature/contact-phone-field`. Builders commit
in **Conventional Commits**, and integration prefers a **fast-forward** so a run's
history stays the Builder's clean `feat`/`fix` commits — a merge commit is made
only when branches diverged, and then with a Conventional-Commits message rather
than a bare `merge(...)` type. The `runId` still keys `.hive/runs/`, and the
chosen branch name is recorded in `run.json.integrationBranch`.

**Why:** the original scheme named integration branches `hive/run-<timestamp>`
and produced `merge(t1):` merge commits — the first real dogfood (a phone-field
change in the `portfolio` repo) surfaced both as non-standard. Standard git-flow
branch names and Conventional-Commits history are the house convention.

**Rejected:** keeping the timestamped scheme (available via the template override
`"hive/run-{runId}"` for anyone who wants it); invoking the interactive `/commit`
skill from inside a bee (it blocks on confirmation mid-loop — bees honor its
*format* instead).
