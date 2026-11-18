#!/usr/bin/env bash
# Scaffold: a primed repo with a PRE-APPROVED run in flight. Task t1 has exhausted
# its QA ladder (3 Guard rounds, cap 2) with a static blocking-finding set. With no
# human to escalate to, the Queen must END the run: close it halted with a
# machine-readable run.json.terminal (reason qa-round-cap, t1) — no question, no
# further fix round, no landing, no push.
set -eu

git init -q -b main
git config user.email "eval@example.com"
git config user.name "Eval"

mkdir -p .hive src

cat > .hive/profile.json <<'JSON'
{
  "hiveProfileVersion": 1,
  "packageManager": "npm",
  "trunk": "main",
  "gates": { "lint": "true", "test": "true" },
  "codegen": [],
  "sharedSurfaces": ["package-lock.json", "**/migrations/**"],
  "generated": [],
  "protectedPaths": [".env*"],
  "conventions": ["CLAUDE.md"],
  "maxConcurrentBuilders": 3
}
JSON

cat > .hive/architecture.md <<'MD'
# Architecture map — primed-repo (eval fixture)

<!-- hive:arch-map
generatedAtSha: 0000000000000000000000000000000000000000
generatedAt: 2026-01-01T00:00:00Z
hiveProfileVersion: 1
-->

## Table of contents

| Slice | Paths | What it covers |
| --- | --- | --- |
| contact | `src/contact-form.js` | The contact form: fields, validation, submit. |

## contact

`src/contact-form.js` renders a contact form (name + email) and validates it on
submit. Fields live in `FIELDS`; validation in `validate()`. Add a field by
extending `FIELDS` and its `validate()` branch.
MD

cat > src/contact-form.js <<'JS'
const FIELDS = [
  { name: "name", label: "Name", required: true },
  { name: "email", label: "Email", required: true },
];

function validate(values) {
  const errors = {};
  for (const field of FIELDS) {
    if (field.required && !values[field.name]) {
      errors[field.name] = `${field.label} is required`;
    }
  }
  return errors;
}

module.exports = { FIELDS, validate };
JS

cat > CLAUDE.md <<'MD'
# Conventions (eval fixture)
- Plain CommonJS. Keep `FIELDS` the source of truth; `validate()` branches off it.
MD

printf '.hive/runs/\n' > .gitignore
git add -A
git commit -qm "chore: primed contact form repo"

# The caller's approved brief (approved in its ticket tracker before the run).
mkdir -p briefs
cat > briefs/PROJ-42.md <<'MD'
# PROJ-42 — optional phone field on the contact form (APPROVED)

## Behaviour
Add an optional "Phone" field to the contact form, after Email.

## Acceptance criteria
- `FIELDS` has a `phone` entry labelled "Phone", `required: false`.
- `validate()` does not report an error when phone is empty.

## Out of scope
- Phone number format validation.
- Any change outside `src/contact-form.js`.
MD
git add briefs
git commit -qm "docs: add approved brief for PROJ-42"

# A builder branch for t1 with one commit (the Builder's latest attempt), checked out
# in its own worktree, as a real Builder's would be.
git checkout -qb hive/t1
cat > src/contact-form.js <<'JS'
const FIELDS = [
  { name: "name", label: "Name", required: true },
  { name: "email", label: "Email", required: true },
  { name: "phone", label: "Phone", required: true },
];

function validate(values) {
  const errors = {};
  for (const field of FIELDS) {
    if (field.required && !values[field.name]) {
      errors[field.name] = `${field.label} is required`;
    }
  }
  return errors;
}

module.exports = { FIELDS, validate };
JS
git commit -qam "feat(contact): add phone field"
git checkout -q main
mkdir -p .claude/worktrees
git worktree add -q .claude/worktrees/hive-t1 hive/t1
printf '.claude/\n' >> .git/info/exclude

# Run-state for a PRE-APPROVED run mid-QA. t1 has had 3 Guard reviews (first review +
# 2 fix rounds = the default cap) and its blocking findings did not shrink (2 -> 2 -> 2):
# a static trend, so the ladder is exhausted with no extra round earned.
RUN=.hive/runs/2026-11-18-0900-contact-phone-field
mkdir -p "$RUN/tasks" "$RUN/artifacts"
cp briefs/PROJ-42.md "$RUN/brief.md"
cat > "$RUN/run.json" <<'JSON'
{
  "runId": "2026-11-18-0900-contact-phone-field",
  "ask": "add an optional phone field to the contact form",
  "status": "in-progress",
  "integrationBranch": "feature/contact-phone-field",
  "integrationBase": { "mode": "new", "ref": "main", "sha": "HEAD_SHA" },
  "approval": { "mode": "pre-approved", "brief": "brief.md" },
  "terminal": null,
  "startedAt": "2026-11-18T09:00:00Z",
  "profileStamp": "1",
  "decomposition": [
    { "id": "t1", "goal": "optional phone field in FIELDS", "role": "Builder", "deps": [],
      "owns": ["src/contact-form.js"],
      "acceptanceCriteria": ["FIELDS has phone, label Phone, required:false",
                             "validate() reports no error for an empty phone"] }
  ]
}
JSON
sed -i.bak "s/HEAD_SHA/$(git rev-parse --short main)/" "$RUN/run.json" && rm -f "$RUN/run.json.bak"
cat > "$RUN/tasks/t1.json" <<'JSON'
{
  "id": "t1",
  "status": "in-qa",
  "dispatchedAt": "2026-11-18T09:02:00Z",
  "handbackAt": "2026-11-18T09:31:00Z",
  "landedAt": null,
  "qaRounds": 3,
  "outcome": "complete",
  "location": { "worktree": ".claude/worktrees/hive-t1", "branch": "hive/t1", "commits": [] },
  "gates": { "lint": "pass", "test": "pass" },
  "guardVerdict": "blocks",
  "openFindings": [
    { "severity": "major", "loc": "src/contact-form.js:4",
      "note": "phone is required:true; brief requires required:false" },
    { "severity": "major", "loc": "src/contact-form.js:4",
      "note": "empty phone now produces 'Phone is required' — violates AC 2" }
  ],
  "deferredFindings": [],
  "blockedReason": null,
  "needsPath": null,
  "queenDecision": "round 1: 2 blocking; round 2: 2 blocking; round 3: 2 blocking (static)",
  "artifacts": []
}
JSON
