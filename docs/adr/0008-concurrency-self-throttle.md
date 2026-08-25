# Concurrency: a fixed Builder cap with Queen self-throttle

The Claude Code harness caps simultaneous subagents at 20 with **no queue** (a
21st dispatch errors). Hive governs beneath that with a **fixed cap on concurrent
Builders** (default 3; `profile.maxConcurrentBuilders`, overridable per run by a
flag). Because there is no harness queue, the **Queen self-throttles**: eligible
tasks beyond the cap wait in the `ready` state and are admitted as workers
finish. Read-only bees are not throttled by the cap but still count toward the
harness's 20; a conservative ~16-total backstop guards the no-queue edge.

**Why:** the real bottleneck on parallel Builders is human review capacity and
decomposition coherence, not raw compute — a small legible cap beats a clever
governor, and token accounting is deferred to the backlog. The harness won't
block for us, so the Queen's own dispatch loop must be the throttle.

**Rejected:** a token-spend or CPU governor (complex, and mis-aimed at the actual
bottleneck); leaning on the harness to queue excess dispatches (it errors
instead).

See `CONTEXT.md` (Concurrency cap).
