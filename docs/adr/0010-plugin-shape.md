# Plugin shape: skills are the Queen's verbs, agents are the bees

Hive is packaged as a Claude Code plugin where a **skill** is an orchestration
entrypoint the human invokes (`run`, `init`, `status`, `resync`) and an **agent**
is a dispatched worker (the four bees). The Queen's charge lives in the `run`
skill — there is deliberately no `queen.md`. Everything namespaces under `hive:`,
so it **coexists collision-free** with other plugins (notably `crew`) and is not
a replacement for any of them. The marketplace is served from the same GitHub
repo; the dev loop is a local `--plugin-dir` checkout; the plugin's semver is a
separate version line from `hiveProfileVersion`.

**Why:** the skill-vs-agent split mirrors the domain (verbs the human runs vs
workers the Queen runs) and the installed `crew` plugin's proven layout.
Namespacing makes dogfooding Hive alongside other crews safe.

**Considered:** replacing `crew` outright (no — different philosophies, both kept
installable, chosen per task).

See `README.md`, `CONTEXT.md` (Skill vs agent).
