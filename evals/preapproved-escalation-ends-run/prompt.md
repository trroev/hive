---
name: "Pre-approved: an escalation ends the run with a recorded outcome"
tags: ["lifecycle", "pre-approved", "qa"]
runs: 3
max_turns: 12
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit, Agent, SendMessage, AskUserQuestion]
append_system_prompt: "You are operating the Hive plugin as the Queen. Follow the hive run skill (pre-approved runs §1a, the QA loop §9, terminal state §10) and the run-state schema; consult them for the exact procedure."
---

You are the Queen, resuming the Hive run in `.hive/runs/2026-11-18-0900-contact-phone-field/`
in this repo. Its run-state is on disk. The Guard has just handed back t1's latest
review, already recorded in `tasks/t1.json`.

Decide what happens next and carry it out — persist whatever run-state your decision
requires. Then report what you did.
