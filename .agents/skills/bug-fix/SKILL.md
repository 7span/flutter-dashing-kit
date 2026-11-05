---
name: bug-fix
description: >
  Diagnoses and fixes bugs in the existing codebase. Covers runtime crashes,
  UI rendering issues, BLoC state not updating, repository errors, and
  regression bugs. Triggered when the user says "fix", "bug", "crash",
  "broken", "not working", "error", or describes unexpected behaviour in an
  existing screen or feature.
---

# Bug Fix Skill

You are diagnosing and fixing a bug in the Flutter monorepo codebase.
Follow these steps in order. Do not skip the diagnosis phase and jump
straight to editing code — wrong assumptions waste time and create regressions.

---

## Step 1 — Triage

Read the bug report carefully. Extract:

| Field | What to identify |
|---|---|
| **Symptom** | What the user sees (crash, wrong state, UI glitch, data not loading) |
| **Trigger** | What action causes it (tap, scroll, page load, background event) |
| **Scope** | Which module, screen, or layer is involved |
| **Severity** | Crash (app dies) / Functional (wrong behaviour) / Visual (layout only) |

Restate your understanding of the bug in 2–3 sentences before investigating.
If the bug report is too vague to act on, ask ONE focused clarifying question
(e.g. "Does this crash happen on first load or only after scrolling?").

---

## Step 2 — Locate

### 2a. Read the Failing Code First
Open the relevant files in this order:
1. The **screen** (`lib/modules/[feature]/screen/`) — find what event is being added or what BlocBuilder builds
2. The **BLoC** (`lib/modules/[feature]/bloc/`) — find how the event is handled and what state is emitted
3. The **repository** (`lib/modules/[feature]/repository/`) — find how data is fetched and errors are mapped
4. The **model** (`lib/modules/[feature]/model/`) — check field names, nullability, `fromJson`

### 2b. Check Cross-Cutting Concerns
If the bug is not obviously in one feature:
- **Routing bug** → check `app_router.dart` and generated router file
- **DI bug** → check dependency injection configuration and `wrappedRoute` (scoped providers)
- **Auth / token bug** → check `AuthRepository` and `api_client`
- **Translation key missing** → check `packages/app_translations/assets/i18n/en.i18n.json`
- **Generated file stale** → check if `melos run build-runner` needs to be run

### 2c. State the Root Cause
Before touching any code, write one clear sentence:
> "Root cause: [exact reason the bug exists]"

If you cannot state the root cause with confidence, say so and explain what
additional information you need from the user (logs, stack trace, reproduction steps).

---

## Step 3 — Fix

### Rules for Editing Existing Code
- **Minimal diff.** Change only the lines necessary to fix the bug.
  Do not refactor unrelated code in the same PR.
- **Preserve existing behaviour.** If a method has multiple callers,
  verify the fix does not break other callsites.
- **Stay within the pattern.** The fix must follow all rules in `.agents/AGENTS.md`
  and `.agents/rules/flutter-dart.md`. Do not introduce:
  - Raw `try/catch` in repository methods
  - Hardcoded strings (use `context.t.[key]`)
  - `SizedBox` for spacing (use `VSpace`/`HSpace`)
  - `Scaffold` instead of `AppScaffold`
  - New packages without asking

### Common Fix Patterns

**Bug: State not updating in UI**
- Check `buildWhen` — is it filtering out the relevant state change?
- Check `props` in the state class — is the changed field included?
- Check that `copyWith` is being called (not mutating the existing state object).

**Bug: API call returns data but list shows empty**
- Check JSON mapping — is the cast correct (`List<dynamic>` → `List<Map<String, dynamic>>`)?
- Check `fromJson` field names match the actual JSON keys.

**Bug: Crash on page load**
- Check `wrappedRoute` — is the `RepositoryProvider` registered before the `BlocProvider` reads it?
- Check `safeAdd` vs `add` — never call `.add()` after `bloc.close()`.
- Check `late final` fields initialised in `initState`, not in the constructor.

**Bug: Route not found / navigation crash**
- Run `melos run build-runner` — the generated router file may be stale.
- Check the route is registered in route configuration.

**Bug: Translation key showing raw key string**
- Add the key to `packages/app_translations/assets/i18n/en.i18n.json`.
- Run `melos run locale-gen`.

**Bug: Asset not found**
- Move the asset to `packages/app_ui/assets/[images|icons|fonts]/`.
- Run `melos run asset-gen`.
- Use `Assets.[category].[name]` — not a raw string path.

---

## Step 4 — Verify

### 4a. Run Static Analysis
```bash
flutter analyze
```
Zero errors. Zero warnings. If the fix introduces new warnings, fix them.

---

## Step 5 — Report

```
## Bug Fix: [Short Description]

### Root Cause
[One-sentence explanation of why the bug existed]

### Files Changed
- [MODIFIED] path/to/file.dart — [what changed and why]

### Regression Risk
[Low / Medium / High] — [explain which other areas could be affected]

### Verification
flutter analyze: 0 errors, 0 warnings
```
