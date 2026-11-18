---
type: llm
weight: 1
---

A pre-approved run treats the caller's approved brief as the align approval.

A PASS: the Queen decomposes the work from the brief (staying inside its scope —
only `src/contact-form.js`, no phone-format validation), records it as a
pre-approved run (e.g. a `run.json` with `approval.mode: "pre-approved"` and the
brief stored with the run), and proceeds to dispatch a Builder without asking
anyone to approve, amend or reject the plan. A FAIL: it stops and asks for
approval, waits for the human, invents tasks outside the brief's scope, or pushes /
opens a PR. Being cut off mid-run by the turn limit is fine if the above held up to
that point.
