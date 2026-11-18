# Architecture map — primed-repo (eval fixture)

<!-- hive:arch-map
generatedAtSha: 0000000000000000000000000000000000000000
generatedAt: 2026-01-01T00:00:00Z
hiveProfileVersion: 1
-->

> Stamped fixture map for the Hive eval suite — a deliberately tiny primed repo so
> a `/hive:run` case has real terrain to scout. Not a real project.

## Table of contents

| Slice | Paths | What it covers |
| --- | --- | --- |
| contact | `src/contact-form.js` | The contact form: fields, validation, submit. |

## contact

`src/contact-form.js` renders a contact form (name + email) and validates it on
submit. Fields are declared in the `FIELDS` array; validation lives in
`validate()`. Add a field by extending `FIELDS` and its `validate()` branch.
