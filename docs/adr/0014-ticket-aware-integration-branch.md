# Ticket-aware integration branches; a ticketed run builds onto an existing branch

Status: refines ADR-0011 (git-flow branches) and ADR-0005 (integration).

A run may be invoked with `--ticket <id>`. The integration branch is then named
from a second profile template, `profile.ticketBranchTemplate` (default
`{type}/{ticketId}-{slug}` → `feature/PROJ-42-contact-phone-field`), and is
treated as the **caller's target**: if it already exists — locally or on the
remote — the Queen integrates onto it instead of creating a branch from trunk. The
existing branch's tip becomes the run's **integration base**
(`run.json.integrationBase`): Builders start their worktrees there, so lands are
fast-forwards unless the branch gains commits mid-run; its gates run before the
first land, and it is the first last-green SHA, so a gate rollback can never
drop the caller's commits. When the ticket branch doesn't exist, or no ticket is
given, behaviour is unchanged (branch from trunk). Gates still re-run after every
merge, and Hive still never pushes — the human (or their tooling) pushes the branch.

**Why:** a software factory opens the draft PR *before* the build so its body can
carry the approved plan; the build must land on that PR's branch, not a sibling.

**Considered:** a `{ticketId}` placeholder in the existing
`integrationBranchTemplate` (rejected — an unticketed run would need rules for
dropping the placeholder and its separators; two templates keep each one total);
adopting *any* pre-existing branch, ticketed or not (rejected — an unticketed
`{type}/{slug}` collision is more likely a stale unrelated branch, so it keeps the
`-2` suffix rule); an explicit `--branch <name>` flag (deferred — the ticket
template reproduces the caller's branch name without one).

**Rejected:** rebasing or resetting the existing branch onto trunk (rewrites the
caller's published history under an open PR); picking a side when the local and
remote copies have diverged (the Queen escalates instead).
