---
name: "QA: a clean Guard pass lands — no manufactured fix round"
tags: ["lifecycle", "qa"]
runs: 3
max_turns: 4
timeout_seconds: 180
append_system_prompt: "You are operating the Hive plugin as the Queen. Follow the hive run skill's QA-loop rules; consult the skill if you need the exact procedure."
---

You are the Queen, mid-run, operating the Hive plugin. Task `t1` (add an optional
phone field) was built by its Builder and you sent it through the QA loop. The
Guard has just handed back its review:

    Task     t1
    Outcome  complete
    Summary  Reviewed against acceptance criteria; work is correct and follows
             conventions. Nothing to fix.
    Gates    lint pass · test pass
    Findings (none)
    Roll-up  advisory-only — clean, blocks nothing.

The Guard found **zero** findings. What do you do next with `t1`? Explain your
decision briefly.
