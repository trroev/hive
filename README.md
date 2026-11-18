# Hive 🐝

A personal orchestration crew for Claude Code. Your main session is the **Queen**:
she holds the plan, decomposes a loose ask into tasks with declared file-ownership
boundaries, dispatches background worker bees into isolated git worktrees, runs an
autonomous QA loop, and sequences the landings herself — handing you a green branch
to push. The project-specific knowledge (gates, trunk, conventions, codegen) lives
in a committed `.hive/` profile, so the same flow runs in any repo.

## The roster

| Bee | Job |
| --- | --- |
| **Queen** | Your session. Holds the plan; decomposes, dispatches, integrates. Never writes code, never pushes. |
| **Scout** | Read-only internal recon. Sweeps the codebase, returns structured findings the Queen decomposes from. |
| **Forager** | Read-only external research. Docs, web, MCP — returns a distilled, cited brief. |
| **Builder** | The only mutating role. One per isolated worktree; runs the gates, never pushes. |
| **Guard** | Read-only gatekeeper. Runs the gates, returns severity-ranked findings, cannot fix. |

Full charges: [`reference/roles.md`](reference/roles.md) and the per-bee files in
[`agents/`](agents/).

## Install

Hive ships its own marketplace from this repo:

```bash
claude plugin marketplace add trroev/hive
claude plugin install hive@hive
```

Developing Hive itself? Run a local checkout instead — see
[Dogfooding](#dogfooding-run-hive-on-hive).

## Commands

| Command | What it does |
| --- | --- |
| `/hive:init` | Detect the toolchain, confirm it in one pass, and write a committed `.hive/` profile + architecture map so Hive can run here. Idempotent — re-run to re-detect and diff. |
| `/hive:run <ask>` | The Queen's charge — scout, decompose, align with you, dispatch the bees, run the QA loop, integrate. |
| `/hive:status` | Read-only glance at the current run — a per-task table, gates, and what's next. |
| `/hive:resync` | Regenerate the architecture map when the codebase has drifted. The map-only half of `init`. |

## Quickstart

```bash
# 1. Prime the repo once — detect → confirm → commit .hive/profile.json + architecture.md
/hive:init

# 2. Hand the Queen a loose ask
/hive:run Add a password-reset flow (request + confirm + email)

# 3. She scouts, then shows you a one-screen plan. Approve / amend / reject. (gate 1)
# 4. Bees build in isolated worktrees; the Guard reviews; fixes route back — all AFK.
# 5. She merges the green branches onto a local <type>/<slug> branch and hands it back. (gate 2)

# Peek any time, without disturbing the run:
/hive:status
```

## The two human gates

Everything between them runs autonomously — the only thing that pulls you back in
mid-flight is an **escalation** (a plan that needs rethinking), which is itself a gate.

- **Align** (entry) — the Queen renders the whole decomposition on one screen and you
  approve it *before any bee is dispatched*. Nothing builds against a plan you haven't seen.
- **Integration** (exit) — one confirmation on the finished, green batch.

**The push is yours.** Nothing in Hive pushes. The Queen merges onto a *local*
`<type>/<slug>` branch — never the trunk, never pushed — and hands it to you. The
push / PR is the one irreversible act, and it is yours alone. (She also never resolves
a merge conflict by hand — that re-opens the later Builder, rebased.)

**Landing on a ticket's branch.** Pass `--ticket <id>` (e.g. `/hive:run --ticket PROJ-42
add a phone field`) and the branch is named from `profile.ticketBranchTemplate` (default
`{type}/{ticketId}-{slug}` → `feature/PROJ-42-phone-field`). If that branch already
exists — locally or on the remote, say because a draft PR is already open on it — the
Queen builds onto it, leaving its commits intact, instead of branching from trunk. You
still push it.

## Dogfooding — run Hive on Hive

To run a local checkout while developing the plugin:

```bash
claude --plugin-dir ~/Developer/Personal/hive
```

After editing a skill or agent, hot-reload without restarting the session:

```
/reload-plugins
```

The local `--plugin-dir` install namespaces under `hive:` and does not touch any other
installed plugin (crew, trroev-skills, …) — those live in the plugin cache independently.

> Note: this repo is a prose/plugin repo with no JS toolchain, so `/hive:init` here
> detects `trunk: main` and **no gates** (there is no `package.json`). A run in *this*
> repo therefore has no mechanical gates for the Guard to run — it reviews against
> acceptance criteria and conventions only. Point Hive at a repo with real gates to
> exercise the full loop.

## Testing — self-testing a plugin made of prose

Hive's behavior lives in prose (skills + agents), so its regression harness guards
the prose. Two layers, both wired into CI ([`.github/workflows/evals.yml`](.github/workflows/evals.yml),
[ADR-0013](docs/adr/0013-eval-harness.md)):

```bash
# 1. Static invariant check — deterministic, zero deps, runs today.
#    Fails (exit 1) naming the exact rule if a load-bearing lifecycle invariant
#    is deleted or reworded past recognition.
bash scripts/check-invariants.sh

# 2. Behavioral suite — `claude plugin eval`, one case per lifecycle phase
#    (decompose → dispatch → QA → integrate). Costs tokens; see evals/README.md.
claude plugin eval . --scaffold --ablation with-without --no-publish
```

Both cover the same four phases. See [`evals/README.md`](evals/README.md) for the
case-by-case map and how to demonstrate the harness catching a deliberate regression.

## Reference

Agent-facing durable docs — what the skills and bees point at:

- [`CONTEXT.md`](CONTEXT.md) — the domain glossary (the ubiquitous language)
- [`reference/roles.md`](reference/roles.md) — the five role charges, the walls, the model framing
- [`reference/lifecycle.md`](reference/lifecycle.md) — one run end to end, and the two human gates
- [`reference/ownership.md`](reference/ownership.md) — decomposition, overlap vs dependency, shared surfaces, the write-claim
- [`reference/handback.md`](reference/handback.md) — the fixed envelope every bee returns
- [`reference/PRINCIPLES.md`](reference/PRINCIPLES.md) — the design principles Hive is built on
- [`reference/run-state.md`](reference/run-state.md) — the on-disk run-state schema
- [`reference/profile.schema.json`](reference/profile.schema.json) · [`profile.example.json`](reference/profile.example.json) — the profile contract + a filled example

## Layout

```
.claude-plugin/plugin.json        # plugin manifest (semver)
.claude-plugin/marketplace.json   # marketplace served from this repo
skills/{run,status,init,resync}/  # Queen verbs — human-invoked (/hive:*)
agents/{scout,forager,builder,guard}.md  # the bees — Queen-invoked
reference/                        # agent-facing durable docs (schema + prose)
scripts/check-invariants.sh       # deterministic prose-regression guard (self-test)
evals/                            # `claude plugin eval` behavioral suite (self-test)
.github/workflows/evals.yml       # CI: invariant check (every PR) + eval suite (main/manual)
.hive/                            # committed per-project profile + architecture map (per repo)
```

Plugin semver (in `plugin.json`) is separate from `hiveProfileVersion`, which versions
the `.hive/` profile schema. A breaking schema change bumps the profile version;
re-running `/hive:init` detects, diffs, and migrates an old `.hive/`.

## License

[MIT](LICENSE)
