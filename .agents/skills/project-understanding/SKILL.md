---
name: project-understanding
description: Turn a client-call transcript into evidence-based project-understanding documentation for human and AI implementation planning without changing code or project files.
---

# Project Understanding

Use this skill only after a client call when a transcript must be converted into a shared project-understanding package that humans and AI agents can use to plan and implement later. It is not a feature implementation, code review, or general documentation workflow.

## Hard boundary

This is a documentation-only workflow.

- Read repository files and transcript input.
- Write only Markdown files below `docs/project/`.
- Never change application code, configuration, dependencies, generated files, tests, scripts, agent instructions, or directory structure.
- Do not run code generation, formatting, analysis, builds, dependency installation, migrations, or setup scripts.
- Before every write, resolve the absolute path and refuse the write if it is not inside `docs/project/` and does not end in `.md`.

## Primary purpose and audience

The transcript is the product-context source. By default, this is a from-scratch documentation workflow: do not inspect, infer from, or use current application code, routes, modules, dependencies, or architecture. The user may explicitly provide API material alongside the transcript; supplied API material is allowed evidence and must be kept separate from transcript evidence. Only inspect the repository when the user explicitly asks for a codebase-alignment review or supplies repository context as part of the request. The output must be useful to:

- A human engineer estimating, decomposing, and planning implementation.
- An AI coding agent that needs reliable context before changing code.
- A project/product owner reviewing what was agreed, inferred, or left unresolved.

Preserve client terminology where it is clear, and flag terminology that needs confirmation. Do not convert a conversation into implementation tickets unless the transcript explicitly establishes them.

## Official grill bootstrap

When this transcript agent receives a transcript, it owns setup for the official `grill-with-docs` flow. Before questioning the transcript:

1. Check whether the official skills `grill-with-docs`, `grilling`, and `domain-modeling` are available in the current agent environment.
2. If any are missing and `npx` is available, install them automatically from `mattpocock/skills` using the agent’s supported command execution mechanism. Do not ask the teammate to run a separate setup command.
3. If installation is unavailable because the environment lacks `npx`, network access, or permission, report that as a setup blocker and ask the user to authorize or resolve that environment issue; do not silently substitute an unapproved implementation.
4. Invoke the official grill behavior using the transcript as the source of product decisions. If API material was supplied, use it to ask API-readiness questions and map known contracts, but do not treat it as proof that a product requirement is agreed. Do not let the existing repository shape the interview unless the user explicitly requested codebase alignment.

The repository installer script is only a fallback for environments that cannot perform this bootstrap from the delegated subagent. It is not a required teammate step.

## Required interaction model: transcript grill

Do not make silent assumptions. This agent has a mandatory transcript-grill phase inside the subagent itself. After receiving a transcript, produce a useful provisional documentation package from explicit transcript evidence, then ask focused questions for unresolved decisions. Questions block finalization, not the initial understandable baseline.

The grill is iterative and evidence-driven:

1. Extract the client’s stated goals, actors, scope, priorities, constraints, integrations, and future projections.
2. Identify ambiguity, contradiction, missing decisions, and terms that could be interpreted more than one way from the transcript itself. If codebase alignment was explicitly requested, compare against repository evidence as a separate evidence category.
3. Create or update only `docs/project/open-questions.md` with numbered questions. Each question must include why it matters, the related transcript reference, relevant repository paths, answer options only when they are genuinely distinct, and the decision that will be unblocked by the answer.
4. Present the same questions to the user and stop only while blocking answers are pending. The baseline documentation may still be generated in this state, clearly marked `Draft — questions pending`.
5. On each later turn, reconcile the answers, record decisions and approved assumptions, then repeat the grill if new dependencies or contradictions appear.
6. When no required questions remain, proceed automatically to finalize and regenerate the documentation. Do not ask for an additional “continue” or “generate” confirmation.
7. Keep optional questions documented as open questions without blocking if they do not affect the current understanding.

The subagent must own this question loop. A parent agent may dispatch the subagent and relay its questions, but must not answer on the client’s behalf.

Classify every meaningful statement as one of:

1. **Verified repository fact** — directly supported by a file, symbol, manifest, route, dependency, or directory; use this category only when repository inspection was explicitly requested.
2. **Explicit transcript requirement** — directly stated in the supplied transcript.
3. **Inference requiring confirmation** — a reasonable interpretation that is not directly established.
4. **Unknown/open question** — information not available from current evidence.

