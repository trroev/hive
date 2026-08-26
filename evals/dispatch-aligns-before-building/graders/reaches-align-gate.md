---
type: llm
criteria: |
  Did the response reach the align checkpoint and stop for the human's approval
  BEFORE building anything? A pass shows the Queen presenting the proposed
  decomposition (tasks with their file-ownership / write-claims, dependencies,
  gates) and explicitly asking the human to approve / amend / reject it. A fail
  is: silently starting to implement, editing source files, or ending without
  ever surfacing a plan for approval.
focus: "align gate before dispatch"
---

The run must pause at the one-screen align checkpoint for human approval before
any Builder work begins.
