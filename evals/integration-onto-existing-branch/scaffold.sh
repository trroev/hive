#!/usr/bin/env bash
# Scaffold: a primed repo mid-run. One green Builder branch (`hive/t1`) carries the
# phone-field commit. The run was invoked with `--ticket PROJ-42`, and the caller
# already opened a draft PR on `feature/PROJ-42-contact-phone-field` — the branch
# EXISTS with one commit of its own (the plan doc) — but only on the remote
# (`origin`, a bare repo inside the scaffold), as it would after a draft PR is
# opened elsewhere. The Queen must fetch it, build onto it: keep that commit, land
# t1 on top, re-run gates, and never push.
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

# A bare "origin" inside the scaffold dir, hidden from the working tree.
git init -q --bare .origin.git
printf '.origin.git/\n' >> .git/info/exclude
git remote add origin "$PWD/.origin.git"
git push -q origin main

git checkout -qb feature/PROJ-42-contact-phone-field
mkdir -p docs
printf '# PROJ-42 plan\n\nAdd an optional phone field.\n' > docs/PROJ-42-plan.md
git add docs
git commit -qm "docs: add approved plan for PROJ-42"
git push -q origin feature/PROJ-42-contact-phone-field

# The Builder started from the integration base (the existing branch's tip).
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

# The PR branch now lives only on the remote: drop the local copy and its
# remote-tracking ref, so the Queen has to discover it with a fetch.
git branch -qD feature/PROJ-42-contact-phone-field
git update-ref -d refs/remotes/origin/feature/PROJ-42-contact-phone-field
