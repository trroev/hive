# Architecture map — hive

<!-- hive:arch-map
generatedAtSha: fdfa179b469699df6e93f829b86763195e25ef30
generatedAt: 2026-11-18T17:55:07Z
hiveProfileVersion: 1
-->

> Stamped to `fdfa179`. Drift = this stamp vs `HEAD`. Regenerate with `/hive:resync`.
> A prior, not the truth — a Scout validates the one slice it touches against live code
> and reports drift in its recon handback; it never rewrites this file mid-run.

This repo **is** the Hive Claude Code plugin. It is made of prose — skills, agent
definitions, reference contracts, ADRs — guarded by a deterministic grep script
(the only mechanical gate) and a manual `claude plugin eval` suite. No
`package.json`, no lockfile, no codegen.

## Table of contents

| Slice | Path globs | One-line summary |
| --- | --- | --- |
| queen-run | `skills/run/**` | The Queen's whole run lifecycle (§0–§10 + Guardrails) |
| profile-map | `skills/init/**`, `skills/resync/**`, `reference/profile.*`, `reference/shared-surfaces.default.json`, `reference/architecture.template.md` | Priming a repo: the profile contract and the architecture map |
| run-state | `reference/run-state.md`, `skills/status/**` | The on-disk run schema and its read-only renderer |
| bees | `agents/**`, `reference/roles.md`, `reference/handback.md` | Bee charges, frontmatter walls, the handback envelope |
| doctrine | `CONTEXT.md`, `reference/PRINCIPLES.md`, `reference/lifecycle.md`, `reference/ownership.md`, `docs/adr/**` | Glossary, principles, ADRs |
| invariants | `scripts/check-invariants.sh` | The deterministic prose-regression grep, the required CI check |
| evals | `evals/**` | Behavioral `claude plugin eval` cases plus fixtures |
| packaging-ci | `.claude-plugin/**`, `.github/**`, `README.md`, `SECURITY.md`, `LICENSE`, `.gitignore` | Manifest, CI, user-facing docs |

## queen-run

**Owns:** `skills/run/**`

- One long file, `skills/run/SKILL.md`, numbered §0–§10 plus §1a and Guardrails.
  Evals and other docs cite section numbers — renumbering breaks them.
- 28 of the 34 invariants grep this file (`scripts/check-invariants.sh`). Rewording
  a pinned phrase (e.g. `sequenced, never parallelized`, `auto-serialize`,
  `trend-aware round cap`, `--ff-only`, `Never push`) needs the matching edit in the
  invariants script, in the same change.
- Eval prompts point into specific sections (e.g.
  `evals/integration-ticket-new-branch/prompt.md`,
  `evals/preapproved-escalation-ends-run/prompt.md`).
- The skill writes run-state per `reference/run-state.md`; any field change here
  must land there too.

## profile-map

**Owns:** `skills/init/**`, `skills/resync/**`, `reference/profile.*`,
`reference/shared-surfaces.default.json`, `reference/architecture.template.md`

- Adding a profile field touches: `profile.schema.json` (`additionalProperties:
  false`), `profile.example.json`, the init detection table in
  `skills/init/SKILL.md`, CONTEXT.md "Project profile", and README.
- `"ticketBranchTemplate"` and `"preApproved"` are invariant-pinned schema keys.
- Bumping `hiveProfileVersion` (const 1) means updating the run precondition in
  `skills/run/SKILL.md` §0 and the README versioning note.
- `resync` is init's map-only half; the two skills' Scout-dispatch wording mirrors —
  edit together.

## run-state

**Owns:** `reference/run-state.md`, `skills/status/**`

- Plan (`run.json`, frozen at align) vs live state (`tasks/<id>.json`): no field in
  both. Six task status values.
- `status` renders per the rules in run-state.md; a new field or status value lands
  in `skills/run/SKILL.md`, `skills/status/SKILL.md` and run-state.md together.
- run-state.md links CONTEXT.md heading anchors (`#run`, `#concurrency-cap`) —
  renaming a glossary heading breaks them.

## bees

**Owns:** `agents/**`, `reference/roles.md`, `reference/handback.md`

- The walls live in agent frontmatter and are invariant-pinned: builder
  `isolation: worktree`, `disallowedTools: Agent`, `model: inherit`; scout/guard
  strip Edit/Write/NotebookEdit/Agent; forager also strips Bash and pins
  `model: sonnet`.
- Builder's integration-base wording is invariant-pinned.
- `reference/roles.md` restates the frontmatter — keep it in sync. Model/effort
  are frontmatter-only; the profile has no override (ADR-0009). `handback.md`
  defines the envelope every agent body emits.

## doctrine

**Owns:** `CONTEXT.md`, `reference/PRINCIPLES.md`, `reference/lifecycle.md`,
`reference/ownership.md`, `docs/adr/**`

- CONTEXT.md is the fixed vocabulary skills cite by path; new terms land there first.
- ADRs are sequentially numbered; each new one needs a row in `docs/adr/README.md`.
  Accepted ADRs aren't rewritten — later changes are dated "Update" notes or
  back-links.
- Typical feature footprint (e.g. #16): CONTEXT, PRINCIPLES, lifecycle, run-state,
  schema, run skill, invariants, evals, a new ADR + index row, README.

## invariants

**Owns:** `scripts/check-invariants.sh`

- Each rule is a fixed-string (or `E` regex) assertion against a named file; exits 1
  on any miss. Phrases must sit on one line in the target file — a line break
  inside a pinned phrase fails it.
- Its CI job name is the `protect-main` ruleset's required check — never rename it.

## evals

**Owns:** `evals/**`

- A case is `case.yaml` + `prompt.md` (frontmatter: tags, runs, allowed_tools,
  append_system_prompt) + `graders/*.md` + `scaffold.sh`, or prompt-only with no
  case.yaml (`qa-clean-is-clean`, `integration-never-pushes`).
- Four scaffolds inline a copy of `fixtures/primed-repo`; changing the fixture means
  updating every copy. Scaffolds must `git init -q -b main`.
- A new case needs a row in `evals/README.md` (and, ideally, the regression table).
  Grader-format gotchas are listed there (llm graders: `type`/`weight` only, criteria
  in the body).

## packaging-ci

**Owns:** `.claude-plugin/**`, `.github/**`, `README.md`, `SECURITY.md`, `LICENSE`,
`.gitignore`

- A release is a version bump in `.claude-plugin/plugin.json` only — separate from
  `hiveProfileVersion`.
- Actions are SHA-pinned and Dependabot-managed; the plugin-eval job is manual and
  main-only. `.github/**`, `.claude-plugin/**` and `LICENSE` are `protectedPaths`.
- README's Layout and Reference lists enumerate files — adding a reference doc means
  updating them.

## Cross-cutting notes

- **Shared surfaces** (profile `sharedSurfaces`): the run skill, the invariants
  script, CONTEXT.md, README, evals/README, the ADR directory, run-state.md and the
  profile schema — nearly every feature touches most of them, so most runs here are
  close to sequential.
- **Gate:** the only gate is `bash scripts/check-invariants.sh` (profile `gates`).
  Behavioral evals cost tokens and are not a gate.
- **Machine-local / gitignored:** `.hive/runs/**`, `evals/results/**`, `.DS_Store`.
- **Conventions:** see profile `conventions`; commits are Conventional Commits,
  branches git-flow (ADR-0011).
