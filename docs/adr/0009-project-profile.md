# The project profile holds facts and pointers; init detects-then-confirms

`.hive/profile.json` (committed) is the cold-start answer every bee reads: gates
(name→top-level command, orchestrator-agnostic), codegen, sharedSurfaces,
generated, protectedPaths, and `conventions` — which **points at** `CLAUDE.md`
and convention docs rather than restating them. `generated`
(regenerate-never-hand-edit) is a field distinct from `sharedSurfaces`
(serialize-me). `/hive:init` auto-detects most fields, guess-and-confirms the
fuzzy ones, and presents the whole draft in **one detect-then-confirm pass**;
it is idempotent (detect-and-diff on re-run), and `init` ⊇ `resync`.

**Why:** the profile must not rot into a stale copy of the conventions, so it
points at the source of truth instead of duplicating it. Silent detection risks
a wrong trunk/gate poisoning every run; per-field interrogation is tedious — one
confirm pass is the right friction for a once-per-repo setup. Validated by
hand-writing profiles for two real repos before fixing the schema.

**Rejected:** a per-role model/effort override field (cut as speculative —
frontmatter defaults suffice); stored per-role profile slices (the Queen projects
the fields a role needs at dispatch instead); a fully silent `init`.

See `reference/profile.schema.json`.
