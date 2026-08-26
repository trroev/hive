#!/usr/bin/env bash
#
# check-invariants.sh — the deterministic half of Hive's self-test harness.
#
# Hive is a plugin made of prose: its behavior lives in skill/agent markdown, so
# a load-bearing rule can silently regress with a careless edit and nothing
# catches it. This script asserts that each such rule is still present in the
# text, grouped by the four lifecycle phases (decompose → dispatch → QA →
# integrate). It is the layer that runs *today* — zero deps, deterministic, free
# — alongside the richer `claude plugin eval` suite in evals/ (see evals/README.md).
#
# A row asserts a short "term of art" — a distinctive phrase a benign rewording
# would keep but a real regression (deleting the rule) would drop. Any miss is a
# regression: the run reports it and exits 1.
#
# Usage:   bash scripts/check-invariants.sh
# Exit:    0 = every invariant intact · 1 = one or more regressed
#
set -u

# Repo root = the parent of this script's dir, so the check runs from anywhere.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || { echo "cannot cd to repo root: $ROOT" >&2; exit 1; }

pass=0
fail=0

# assert PHASE FILE "label" "pattern" [mode]
#   mode: F (fixed string, default) | E (extended regex)
assert() {
  local phase="$1" file="$2" label="$3" pattern="$4" mode="${5:-F}"
  local found=1
  if [ ! -f "$file" ]; then
    printf '  \033[31mFAIL\033[0m [%s] %s\n        missing file: %s\n' "$phase" "$label" "$file"
    fail=$((fail + 1))
    return
  fi
  if [ "$mode" = "E" ]; then
    grep -qE -- "$pattern" "$file" && found=0
  else
    grep -qF -- "$pattern" "$file" && found=0
  fi
  if [ "$found" -eq 0 ]; then
    printf '  \033[32mok\033[0m   [%s] %s\n' "$phase" "$label"
    pass=$((pass + 1))
  else
    printf '  \033[31mFAIL\033[0m [%s] %s\n        %s no longer matches: %s\n' \
      "$phase" "$label" "$file" "$pattern"
    fail=$((fail + 1))
  fi
}

RUN="skills/run/SKILL.md"
BUILDER="agents/builder.md"
SCOUT="agents/scout.md"
GUARD="agents/guard.md"
FORAGER="agents/forager.md"

echo "Hive invariant check — the lifecycle rules that must not regress"
echo

# ── DECOMPOSE ────────────────────────────────────────────────────────────────
# The Queen turns a loose ask into an aligned DAG; these are the rules that keep
# that decomposition safe and human-gated.
assert decompose "$RUN" "precondition: unprimed repo → run /hive:init first and stop" \
  'run `/hive:init` first and stop'
assert decompose "$RUN" "overlap is sequenced, never parallelized" \
  'sequenced, never parallelized'
assert decompose "$RUN" "shared surfaces auto-serialize" \
  'auto-serialize'
assert decompose "$RUN" "the align checkpoint gates all dispatch" \
  'Never dispatch before align'

# ── DISPATCH ─────────────────────────────────────────────────────────────────
# Only the Queen dispatches; bees are walled by construction. These live in the
# agent frontmatter (the enforcement) plus the run skill's throttle.
assert dispatch "$BUILDER" "Builder runs in an isolated worktree" \
  'isolation: worktree'
assert dispatch "$BUILDER" "Agent stripped from the Builder (only the Queen dispatches)" \
  'disallowedTools: Agent'
assert dispatch "$BUILDER" "Builder rides the session model (inherit)" \
  'model: inherit'
assert dispatch "$SCOUT" "read-only wall: Scout strips Edit/Write/NotebookEdit/Agent" \
  'disallowedTools: Edit, Write, NotebookEdit, Agent'
assert dispatch "$GUARD" "read-only wall: Guard strips Edit/Write/NotebookEdit/Agent" \
  'disallowedTools: Edit, Write, NotebookEdit, Agent'
assert dispatch "$FORAGER" "read-only wall: Forager strips writes and Bash" \
  'disallowedTools: Edit, Write, NotebookEdit, Agent, Bash'
assert dispatch "$FORAGER" "Forager pins sonnet (the one non-inherit bee)" \
  'model: sonnet'
assert dispatch "$RUN" "Queen self-throttles under the concurrency cap" \
  'self-throttle'

# ── QA ───────────────────────────────────────────────────────────────────────
# The autonomous Guard ↔ Builder loop between the two human gates.
assert qa "$RUN" "blocked and failed never collapse into one path" \
  '`blocked` ≠ `failed`'
assert qa "$RUN" "fix rounds are bounded by a trend-aware round cap" \
  'trend-aware round cap'
assert qa "$RUN" "blocking findings route to the same Builder via SendMessage" \
  'SendMessage'
assert qa "$RUN" "a clean pass is clean — no manufactured fix round" \
  'A clean pass is clean'

# ── INTEGRATE ────────────────────────────────────────────────────────────────
# The Queen lands green branches locally and hands the human the push.
assert integrate "$RUN" "nothing in Hive pushes — the push is the human's" \
  'Never push'
assert integrate "$RUN" "gates re-run after every merge (green combined, not per-branch)" \
  'Gates re-run after every merge'
assert integrate "$RUN" "integration lands on a local branch, never trunk" \
  'never trunk'
assert integrate "$RUN" "fast-forward landings keep clean history" \
  '--ff-only'
assert integrate "$RUN" "the Queen never resolves a conflict herself" \
  'never resolve[s]? a (code )?conflict' E

# ── Roll-up ──────────────────────────────────────────────────────────────────
echo
total=$((pass + fail))
if [ "$fail" -eq 0 ]; then
  printf '\033[32mPASS\033[0m — %d/%d invariants intact\n' "$pass" "$total"
  exit 0
else
  printf '\033[31mFAIL\033[0m — %d/%d invariants regressed\n' "$fail" "$total"
  echo "A load-bearing rule was removed or reworded past recognition. Restore it," \
       "or — if the change is intentional — update this check to match." >&2
  exit 1
fi
