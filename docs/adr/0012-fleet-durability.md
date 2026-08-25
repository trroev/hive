# Fleet durability: stay in-session; the detached fleet stays an unbuilt seam

Spike outcome (issue #1). Hive keeps the **v1 in-session model** — the Queen is
the interactive session (ADR-0002), bees are subagents whose liveness is bound to
it — and does **not** build a detached/durable fleet now. The run-state seam that
was designed to make durability additive (ADR-0006) stays exactly that: designed,
unbuilt, and ready if a real trigger appears.

**Why — workflow fit (the decisive axis).** A run is human-gated at *both* exits:
align on entry, integration on exit (ADR-0004, ADR-0005); only the middle QA loop
runs AFK. A detached fleet's whole value is surviving a closed laptop — but with
the human gone there is no one to approve the decomposition or the landing, so
detachment buys only the middle stretch unattended. That stretch already survives
a crash: a resumed Queen reconstructs the entire DAG, per-task status, worktrees,
branches, commits, gates, and findings from `.hive/runs/` (`run-state.md`). For a
solo, local-git, human-at-the-exits tool the natural unit of work is a sitting —
kick off, approve, let the loop churn in the open session, return to integrate —
which the in-session model fits exactly. The durable options are also cloud
sandboxes, a poor host for the local-worktree integration ritual and the
hand-to-human-to-push finish (ADR-0005). Detaching fights the design, it doesn't
extend it.

**Why — token cost (neutral, no savings).** Every path draws the same per-turn
cost; the only real difference is prompt-cache warmth. An in-session run held
inside one TTL window stays cache-warm; a detached orchestrator that re-hydrates
run-state on each wake pays cold-read overhead — resuming a long conversation
after cache expiry "reprocesses the entire conversation history with no cache
hits… the most expensive request you send." Detachment *adds* re-hydration cost,
it never saves tokens.

**Evidence.** In-flight subagents are bound to the parent session's lifetime and
background Bash is killed ~5s after exit — closing the session does kill live
bees, exactly as `run-state.md` assumes. The only paths that survive a closed
laptop are cloud-hosted: **Routines** (scheduled Claude Code on web) and
**Managed Agents** (beta). The **Agent SDK** can self-host an orchestrator but is
"not a documented orchestration pattern" — you own the persistence, supervisor,
and session store. (Sources: docs.claude.com — sub-agents, headless, routines,
agent-sdk/overview, prompt-caching; platform.claude.com — managed-agents/overview,
retrieved 2026-08-25.)

**Additive confirmed.** A durable mode changes only *one* thing: today a live
handle dies on close and the task is presumed dead → re-dispatched; a durable
fleet would instead let that worker keep running and be re-attached. The status
enum, timestamps, and silence-detection already model a worker whose liveness is
decoupled from the session (`run-state.md`), so the change is a new *re-attach*
capability layered on — no schema rewrite. The path, if ever triggered (builds
that routinely outlast a sitting, or a real want for scheduled/overnight batches),
is **Routines or Managed Agents**, not a self-hosted SDK daemon.

**Rejected:** building a detached/durable fleet for v1 (solves an unfelt problem,
fights the human-gated design, saves no tokens); a self-hosted Agent SDK daemon
(undocumented as orchestration, and shifts persistence/supervision onto us);
removing the align/integration gates to make detachment meaningful (that is a
different product, not Hive).

See `reference/run-state.md` (the additive seam), ADR-0006, ADR-0004, ADR-0005.
Resolving this unblocks issue #7.
