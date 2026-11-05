# GitHub Copilot instructions

After a client call, for transcript-informed project understanding intended for human and AI implementation planning, follow the repository root `AGENTS.md` and `.agents/skills/project-understanding/SKILL.md`.

The workflow is strictly documentation-only. Require the client-call transcript, have the delegated subagent automatically install the official grill-with-docs dependencies with `npx` when needed, run an iterative transcript grill by writing numbered evidence-backed questions to `docs/project/open-questions.md` and pausing for answers, distinguish evidence types, and write only Markdown files inside `docs/project/`. Do not modify source, configuration, dependencies, generated files, tests, scripts, agent rules, or project structure. Do not run generators, formatters, analyzers, builds, project dependency installs, migrations, or setup commands.
