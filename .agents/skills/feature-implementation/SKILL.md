---
name: feature-implementation
description: >
  Implements a new Flutter feature or screen from a prompt (ideally a FINAL
  PROMPT from /refine, but also works on a raw prompt). Follows AGENTS.md,
  flutter-dart.md, and structure.md exactly, using feature layer architecture
  as the canonical reference pattern. Triggered when the user asks to implement,
  build, or create a new feature or screen.
---

# Feature Implementation Skill

You are implementing a new feature in a Flutter monorepo workspace.
Execute the four steps below in order. Do not skip or reorder them.

**Before you write a single line of code**, read:
1. `.agents/AGENTS.md` (root) — project rules and golden rules
2. `.agents/rules/flutter-dart.md` — coding conventions
3. `.agents/rules/structure.md` — feature structure & TaskEither architecture

Do not proceed without understanding all three.

---

## Step 1 — Confirm Scope

**Case A: Input is a FINAL PROMPT from `/refine`**
The FINAL PROMPT already contains resolved edge cases and requirements.
- Do NOT re-ask edge case questions.
- Briefly restate (2–3 sentences) what you will build and list the top-level
  requirements as bullet points.
- Then immediately begin Step 2.

**Case B: Input is a raw prompt (not from `/refine`)**
The prompt may be underspecified. Before coding:
- Restate what you understand the feature to be.
- Run edge-case analysis (loading, empty, error, auth, validation, concurrency, pagination).
- State the defaults you will apply and call out any ambiguity.
- Proceed with your stated assumptions — do NOT ask questions. Implement
  sensible defaults and document what you assumed in Step 4.

---

## Step 2 — Implement

Follow this implementation order exactly. Do not proceed to the next file
until the current one compiles without errors.

### 2a. Translation Keys
Add any new user-visible strings to:
`packages/app_translations/assets/i18n/en.i18n.json`

Then run:
```bash
melos run locale-gen
```

### 2b. Model
Create `lib/modules/[feature]/model/[feature]_model.dart`.
- Plain Dart class with `fromJson` / `toJson`.
- All fields `final`.
- Use `const` constructor.

### 2c. Repository
Create `lib/modules/[feature]/repository/[feature]_repository.dart`.
- `abstract interface class I[Feature]Repository` with method signatures.
- `class [Feature]Repository implements I[Feature]Repository` in the same file.
- All methods return `TaskEither<Failure, T>`.
- Chain: `makeRequest().chainEither(checkStatusCode).chainEither(mapToModel(...))`.

### 2d. BLoC (3 files)
Create the bloc, event, and state files under `lib/modules/[feature]/bloc/`.

**`[feature]_event.dart`** (will be `part of` the bloc file):
- `sealed class [Feature]Event extends Equatable`
- One `final class` per action

**`[feature]_state.dart`** (will be `part of` the bloc file):
- `class [Feature]State extends Equatable`
- Named constructors with default values
- `copyWith`, `props`
- Use `ApiStatus` from `package:api_client/api_client.dart`

**`[feature]_bloc.dart`**:
- `part '[feature]_event.dart';` and `part '[feature]_state.dart';`
- Inject `I[Feature]Repository` via constructor
- Handle all events, use `state.copyWith(...)` for transitions
- Fold `TaskEither` results: `(await repository.method().run()).fold(left, right)`
- Use `droppable()` for fetch/refresh events

### 2e. Screen
Create `lib/modules/[feature]/screen/[feature]_screen.dart`.
- `@RoutePage()` annotation
- Implements `AutoRouteWrapper` — scope `RepositoryProvider` + `BlocProvider` in `wrappedRoute`
- Use `AppScaffold`, `CustomAppBar`, `AppText`, `VSpace`, `HSpace`, `AppButton`
- All user-visible strings via `context.t.[key]`
- Handle all `ApiStatus` values in the `BlocBuilder`
- Extract any repeated or isolated UI sections into separate `StatelessWidget` classes

### 2f. Register Route
Add `AutoRoute(page: [Feature]Route.page)` to `AppRouter.routes` in the router config file.

Then run:
```bash
melos run build-runner
```

---

## Step 3 — Verify

### 3a. Run Analysis
```bash
flutter analyze
```

Fix all errors and warnings.

---

## Step 4 — Report

Provide a structured summary:

```
## Feature: [Feature Name]

### Files Changed
- [NEW] lib/modules/[feature]/model/[feature]_model.dart
- [NEW] lib/modules/[feature]/repository/[feature]_repository.dart
- [NEW] lib/modules/[feature]/bloc/[feature]_bloc.dart
- [NEW] lib/modules/[feature]/bloc/[feature]_event.dart
- [NEW] lib/modules/[feature]/bloc/[feature]_state.dart
- [NEW] lib/modules/[feature]/screen/[feature]_screen.dart
- [MODIFIED] app_router.dart
- [MODIFIED] packages/app_translations/assets/i18n/en.i18n.json

### Assumptions Made
- [List any assumption you applied from Step 1 Case B]

### Verification Results
flutter analyze: 0 errors, 0 warnings
```
