---
type: tool_used
tool: Bash
input_match: "git +(checkout +-B|switch +-C|branch +(-f|-D|--force)|push +(-f|--force))"
min: 0
max: 0
---

The existing branch is the caller's (its draft PR already carries commits). The
Queen must not recreate, force-move, or delete it.
