---
name: init
description: "Set up a repo for Hive: detect the toolchain, confirm it in one pass, and persist a committed .hive/ profile + architecture map so /hive:run can work here. Use for 'set up hive', 'hive init', 'profile this project', or the first time Hive runs in a repo. Idempotent — re-run to re-detect and diff."
---

# hive:init

Prime the hive for this repo. `init` writes the two committed artifacts every cold
worker reads — `.hive/profile.json` (the cold-start facts) and `.hive/architecture.md`
(the refreshed-on-read map) — in **one detect-then-confirm pass**: the Queen drafts
everything mechanically, you approve or amend before anything is written.

Run once per project; re-run whenever the toolchain shifts. `init` ⊇ `resync`: on a
re-run it re-detects the profile, diffs, and regenerates the map (the `resync` half).

Schema and shipped defaults live under `${CLAUDE_PLUGIN_ROOT}/reference/`:
`profile.schema.json`, `profile.example.json`, `shared-surfaces.default.json`,
`architecture.template.md`.

## 0 · First or re-run?

Check for `${CLAUDE_PROJECT_DIR}/.hive/profile.json`.

- **Absent** → first-time init. Draft from scratch (steps 1–5).
- **Present** → re-run. This is **detect-and-diff, never clobber**: run the same
  detection, then in the confirm pass show a field-by-field **diff** of drafted-vs-current
  and let the user accept per field. Regenerate and re-stamp the map (the `resync` half).
  Read the existing `hiveProfileVersion` first — a lower version than the schema's `const`
  means a migration, so call it out explicitly rather than silently overwriting.

## 1 · Detect (mechanical, read-only)

Inspect the repo directly — no writes. Per the fixed detection map (issue 13):

| field | how | heuristic |
| --- | --- | --- |
| `packageManager` | detect | lockfile present (`pnpm-lock.yaml`→pnpm, `package-lock.json`→npm, `yarn.lock`→yarn, `bun.lock*`→bun) or `packageManager` in `package.json` |
| `trunk` | detect | `git symbolic-ref refs/remotes/origin/HEAD` → strip to branch; fallback `main`, then `master` |
| `gates` | detect→confirm | `package.json` scripts whose names match lint / typecheck (or `types`/`tsc`) / test / build. Record as `<pm> <script>` |
| `codegen` | detect→confirm | scripts matching `generate*` / `codegen` |
| `sharedSurfaces` | default+detect→confirm | shipped default set ∪ the repo's actual lockfile ∪ detected `generated` paths |
| `generated` | detect→confirm | known codegen output paths (e.g. `**/payload-types.ts`, import maps) inferred from the codegen scripts |
| `protectedPaths` | default+ask | `.env*` default; anything else is intent, so ask |
| `conventions` | detect | presence of `CLAUDE.md` / `AGENTS.md` / a `docs/` conventions file |
| `maxConcurrentBuilders` | default | `3` (confirm) |
| architecture map | generate | Scout survey (step 3) |

Concrete commands (read-only): `ls` for lockfiles, `cat package.json` (or Read) for
scripts and `packageManager`, `git symbolic-ref refs/remotes/origin/HEAD` for trunk,
`ls CLAUDE.md AGENTS.md` for conventions. Seed `sharedSurfaces` from
`${CLAUDE_PLUGIN_ROOT}/reference/shared-surfaces.default.json`, then union in the lockfile
that actually exists and any `generated` paths you detected.

**Fail-safe while detecting:**
- A gate the repo has no script for is **omitted** — never invent a command. It is
  reported at run time, not fabricated here.
- Detect facts; do not run gates or codegen during init.

## 2 · Draft the profile (guess-and-confirm the fuzzy fields)

Build a full draft in memory. For each field:

- **Confident detections** (`packageManager`, `trunk`, matched `gates`) — draft the value,
  batch-confirm.
- **Fuzzy fields** (`sharedSurfaces`, `generated`, `codegen`) — **draft a best guess and
  flag it** for review. Never silently blank-and-hide.
- **Undetectable-by-nature** (`protectedPaths` beyond `.env*`) — draft the default and ask.
- **No reasonable guess** — leave the field blank with a **visible note** in the confirm
  pass. `init` never blocks on ambiguity; the profile fail-safe turns a blank gate into a
  run-time report, not a fatal error.

Match the shape in `reference/profile.example.json`. `conventions` is a **pointer list**,
never a restatement.

## 3 · Architecture map (Scout survey → Queen writes)

The map is generated, not detected: dispatch a **Scout** to survey the terrain, then the
**Queen writes** `.hive/architecture.md` from the Scout's recon using
`${CLAUDE_PLUGIN_ROOT}/reference/architecture.template.md` — a slice TOC (path-globs →
per-subsystem slices) plus a commit-SHA stamp. This is `init`'s one real token cost, paid
once and amortized by the refreshed-on-read model thereafter.

Dispatch the Scout read-only in survey mode (`Agent` tool, `subagent_type: "hive:scout"`)
with the write-claim-to-slice framing above; the Queen writes its recon handback into the
map. If the Scout genuinely cannot be dispatched, the Queen surveys **herself, read-only**
(Read/Grep/Glob only; no source writes), fills the template, and notes in the confirm pass
that the map was bootstrapped without a Scout. Never fabricate Scout output — dispatch the
real agent or run the read-only bootstrap survey, and say which was used.

Stamp the map header to the current commit:

```bash
git rev-parse HEAD
```

Record it as `generatedAtSha` in the map's `hive:arch-map` header (the profile deliberately
does **not** hold the map or its stamp — drift is header-vs-HEAD).

## 4 · Confirm — one reviewable screen

Present the whole draft on **one screen** for edit/confirm:

- The drafted profile (all fields), fuzzy guesses and blank-with-note fields flagged.
- The generated map's **slice TOC** (not the whole map body).
- On a **re-run**, a field-by-field **diff** vs the current profile, plus the map re-stamp.

The user edits/confirms before anything lands. This mirrors the align-checkpoint
philosophy: the machine drafts, the human approves before commit. Not silent (a wrong
`trunk` or `gate` would invisibly poison every run), not per-field interrogation.

## 5 · Persist

Only after confirmation:

1. Write `${CLAUDE_PROJECT_DIR}/.hive/profile.json`. **Validate against**
   `${CLAUDE_PLUGIN_ROOT}/reference/profile.schema.json` (`hiveProfileVersion`, `trunk`,
   `gates` are required; `additionalProperties` is false — no stray keys). Omit any gate
   the repo lacks; omit `sharedSurfaces` only if you intend the shipped-default fallback
   (otherwise write the seeded set).
2. Write `${CLAUDE_PROJECT_DIR}/.hive/architecture.md` from the template, stamp included.
3. `.hive/profile.json` and `.hive/architecture.md` are **committed** artifacts;
   `.hive/runs/` is gitignored (already in `.gitignore`). Show the final profile and offer
   to commit both — do not commit without the user's ok, and never push.

## 6 · Done

Tell the user Hive is primed and they can run `/hive:run <loose ask>` here. Point at
`/hive:resync` for refreshing the map when the codebase drifts from the stamp.
