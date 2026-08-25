---
name: resync
description: "Regenerate the Hive architecture map (.hive/architecture.md) for the current project and re-stamp it to HEAD. Use when the codebase has drifted enough that the map is stale, or after a big refactor or merge. The arch-map-only half of /hive:init."
---

# hive:resync

Refresh the committed architecture map and re-stamp it to the current commit. `resync` is
the **arch-map-only** regeneration — the profile is untouched. It is the subset `/hive:init`
runs for the map half on a re-run; reach for `resync` directly when only the map is stale.

## 1 · Precondition

Read `${CLAUDE_PROJECT_DIR}/.hive/profile.json`. If there is no profile, this repo was
never primed — tell the user to run `/hive:init` first and stop.

Show the drift: compare the map header's `generatedAtSha` against `git rev-parse HEAD`.
If they already match and no big change is known, say the map is fresh and confirm the user
still wants to regenerate before spending the survey.

## 2 · Survey → write

Regenerate `.hive/architecture.md` the same way `init` first generated it: a Scout survey
the Queen writes up, using `${CLAUDE_PLUGIN_ROOT}/reference/architecture.template.md` — a
slice TOC (path-globs → per-subsystem slices) plus the commit-SHA stamp.

Dispatch the Scout read-only in survey mode (`Agent` tool, `subagent_type: "hive:scout"`);
the Queen writes its recon handback into the map. If the Scout cannot be dispatched, the
Queen surveys herself **read-only** (Read/Grep/Glob; no source writes) and fills the
template, noting which path was used. Never fabricate Scout output — dispatch the real
agent or run the read-only bootstrap.

Writing the map is a Queen-driven maintenance write and the only sanctioned rewrite of this
file: mid-run a read-only Scout reports drift in its handback but never rewrites the map.

## 3 · Re-stamp

Record the current commit as `generatedAtSha` in the map's `hive:arch-map` header:

```bash
git rev-parse HEAD
```

The stamp lives in the map header, not the profile — the profile deliberately holds neither
the map nor its stamp.

## 4 · Done

Summarize what changed in the map (which slices moved) and offer to commit
`.hive/architecture.md`. `.hive/architecture.md` is committed and lands like any other
change — do not commit without the user's ok, and never push.
