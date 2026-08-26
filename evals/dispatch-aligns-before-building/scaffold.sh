#!/usr/bin/env bash
# Scaffold: a repo already primed for Hive (mirrors evals/fixtures/primed-repo).
# The run skill may dispatch a read-only Scout for recon, but it must render the
# one-screen align checkpoint and STOP for approval before dispatching any
# Builder into a worktree.
set -eu

git init -q
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

git add -A
git commit -qm "chore: primed contact form repo"
