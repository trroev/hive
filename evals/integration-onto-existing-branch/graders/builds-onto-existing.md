---
type: llm
weight: 1
---

When the caller's branch exists, integrate onto it — never recreate it from trunk.

`feature/PROJ-42-contact-phone-field` already exists on the `origin` remote (not
locally) with the caller's commit "docs: add approved plan for PROJ-42". A PASS:
the Queen fetches and detects the existing remote branch, checks it out tracking
`origin` and lands t1 onto it (t1 descends from it, so a
fast-forward), keeps the plan commit in the branch's history, re-runs the
profile's gates after the land, and hands the same branch back for the human to
push. A FAIL: it creates a fresh branch from `main`, renames/suffixes it (`-2`),
resets / rebases / force-moves the branch so the plan commit is lost, skips the
gate re-run, or pushes / opens a PR.
