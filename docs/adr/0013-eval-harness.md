# Self-test harness: a static invariant check plus a `claude plugin eval` suite

Hive is a plugin made of prose — the run lifecycle lives entirely in
`skills/run/SKILL.md` and the four `agents/*.md` bees, with no code to unit-test.
A routing rule, a read-only wall, or an integration invariant can therefore
regress with one careless edit and nothing catches it. Issue #5 asks for a
regression harness that exercises the lifecycle (decompose → dispatch → QA →
integrate), runs in CI, and catches a deliberately introduced regression.

**Decision — two complementary layers, both in CI:**

1. **`scripts/check-invariants.sh`** — a deterministic grep over the prose for the
   load-bearing "terms of art" of each lifecycle phase (e.g. `sequenced, never
   parallelized`, `disallowedTools: Agent`, `` `blocked` ≠ `failed` ``, `--ff-only`,
   `Never push`). Zero dependencies, zero cost, runs **today** on every PR, and
   exits non-zero naming the exact rule that regressed.
2. **`evals/`** — a `claude plugin eval` suite: one case per phase, driving the
   real skills/agents, deterministic graders (`tool_used`, `regex`) first and an
   `llm` judge only for the semantic call. It is the richer behavioral net.

**Why two.** `claude plugin eval` is the right long-term tool — it tests actual
model behavior against the loaded plugin — but it is **early-access gated** in the
current Claude Code build (2.1.245): it prints `` `plugin eval` is currently in
early access `` and exits without running, and in CI it also needs an API key and
an Anthropic-provided enablement env var. That makes it unrunnable and unprovable
right now. The static check fills the gap: it is instant, free, deterministic, and
catches the most common prose regression — a rule deleted or reworded past
recognition — so acceptance criterion #3 ("catches a deliberately introduced
regression") is **satisfiable and verified today**, and CI is meaningful before
early access lands. The two cover the same four phases from different angles: one
proves the text still *says* the rule, the other proves the model still *follows*
it.

**Provenance / accuracy.** The static check greps short terms of art rather than
whole sentences, so benign rewording survives but removing a rule fails — verified
by mutating throwaway copies (drop `sequenced, never parallelized`; delete
`disallowedTools: Agent`) → exit 1 naming both, clean tree → exit 0. The eval
suite is authored against the CLI's embedded reference (no public docs exist yet);
its grader field names may need a tweak on the first enabled run, called out in
`evals/README.md`.

**Considered:** an eval-only harness faithful to the issue's "likely `claude
plugin eval`" (rejected as the sole layer — unprovable while gated, leaving CI
empty today); a static-check-only harness (rejected as the sole layer — can't test
model behavior, and isn't the tool the issue names); a full end-to-end `/hive:run`
eval that drives the whole multi-agent machinery to integration (rejected —
slow, costly, flaky, and needs live worktrees; the cases instead pin decision
points at each phase).

**Rejected:** guessing the early-access enablement env-var name (left as a
commented placeholder in `.github/workflows/evals.yml`); blocking the branch on the
noisy LLM suite (the `plugin-eval` job is `continue-on-error` until it's a trusted
gate — the invariant job is the active gate).

See `evals/README.md` (the suite + the regression demo), `scripts/check-invariants.sh`,
`.github/workflows/evals.yml`, and the lifecycle these check in `reference/lifecycle.md`.
