# /change-flow — Existing Flow Modification Workflow

**Usage:** `/change-flow <description of what to change>`

Examples:
- `/change-flow add a confirmation dialog before the logout action`
- `/change-flow redirect to verify-OTP after sign-up instead of going to home`
- `/change-flow move the profile image picker from profile screen to sign-up`
- `/change-flow add a filter bar above the posts list on home screen`

---

## What This Workflow Does

1. Reads `.agents/AGENTS.md`, `.agents/rules/flutter-dart.md`, and
   `.agents/rules/structure.md` to load all project rules.
2. Reads the reference feature structure under `lib/modules/[feature]/`.
3. Loads `.agents/skills/flow-change/SKILL.md`.
4. Executes the skill's 5-step loop:
   - **Step 1:** Understand the change — restate before/after, classify layer, identify impact surface
   - **Step 2:** Read before writing — inspect all affected files first
   - **Step 3:** Apply the change — follow the per-layer patterns in the skill
   - **Step 4:** Verify — analyze, test, format, build-runner if routes changed
   - **Step 5:** Report — before/after summary, diff, regression risk, verification
