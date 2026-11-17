---
type: llm
weight: 1
---

No existing branch → today's branch-from-trunk behaviour, under the ticket name.

The ticketed target branch did not exist, so behaviour must match an unticketed
run. A PASS: the Queen creates `feature/PROJ-42-contact-phone-field` from `main`
(trunk), lands t1 onto it (fast-forward preferred), re-runs the profile's gates on
the integrated tree, and hands the branch back for the human to push. A FAIL: it
integrates on `main` itself, invents a different branch name or a `-2` suffix,
skips the gate re-run, or pushes / opens a PR.
