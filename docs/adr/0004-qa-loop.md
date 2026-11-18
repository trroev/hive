# QA loop: same-Builder fix rounds, a trend-aware cap, human at the exits

After a Builder hands back, a Guard reviews its worktree. Blocking findings route
back to the **same Builder** (via `SendMessage`, worktree + context intact — the
worktree is never discarded between rounds). A **severity gate** decides landing:
blocker/major block, minor/nit are advisory, acceptance-criteria misses are ≥
major, and a clean result is reportable as clean. The loop is bounded by a
**trend-aware round cap** (default 2): a shrinking blocking-finding set earns one
round past the cap, a static or growing set escalates before it. The loop runs
**AFK between two human gates** — the align checkpoint on entry, integration on
exit.

**Why:** re-dispatching the same Builder reuses its context and the work in its
worktree — cheap and coherent. A pure count cap abandons a fix that was one round
from done; a pure run-until-clean grinds a Builder against a wrong premise
forever. Escalation re-opens the *decomposition* (a shape change → re-align)
rather than looping on a bad plan.

**Rejected:** a fresh Builder per round (throws away worktree + context);
run-until-clean; a human inside every round (defeats the fleet).

**Note:** in a pre-approved run there is no human to escalate to — an escalation ends
the run with a recorded outcome instead; see ADR-0016.

See `reference/lifecycle.md`.
