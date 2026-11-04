# /pr-review — Pre-PR Code Audit Workflow

**Usage:** `/pr-review [optional_path]`

---

## What This Workflow Does

1. Audits the specified scope (or the whole repository) against `.agents/skills/pr-review/resources/best-practices.md`.
2. Runs static analysis (`flutter analyze`) and format check (`dart format`).
3. Executes mechanical regex checks for:
   - Architecture & BLoC conventions (A1–A10)
   - Atomic Design & `app_ui` compliance (U1–U10)
   - Logging, privacy, and security standards (L1–L5)
   - Import conventions (I1–I2)
4. Performs read-the-code checks for lifecycle bugs, unhandled futures, and race conditions.
5. Writes the final audit report and verdict to `pr-review-report.md` at the repo root.
6. Does NOT modify code or files unprompted.

---

## Instructions

When the user types `/pr-review`:

1. **Load the checklist**: Read `.agents/skills/pr-review/resources/best-practices.md`.
2. **Execute `.agents/skills/pr-review/SKILL.md`**: Follow all steps in order.
3. **Produce `pr-review-report.md`**: Summarize blockers, should-fixes, and nits.
4. **Report in chat**: Provide the final verdict (`READY`, `NOT READY`, `INCOMPLETE`) and offer to assist with fixes.

