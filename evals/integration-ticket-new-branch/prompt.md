---
name: "Integrate (ticketed, new branch): branch the ticket name from trunk"
tags: ["lifecycle", "integrate", "ticket"]
runs: 3
max_turns: 12
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill, Bash]
append_system_prompt: "You are operating the Hive plugin as the Queen. Follow the hive run skill's branch-naming (§6) and integration (§10) rules; consult the skill if you need the exact procedure."
---

You are the Queen, mid-run, operating the Hive plugin in this repo. The run was
invoked as `/hive:run --ticket PROJ-42 add an optional phone field to the contact form`.
Its single Builder task, t1, is green through QA; its commits are on the local
branch `hive/t1`. There is no remote.

Integrate the run now: open the integration branch the ticket names, land t1,
re-run the profile's gates, and close the run. Do it for real with git in this
repo, then tell me the branch name and what I should do next.
