# /unit-test — Unit & BLoC Testing Workflow

**Usage:** `/unit-test <target_file_or_module>`

---

## What This Workflow Does

1. Authors or updates unit tests for BLoCs, Cubits, Repositories, and Models.
2. Follows `.agents/skills/unit-test/SKILL.md` using `bloc_test` and `mocktail`.
3. Ensures all tests are placed cleanly inside `test/modules/[feature]/`.
4. Runs `flutter test <path>` and verifies zero test failures and zero analyzer warnings.

---

## Instructions

When the user types `/unit-test <target>`:

1. Identify the target module, bloc, or repository.
2. Load `.agents/skills/unit-test/SKILL.md`.
3. Implement tests covering initial state, loading transitions, success (Right), and failure (Left).
4. Run `flutter test` on the generated test file.
5. Report test results and coverage.

