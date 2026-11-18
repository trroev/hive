# Repo hardening: squash-only, a ruleset-guarded `main`, SHA-pinned CI, evals off PRs

Status: accepted. Refines ADR-0013 (eval harness — the behavioral suite no longer
runs on PRs); complements ADR-0011 (Conventional-Commits history).

`main` only changes through a pull request whose **invariant check** is green — the
required status check is the job name `invariant check (prose regression guard)`, so
renaming that job breaks the ruleset. A
repository ruleset enforces that, requires linear history, and blocks force-pushes
and deletion; the repository **Admin** role is the sole bypass actor (emergencies
only) — today that is just the owner, so granting anyone else admin also grants bypass, and zero
approvals are required because there is one maintainer, who cannot approve their own
PRs. Merging is **squash-only**, the squash commit taking the PR title, so `main`
stays one Conventional Commit per PR; head branches auto-delete on merge, which also
makes GitHub retarget stacked PRs to `main`. A tag ruleset on `v*` keeps release
tags immutable.

CI pins every action to a full commit SHA (the repo setting requires it) and the
Claude Code CLI to an exact version (pinning moved the actions to their current
majors and the runtime to Node 24, since Node 20 is past end-of-life); Dependabot proposes updates after a 7-day
cooldown. Each job gets only `contents: read`. The paid `plugin eval` job runs only
on pushes to `main` and on manual dispatch from `main` — never on `pull_request`, and
never on an unmerged branch.

**Why:** a stacked PR (#11) merged into a stale base branch instead of `main`
because head branches weren't auto-deleted, and the history mixed merge and squash
commits. The eval job ran PR-supplied scaffold scripts with `ANTHROPIC_API_KEY` in
scope — fork PRs never get secrets, but a same-repo branch did. Tag-pinned actions
can be silently repointed.

**Considered:** a protected `evals` environment with a required reviewer, keeping
evals on PRs (rejected — a click per PR for a non-blocking job; post-merge runs
still catch behavioral regressions, and the free invariant check gates every PR);
required approvals (rejected — impossible for a sole maintainer); classic branch
protection (rejected — rulesets are the current mechanism and also cover tags).

**Rejected:** no bypass at all (a broken required check would lock `main` with no
recovery short of deleting the ruleset).
