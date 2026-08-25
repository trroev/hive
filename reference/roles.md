# The roster — role charges

The five roles of the hive and what each is chartered to do. This is the durable
overview; each bee's full charge lives in its agent file, and every capitalised
term is defined once in [`CONTEXT.md`](../CONTEXT.md). Roles summarised here, not
restated — follow the pointers for the operational detail.

## Queen — the orchestrating main session

The Queen is **your session**, not a subagent, so she has no agent file: her
charge is the [`run`](../skills/run/SKILL.md) skill. She scouts, proposes a
decomposition, aligns it with you, dispatches the bees, runs the QA loop, and
integrates. She **never writes code, never pushes, merges, or opens a PR** — she
orchestrates. She runs on whatever model your session runs.

## The four bees

Each bee has an agent file (its full charge) and is dispatched by the Queen via
the `Agent` tool under `subagent_type: "hive:<role>"`. Domain expertise is not a
per-bee file — it arrives **at dispatch** as a bundle: projected profile fields +
doc pointers (`conventions`) + the architecture-map slices the task touches.

| Bee | Writes? | Model / effort | Charge | File |
| --- | --- | --- | --- | --- |
| **Scout** | no (wall) | inherit / high | survey this repo's terrain; hand back recon the Queen decomposes from | [`agents/scout.md`](../agents/scout.md) |
| **Forager** | no (wall) | sonnet / medium | answer a scoped *external* question with a distilled, cited brief | [`agents/forager.md`](../agents/forager.md) |
| **Builder** | yes (claim) | inherit / medium | implement one task in an isolated worktree; run gates; hand back | [`agents/builder.md`](../agents/builder.md) |
| **Guard** | no (wall) | inherit / high | review a worktree against acceptance criteria + conventions; ranked findings | [`agents/guard.md`](../agents/guard.md) |

## Two walls, enforced differently

See [Read-only wall vs write-claim](../CONTEXT.md#read-only-wall-vs-write-claim).

- **Read-only wall** (Scout / Forager / Guard) — enforced *by construction*. Their
  frontmatter strips `Edit`/`Write`/`NotebookEdit`; Forager also has no `Bash`. A
  finder that cannot quietly patch its own finding has to make the case.
- **Write-claim** (Builder) — a *prompt* wall the harness cannot enforce. A Builder
  that needs a path outside its [write-claim](../CONTEXT.md#write-claim-ownership)
  **stops and hands back `blocked`**, naming the path; it never edits an unowned
  file or widens its own claim.
- **The `Agent` tool is stripped from every bee** — only the Queen dispatches, so
  the fleet never nests (depth stays at 2).

## Model framing: inherit, don't pin

The judgment bees (Scout / Builder / Guard) carry `model: inherit` — they ride
whatever model your session runs, so the Queen never hardcodes a strong model at
dispatch. **Forager is the one exception**: a low-judgment fetch-and-distill role,
it pins `sonnet`. Effort and these model choices are frontmatter defaults,
overridable per project via the profile.
