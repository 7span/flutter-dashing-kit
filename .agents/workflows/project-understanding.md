# /project-understanding — Project Understanding Documentation Workflow

**Usage:** `/project-understanding <transcript path or pasted transcript>`

This workflow converts a client-call transcript into a shared project-understanding package for human engineers and AI coding agents. It does not implement features or modify application code.

## Execution protocol

1.  Load `.agents/skills/project-understanding/SKILL.md`.
2.  Resolve the client-call transcript input. If no transcript was supplied, stop and ask for it; do not silently downgrade this workflow to repository-only documentation.
3.  In the delegated subagent, check for the official `grill-with-docs`, `grilling`, and `domain-modeling` skills. If missing, install them automatically from `mattpocock/skills` with `npx`; do not require a separate teammate setup step.
4.  Treat the transcript as the product source. Accept explicitly supplied API specifications, endpoint lists, schemas, Postman exports, or sample payloads as separate API evidence. Do not inspect current code or architecture unless the user explicitly requests codebase alignment.
5.  Build an evidence ledger before writing. Keep transcript commitments, API evidence, inferences, and unknowns separate; include repository facts only when codebase alignment was explicitly requested.
6.  Run the mandatory transcript grill in the subagent: write/update `docs/project/open-questions.md`, present numbered blocking questions with evidence and impact, and generate a provisional, transcript-only documentation package marked `Draft — questions pending` so humans and AI agents can understand the confirmed baseline.
7.  On each follow-up, reconcile answers and rerun the grill if they expose new ambiguity. Never answer on the client’s behalf.
8.  If required answers are missing, keep the provisional package and stop asking questions; do not present it as finalized.
9.  Once the client context and scope are confirmed, proceed automatically to regenerate the Markdown files under `docs/project/` as finalized; do not request an extra confirmation.
10.  Review the resulting documentation for unsupported claims, missing evidence, and accidental writes outside the allowed directory.
11.  Report the evidence basis, questions, assumptions, output files, and boundary verification.

## Safety rule

Never run project dependency commands, `melos`, `flutter`, `dart run`, `mason`, `pod`, formatters, analyzers, generators, builds, setup scripts, or migrations as part of this workflow. The only allowed installation is the delegated subagent’s bootstrap of the official agent skills from `mattpocock/skills` when they are missing.
