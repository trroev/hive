# Architecture Decision Records

The decisions behind Hive v1 and *why* they were made — the durable record of the
design, distilled from the wayfinding effort that produced the plugin.

| ADR | Decision |
| --- | --- |
| [0001](0001-task-ownership-model.md) | Tasks own file-glob write-claims; overlap sequences, dependencies order |
| [0002](0002-queen-and-read-only-bees.md) | The Queen is the main session; bees are read-only by construction |
| [0003](0003-handback-contract.md) | The handback is a markdown envelope with a four-value outcome verdict |
| [0004](0004-qa-loop.md) | QA loop: same-Builder fix rounds, a trend-aware cap, human at the exits |
| [0005](0005-integration-ritual.md) | Integration lands on a local branch; nothing in Hive pushes |
| [0006](0006-run-state-on-disk.md) | Run state on disk: plan/state split, Queen sole writer |
| [0007](0007-architecture-map-as-prior.md) | The architecture map is a refreshed-on-read prior, not a source of truth |
| [0008](0008-concurrency-self-throttle.md) | Concurrency: a fixed Builder cap with Queen self-throttle |
| [0009](0009-project-profile.md) | The project profile holds facts and pointers; init detects-then-confirms |
| [0010](0010-plugin-shape.md) | Plugin shape: skills are the Queen's verbs, agents are the bees |
| [0011](0011-git-flow-branches.md) | Integration branches use git-flow names; commits follow Conventional Commits |
| [0012](0012-fleet-durability.md) | Fleet durability: stay in-session; the detached fleet stays an unbuilt additive seam |
| [0013](0013-eval-harness.md) | Self-test harness: a static invariant check plus a `claude plugin eval` suite, both in CI |
| [0014](0014-ticket-aware-integration-branch.md) | Ticket-aware integration branches; a ticketed run builds onto an existing branch |
| [0015](0015-repo-hardening.md) | Repo hardening: squash-only, a ruleset-guarded `main`, SHA-pinned CI, evals off PRs |
| [0016](0016-pre-approved-runs.md) | Pre-approved runs: an approved brief replaces both human gates; escalations end the run |

New decisions get the next sequential number. Superseding or refining an earlier
one: note it in a `Status:` line and cross-link (see 0011 → 0005). The glossary
these draw on is the repo-root `CONTEXT.md`; the how-to detail lives in
`reference/`.
