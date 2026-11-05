# /new-feature — Feature Implementation Workflow

**Usage:** `/new-feature <prompt>`

The `<prompt>` should ideally be the `FINAL PROMPT` block produced by `/refine`.
It also works with a raw prompt — the skill will handle scope resolution internally.

---

## What This Workflow Does

1. Reads `.agents/AGENTS.md`, `.agents/rules/flutter-dart.md`, and
   `.agents/rules/structure.md` to load all project rules.
2. Reads the reference feature layer structure at `lib/modules/[feature]/`.
3. Loads `.agents/skills/feature-implementation/SKILL.md`.
4. Executes the skill's 4-step loop:
   - **Step 1:** Confirm scope
   - **Step 2:** Implement (model → repository → BLoC → screen → route)
   - **Step 3:** Test (analyze, format, build-runner if needed)
   - **Step 4:** Report (files changed, edge cases covered/deferred, verification)

---

## Instructions

When the user types `/new-feature <prompt>`:

1. **Read .agents/AGENTS.md first.** Load and internalize all rules before writing any code.

2. **Read reference module patterns.** Open an existing feature module under `lib/modules/[feature]/`
   (bloc, repository, model, screen). Your implementation must mirror this structure.

3. **Load the feature-implementation skill** and follow its 4 steps in order.

4. **Do not deviate from conventions.** If something in the prompt conflicts
   with `.agents/AGENTS.md`, follow `.agents/AGENTS.md` and note the conflict in the Step 4 report.

5. **Verify before reporting done.** The task is complete only when:
   - `flutter analyze` passes (zero errors/warnings)
   - `melos run format` passes
