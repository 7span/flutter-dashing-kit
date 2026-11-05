# Gemini project instructions

After a client call, use the transcript-informed project-understanding workflow to create context for human engineers and AI coding agents. Follow `AGENTS.md` and `.agents/skills/project-understanding/SKILL.md`.

Require the client transcript and do not silently assume requirements. The delegated subagent must automatically install the official grill-with-docs dependencies with `npx` when needed, then run an iterative transcript grill, writing numbered evidence-backed questions to `docs/project/open-questions.md` and pausing for answers. Separate repository facts, transcript requirements, inferences, and unknowns; ask focused questions when needed. Write only Markdown files under `docs/project/`. Never modify code or other project files, and never run generators, formatters, analyzers, builds, project dependency installs, migrations, or setup commands for this workflow.
