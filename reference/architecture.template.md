<!--
  TEMPLATE for .hive/architecture.md — the committed architecture map.
  Written ONLY by /hive:init (first generation) and /hive:resync (regenerate + re-stamp).
  It is a refreshed-on-read PRIOR, never a source of truth: the code is always the truth.
  Copy this shape, fill the slices from the Scout survey, and stamp the header to HEAD.
  Delete this comment block in the real file.
-->
# Architecture map — <project name>

<!-- hive:arch-map
generatedAtSha: <full 40-char SHA from `git rev-parse HEAD`>
generatedAt: <ISO-8601 timestamp>
hiveProfileVersion: 1
-->

> Stamped to `<short-sha>`. Drift = this stamp vs `HEAD`. Regenerate with `/hive:resync`.
> A prior, not the truth — a Scout validates the one slice it touches against live code
> and reports drift in its recon handback; it never rewrites this file mid-run.

## Table of contents

Slice-addressable: the Queen maps a task's write-claim globs through this table to name
the slice(s) a bee loads. Granularity is per major subsystem/module — not per-file (rots
instantly), not whole-repo (defeats the point).

| Slice | Path globs | One-line summary |
| --- | --- | --- |
| <slice-id> | `<glob>`, `<glob>` | <what this subsystem is> |
| … | … | … |

## <Slice 1 name>

**Owns:** `<glob>`, `<glob>`

<How this subsystem fits together: entry points, key modules, data flow, the seams a
Builder or Guard needs to know before touching it. Cite `path:line` where a claim is
load-bearing. Keep it orientation, not a file listing.>

## <Slice 2 name>

**Owns:** `<glob>`

<…>

## Cross-cutting notes

<Shared surfaces, codegen boundaries, and any repo-wide conventions a slice-local reader
would miss. Point at profile fields and convention docs rather than restating them.>
