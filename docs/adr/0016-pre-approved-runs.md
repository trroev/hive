# Pre-approved runs: an approved brief replaces both human gates; escalations end the run

Status: accepted. Amends the "one fixed mode" policy in `reference/PRINCIPLES.md` (this
is its one sanctioned exception); refines ADR-0004 (QA loop — escalation) and ADR-0005
(integration — the closing confirmation).

A run is **pre-approved** when it is given an approved brief (`--brief <path>`:
behaviour, acceptance criteria, out of scope) **and** opts in — per run with
`--pre-approved`, or for the repo with `profile.preApproved: true`. Off by default; a
run without a brief stays interactive even when the profile opts in. The Queen still
scouts and decomposes into write-claimed tasks, but the brief is the align approval
(she records the align table and proceeds) and integration auto-confirms. Anything
that would hand to a human — including any re-align, since the brief approved one
decomposition — **ends the run** `halted`. The brief is stored with the run;
`run.json` gains `approval` (the mode) and `terminal` (reason code, task ids, detail),
set once when any run closes. The reason codes live in `reference/run-state.md`.

**Why:** a software factory wants Hive as its build engine, with the human approving
the brief in the ticket tracker beforehand; the run itself must never wait. Paired
with ticketed runs (ADR-0014), the factory opens a draft PR, runs Hive pre-approved on
that branch, then reads `terminal` to report back.

**Considered:** profile-only enablement — a human running Hive in the same repo would
lose their checkpoints, so a brief is required too; letting re-aligns inside the
brief's scope continue — kept the issue's stricter rule, since a reshaped plan is no
longer the one approved; a `terminal` record only for pre-approved runs — one schema
for every run is simpler to read.

**Rejected:** retrying or auto-re-decomposing past an escalation (the premise is in
doubt, which only a human can settle); letting a pre-approved run push or open the PR
it builds for (the push stays the caller's — the one irreversible act); a
`--pre-approved` run without a brief (nothing was approved — it refuses).
