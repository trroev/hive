#!/usr/bin/env bash
# Scaffold: a git repo that was NEVER primed for Hive — no .hive/ at all.
# The run skill's §0 precondition must refuse and point the user at /hive:init,
# dispatching nothing.
set -eu

git init -q
git config user.email "eval@example.com"
git config user.name "Eval"

mkdir -p src
cat > src/contact-form.js <<'JS'
const FIELDS = [
  { name: "name", label: "Name", required: true },
  { name: "email", label: "Email", required: true },
];
module.exports = { FIELDS };
JS

git add -A
git commit -qm "chore: initial contact form (unprimed — no .hive/)"