Ask questions whenever an answer could change terminology, audience, ownership, priority, module boundaries, architecture interpretation, or roadmap classification. If the user explicitly says to continue without answering, record the exact decision as an assumption and identify its impact.

If unresolved questions affect final scope or implementation planning, record them in `docs/project/open-questions.md` and mark the other documents as provisional. Do not present the baseline as finalized, and do not fill gaps with assumptions. If the transcript is incomplete, contradictory, or roadmap-heavy, treat that as a reason to grill while still documenting the explicit evidence that is available.

## Discovery

When codebase alignment is explicitly requested, inspect only what is relevant, prioritizing:

- Existing agent instructions and rules.
- Root and package manifests.
- Package/module directory trees.
- Routes, dependency injection, repositories, state-management files, models, and screens.
- README files, setup scripts, CI workflows, and architecture documentation.
- The supplied transcript, preserving transcript references where possible.

Do not inspect the repository by default. When codebase alignment is explicitly requested, do not execute commands that alter tracked or untracked project state. Cache-only read operations are acceptable only when necessary to inspect repository truth.

## Output contract

On the first transcript pass, generate a provisional package from explicit transcript evidence. After required questions are resolved, regenerate the same package as finalized. In both cases, write only these Markdown files:

```text
docs/project/
├── README.md
├── overview.md
├── architecture.md
├── modules.md
├── data-flows.md
├── conventions.md
├── roadmap.md
├── evidence.md
└── open-questions.md
```

Each document must include its evidence sources using transcript references. If API material was supplied, cite its filename, endpoint, schema, example response, or section as a separate API-evidence source. If codebase alignment was explicitly requested, include repository-relative paths in a separate repository-evidence section. For from-scratch runs, state that repository evidence was intentionally not used. Keep any later implementation mapping separate from the transcript-derived product understanding.

The overview must state the client-call context, intended product/problem, known users or actors, agreed outcomes, and the intended use of this documentation for subsequent planning. The evidence document must distinguish transcript evidence from repository evidence.

The roadmap must classify every projected module as:

- **Confirmed** — explicitly present in code or explicitly committed in the transcript.
- **Implied, pending confirmation** — strongly suggested by evidence but not explicitly committed.
- **Speculative** — plausible but unsupported enough that it must not be treated as planned work.

Every projected module must include its evidence, confidence classification, likely impact, and unresolved questions. Never present an inference or speculation as an implementation commitment.

## Question-document contract

When the grill pauses the workflow, `docs/project/open-questions.md` must contain:

- Current status: `Questions pending` or `Ready for documentation`.
- A short evidence summary showing what was verified before questioning.
- Numbered questions grouped by blocking and non-blocking status.
- For each blocking question: question, evidence, why it matters, and expected answer format.
- A decision log recording answered questions, the answer source, and its impact.
- Explicitly approved assumptions, if any, with the approver’s wording preserved as closely as possible.

The other package files must remain understandable in the paused state. Include a clear status such as `Draft — questions pending`, describe only confirmed transcript scope, and link unresolved decisions back to `open-questions.md`. Never leave implementation-planning readers with only a question dump when explicit transcript evidence can support a useful baseline.

## Optional API evidence

When the user supplies partial or complete API material, document it without overstating readiness:

- **Verified API available** — directly described by an endpoint, schema, example response, or API specification supplied by the user.
- **API coverage gap** — a transcript requirement with no supplied API evidence.
- **API ambiguity** — an endpoint or field exists but its product meaning, ownership, lifecycle, error behavior, or release scope is unclear.
- **Unverified API assumption** — never treat a guessed endpoint, payload, authentication method, or status transition as available.

Ask focused questions about missing contracts such as authentication, pagination, validation, error responses, idempotency, payment confirmation, order status transitions, webhooks, and ownership. Never request or record API secrets, tokens, private keys, or credentials.

Do not overwrite unanswered questions with guessed answers. Preserve prior question and decision history when regenerating this file.

## Completion report

Report:

- Questions asked and answers received.
- Any user-approved assumptions.
- Files written under `docs/project/`.
- Evidence limitations and unresolved questions.
- Confirmation that no files outside `docs/project/` were changed by the workflow.
