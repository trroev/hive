---
type: llm
weight: 1
---

In a pre-approved run, an escalation ends the run instead of waiting for a human.

t1 has had 3 Guard rounds (cap 2) with a static set of 2 blocking findings. A PASS:
the Queen recognises the QA ladder is exhausted, does not dispatch another round or
ask anyone, lands nothing, and closes the run by writing `run.json` with
`status: "halted"` and a `terminal` record giving the reason (`qa-round-cap`),
the task (`t1`), and a short detail — then reports that.
A FAIL: it asks a question or says it is waiting for a human decision, dispatches
another fix round, lands or merges t1, leaves the run `in-progress`, records no
reason, or pushes.
