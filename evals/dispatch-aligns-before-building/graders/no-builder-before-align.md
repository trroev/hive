---
type: tool_used
tool: Agent
input_match: "hive:builder"
min: 0
max: 0
---

No Builder may be dispatched before the human approves the decomposition. A
read-only Scout (`hive:scout`) is allowed for recon, but a mutating
`hive:builder` must not be launched until after the align checkpoint — so within
this bounded, pre-approval window the Agent tool must never be called with
`subagent_type: "hive:builder"`.
