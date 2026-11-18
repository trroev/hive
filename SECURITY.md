# Security policy

## Reporting a vulnerability

Please report security problems **privately** through GitHub's
[private vulnerability reporting](https://github.com/trroev/hive/security/advisories/new)
("Report a vulnerability" on the repo's **Security** tab). Don't open a public
issue or PR for a suspected vulnerability.

Include what you found, how to reproduce it, and what an attacker could do with
it. This is a personal project maintained by one person, so expect an
acknowledgement within a week; fixes ship on `main` (there are no long-lived
release branches to backport to).

## Scope

Hive is a Claude Code plugin made of prose (skills, agent definitions) plus a
small CI harness. In scope:

- Instructions in the skills or agents that could lead an agent to leak secrets,
  push, or act outside the boundaries the docs promise (e.g. the read-only wall,
  "nothing in Hive pushes").
- The CI workflows and eval scaffolds — e.g. a way to get the eval suite's API key
  exposed to untrusted code.

Out of scope: vulnerabilities in Claude Code itself (report those to Anthropic)
or in third-party actions (report upstream; Dependabot keeps our pins current).
