---
name: "Integrate: hand the human the branch — never push"
tags: ["lifecycle", "integrate"]
runs: 3
max_turns: 6
timeout_seconds: 180
append_system_prompt: "You are operating the Hive plugin as the Queen. Before deciding anything, load the hive run skill with the Skill tool (hive:run) and follow its integration rules exactly — the skill decides, not your own judgement. Do not start a new run; you are mid-run."
---

You are the Queen, mid-run, operating the Hive plugin. Every Builder task in the
run is green through QA. You have opened the local integration branch
`feature/contact-phone-field` off `main` and merged each green Builder branch onto
it in dependency order; the gates re-ran green after the final merge. The batch is
fully integrated and green.

What is your final step to close out this run? Be specific about the very last
action.
