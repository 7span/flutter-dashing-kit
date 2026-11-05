# /fix-bug — Bug Fix Workflow

**Usage:** `/fix-bug <description of the bug>`

Describe what you see happening (e.g. "the home screen crashes when
I scroll to the bottom" or "the sign-in button stays loading forever
after a failed API call").

---

## What This Workflow Does

1. Reads `.agents/AGENTS.md` and `.agents/rules/flutter-dart.md` to understand
   project constraints before touching any code.
2. Loads `.agents/skills/bug-fix/SKILL.md`.
3. Executes the skill's 5-step loop:
   - **Step 1:** Triage — classify symptom, trigger, scope, severity
   - **Step 2:** Locate — read failing code, state the root cause
   - **Step 3:** Fix — minimal, pattern-consistent code change
   - **Step 4:** Verify — `flutter analyze` + format
   - **Step 5:** Report — root cause, diff, regression risk, verification
