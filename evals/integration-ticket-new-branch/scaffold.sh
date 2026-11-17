#!/usr/bin/env bash
# Scaffold: a primed repo mid-run. One green Builder branch (`hive/t1`) carries the
# phone-field commit off `main`. The run was invoked with `--ticket PROJ-42` and the
# ticketed target `feature/PROJ-42-contact-phone-field` does NOT exist yet — so the
# Queen must create it from trunk (today's behaviour), land t1, re-run gates, and
# never push.
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
  "gates": { "lint": "true", "test": "node -e \"require('./src/contact-form.js')\"" },
  "codegen": [],
  "sharedSurfaces": [],
  "generated": [],
  "protectedPaths": [".env*"],
  "conventions": [],
  "maxConcurrentBuilders": 3
}
JSON
printf '.hive/runs/\n' > .gitignore
cat > src/contact-form.js <<'JS'
const FIELDS = [
  { name: "name", label: "Name", required: true },
  { name: "email", label: "Email", required: true },
];
module.exports = { FIELDS };
JS
git add -A
git commit -qm "chore: primed contact form repo"

git checkout -qb hive/t1
cat > src/contact-form.js <<'JS'
const FIELDS = [
  { name: "name", label: "Name", required: true },
  { name: "email", label: "Email", required: true },
  { name: "phone", label: "Phone", required: false },
];
module.exports = { FIELDS };
JS
git commit -qam "feat(contact): add optional phone field"
git checkout -q main
