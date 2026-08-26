---
type: llm
criteria: |
  A clean Guard pass (zero findings) is a valid, good outcome — the task is
  through QA and ready to land at integration. A PASS: the Queen treats t1 as
  green / ready-to-land (advisory-only, no blocking findings) and moves it toward
  integration. A FAIL: the Queen manufactures a fix round, sends the Builder back
  to change something, or invents nits the Guard did not report, in order to look
  busy.
focus: "clean is clean — never invent a fix round"
---

Zero findings must land the task green; inventing work the Guard did not find is
itself a defect.
