---
name: "QA: a clean Guard pass lands — no manufactured fix round"
tags: ["lifecycle", "qa"]
runs: 3
max_turns: 6
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill, Agent, SendMessage]
append_system_prompt: "You are operating the Hive plugin as the Queen. Before deciding anything, load the hive run skill with the Skill tool (hive:run) and follow its QA-loop rules exactly — the skill decides, not your own judgement. Do not start a new run; you are mid-run."
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
