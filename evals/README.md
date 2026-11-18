# Hive evals — the behavioral half of the self-test harness

Hive is a plugin made of prose: the run lifecycle lives in `skills/run/SKILL.md`
and the four `agents/*.md` bees. This directory is a
[`claude plugin eval`](#running) suite that exercises that lifecycle end to end
(**decompose → dispatch → QA → integrate**) so a careless edit to the prose can't
silently regress the run.

It is one of **two layers** (see [ADR-0013](../docs/adr/0013-eval-harness.md)):

| Layer | What | Runs |
| --- | --- | --- |
| `scripts/check-invariants.sh` | Deterministic grep for load-bearing rules | **Today**, zero deps/cost |
| `evals/` (this dir) | LLM-behavioral cases against the real skills/agents | On demand: locally before merging changes to `skills/` or `agents/`, or in CI via a manual run on `main` (costs tokens; CI needs an `ANTHROPIC_API_KEY` secret) |

The static check is the fast guard that runs on every PR; this suite is the richer
behavioral net that proves the model still *follows* the rules. Together they cover the same four
phases from two angles.

## The cases — by lifecycle phase

| Case | Phase | Pins the invariant |
| --- | --- | --- |
| [`decompose-requires-profile/`](decompose-requires-profile) | decompose | An unprimed repo (no `.hive/`) is refused and pointed at `/hive:init` — **nothing is dispatched** (`tool_used Agent`, `max: 0`). |
| [`dispatch-aligns-before-building/`](dispatch-aligns-before-building) | dispatch | A Scout may recon, but **no `hive:builder` is dispatched before the align checkpoint**; the plan is surfaced for approval. |
| [`qa-clean-is-clean/`](qa-clean-is-clean) | QA | A clean Guard pass (zero findings) lands the task — the Queen **never manufactures a fix round**. |
| [`integration-never-pushes/`](integration-never-pushes) | integrate | The run closes by **handing the human a local branch to push** — the Queen never runs `git push` (`tool_used Bash "git push"`, `max: 0`) or opens a PR. |
| [`integration-ticket-new-branch/`](integration-ticket-new-branch) | integrate | A `--ticket` run whose branch **doesn't exist** creates `feature/PROJ-42-…` **from trunk** (today's behaviour), lands, re-runs gates, never pushes. |
| [`integration-onto-existing-branch/`](integration-onto-existing-branch) | integrate | A `--ticket` run whose branch **already exists on the remote** (a draft PR's) **fetches and builds onto it** — its commits stay intact (no `checkout -B` / `branch -f` / force), gates re-run, never pushes. |
| [`preapproved-run-never-waits/`](preapproved-run-never-waits) | align (pre-approved) | `/hive:run --pre-approved --brief …` treats the approved brief as the align approval: it **dispatches a `hive:builder` without asking** (`tool_used AskUserQuestion`, `max: 0`), stays inside the brief, never pushes. |
| [`preapproved-run-profile-opt-in/`](preapproved-run-profile-opt-in) | align (pre-approved) | Same, but enabled by `profile.preApproved: true` plus `--brief` with **no flag** — the profile route alone makes the run pre-approved. |
| [`preapproved-escalation-ends-run/`](preapproved-escalation-ends-run) | QA (pre-approved) | An exhausted QA ladder in a pre-approved run **ends the run `halted` with a `run.json.terminal` reason of `qa-round-cap`** (checked on disk) — no question, no further round (`Agent`/`SendMessage` `max: 0`), no landing, no push. |

Graders lean on deterministic checks (`tool_used`, `regex`) first and use an `llm`
judge only for the semantic call. The decompose, dispatch and two `preapproved-run-*`
cases drive `/hive:run` itself against a scaffolded repo. The rest put the model in the
Queen's seat at a mid-run decision point (with `append_system_prompt` telling it to
follow the run skill, so the `--ablation with-without` delta reflects the skill prose
itself): `qa-clean-is-clean` and `integration-never-pushes` by prompt alone; the two
ticketed integration cases and `preapproved-escalation-ends-run` with a scaffolded repo
(and run-state) to act on for real.

`fixtures/primed-repo/` is a tiny primed repo (profile + architecture map + a
contact form) that the scaffolds mirror inline.

## Running

From the repo root (each run is a real `claude` session on your credential, so it
costs tokens — roughly $0.10–0.40 per run):

```bash
# Whole suite, no-plugin baseline arm for the delta, JSON for CI, local report
claude plugin eval . \
  --scaffold \
  --allow-tools Bash Write Edit \
  --ablation with-without \
  --no-publish \
  --json evals/results/latest.json \
  --max-cost-usd 15

# One case (matched by its `name`, not its directory), verbose
claude plugin eval . --case "Decompose:*" --scaffold --verbose

# By phase tag
claude plugin eval . --tag qa --scaffold
```

`--scaffold` is required because the cases run author-supplied `scaffold.sh` to
build their fixtures. `--allow-tools` grants the gated tools a real run needs.
Results land in `evals/results/` (gitignored).

## Demonstrating the catch (acceptance criterion #3)

The harness must **catch a deliberately introduced regression**. Both layers do:

- **Static (provable now):** revert a load-bearing rule and re-run the check —
  e.g. change `sequenced, never parallelized` in `skills/run/SKILL.md`, or delete
  `disallowedTools: Agent` from `agents/builder.md`. `bash
  scripts/check-invariants.sh` then exits 1, naming the exact invariant. Restore
  and it returns to green. (Verified in-repo.)
- **Behavioral:** introduce the matching prose
  regression and the paired case fails:

  | Regression in the prose | Failing case |
  | --- | --- |
  | Remove the §0 "no profile → `/hive:init`" precondition | `decompose-requires-profile` |
  | Let the Queen dispatch a Builder before align | `dispatch-aligns-before-building` |
  | Have the Queen invent a fix round on a clean pass | `qa-clean-is-clean` |
  | Have the Queen `git push` at the end of integration | `integration-never-pushes` |
  | Have a ticketed run recreate/suffix an existing branch from trunk | `integration-onto-existing-branch` |
  | Drop `{ticketId}` from the ticketed branch name | `integration-ticket-new-branch` |
  | Make a pre-approved run stop at the align checkpoint | `preapproved-run-never-waits` |
  | Have a pre-approved run wait for a human at an escalation | `preapproved-escalation-ends-run` |

## Caveats

- `claude plugin eval` has **no public docs** yet. Grader shape the CLI accepts:
  an `llm` grader's frontmatter is just `type: llm` / `weight`, with the criteria
  in the markdown body; `focus` exists but is an enum (e.g. `last_message`), not
  free text — a free-text `focus` fails the whole case with `invalid case.yaml`.
  `claude plugin eval init --bare <name>` writes a known-good template.
- Case names, not directory names, are what `--case <glob>` matches.
- The behavioral cases are non-deterministic (LLM); the static check is the
  deterministic backstop. Keep both green.
