# The Queen is the main session; bees are read-only by construction

The main session **is** the Queen — the orchestrator who never writes code — so
she is not a subagent and has **no agent-definition file**; her charge lives in
the `run` skill. The four **bees** are agent files. Scout, Forager, and Guard
strip `Edit`/`Write`/`NotebookEdit` in frontmatter, making them **read-only by
construction, not by prompt**, and the `Agent` tool is stripped from all four so
**only the Queen dispatches** (no nested fleets). Bees use `model: inherit`; the
one exception is Forager (`sonnet`), the low-judgment fetch-and-distill role.

**Why:** a read-only wall you can trust must be enforced by the harness, not
asked for in prose. Domain expertise arrives as *loaded context named at
dispatch* (profile fields + doc pointers + architecture-map slices), so a role
is a durable lifecycle identity rather than a swarm of near-duplicate files.

**Rejected:** a `queen.md` agent (the main session can't be a subagent);
per-domain agent files (expertise is layered context instead); hardcoding a
strong model per bee (they ride the session model — see ADR-0009's profile
overrides for the escape hatch).

**Update (2026-11-18):** the profile override referenced above was cut in ADR-0009
(a per-role model/effort field was rejected as speculative), so model and effort
stay agent-frontmatter defaults only — there is no per-project escape hatch.

See `reference/roles.md`.
