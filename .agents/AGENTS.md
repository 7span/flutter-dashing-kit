# Flutter Monorepo - AI Agent Operating Guidelines

This file serves as the main entrypoint and rule index for AI coding assistants working across Flutter monorepo applications.

---

## Workspace Structure

The project follows a modular monorepo structure managed with **Melos**:

-   **App Modules**: `apps/[app_name]/lib/modules/[feature]/` (or `lib/modules/[feature]/`)
-   **UI Package**: `packages/app_ui/` (Assets, Design System, Common Widgets)
-   **Translations Package**: `packages/app_translations/` (Slang i18n JSON & generated translations)
-   **API Client Package**: `packages/api_client/` (HTTP Client, Interceptors, Base API setup)
-   **Widgetbook Package**: `packages/widgetbook/` (Component catalog & previews)

---

## 10 Golden Rules

Single source of truth: [.agents/skills/pr-review/resources/best-practices.md](file://.agents/skills/pr-review/resources/best-practices.md)

1. **Feature Architecture**: 4-layer structure (`bloc/`, `model/`, `repository/`, `screen/`) under `lib/modules/[feature_name]/`.
2. **Repositories (`TaskEither`)**: Return `TaskEither<Failure, T>` using functional error handling from `fpdart`; never throw unhandled exceptions.
3. **BLoC & State Management**: Sealed class events named in past tense; private constructor states (`FeatureState._()`) with named constructors, `copyWith`, and `Equatable`.
4. **Atomic Design & UI Components**: Always use `app_ui` components (`AppText`, `AppButton`, `VSpace`, `HSpace`, `AppScaffold`). NEVER use raw `SizedBox` for spacing or raw Material buttons.
5. **Color & Typography**: Use `context.colorScheme` and `context.textTheme` via theme extensions; never hardcode colors or raw text styles.
6. **Localization**: Always use `context.t.[key]` via Slang; never hardcode user-facing strings. Run `melos run locale-gen` after editing translations.
7. **Asset Management**: Place assets in `packages/app_ui/assets/` and reference via `Assets.[category].[name].[method]()`. Never use raw string paths. Run `melos run asset-gen`.
8. **Logging & Security**: Use `flog()` or `getIt<Logger>()`. Never use raw `print()` or log sensitive PII.
9. **Imports Discipline**: Use package imports (`package:app_core/...`) in apps. Never use `../` to reach across packages and never import another package's private `/lib/src/`.
10. **Zero Hand-Edits on Generated Code**: Never manually edit `*.g.dart`, `*.gr.dart`, `strings.g.dart`, `assets.gen.dart`, `*.directories.g.dart`, or Hive registrars.

---

## Core Rules Index

Always adhere to the specific rules in `.agents/rules/` and `.cursor/rules/`:

1.  **Architecture & Feature Structure**: [.agents/rules/structure.md](file://.agents/rules/structure.md)
2.  **BLoC & State Management**: [.agents/rules/bloc.md](file://.agents/rules/bloc.md)
3.  **Atomic Design & UI Components**: [.agents/rules/atomic-design-rule.md](file://.agents/rules/atomic-design-rule.md)
4.  **Asset Management**: [.agents/rules/assets-rules.md](file://.agents/rules/assets-rules.md)
5.  **Navigation & Routing**: [.agents/rules/auto-route.md](file://.agents/rules/auto-route.md)
6.  **Flutter & Dart Best Practices**: [.agents/rules/flutter-dart.md](file://.agents/rules/flutter-dart.md)
7.  **Colors & Typography**: [.agents/rules/color.md](file://.agents/rules/color.md)
8.  **Figma to Flutter UI Conversion**: [.agents/rules/figma-to-app-ui.md](file://.agents/rules/figma-to-app-ui.md)

---

## Code Generation Commands

Run these commands using `run_command` whenever relevant files change:

| Change Type | Command | Description |
|---|---|---|
| **Translations** | `melos run locale-gen` | Generates Slang translation classes after editing `en.i18n.json` |
| **Assets** | `melos run asset-gen` | Generates `Assets` class after adding images/icons in `app_ui` |
| **Routes / Serialization** | `melos run build-runner` | Runs `build_runner` code generation for AutoRoute, models, BLoC |
| **Widgetbook** | `melos run widgetbook-gen` | Generates component use-case registry in `packages/widgetbook` |
| **Formatting** | `melos run format` | Runs `dart format` across all packages |
| **Static Analysis** | `flutter analyze` | Checks for lint warnings, type errors, or syntax issues |

---

## Available Skills & Workflows

All skills are available under both `.agents/skills/` and `.cursor/skills/`:

-   `/grill-with-docs` — Run the official iterative design interview and record the shared glossary/decisions. Install it locally with `bash scripts/install-grill-with-docs.sh`.
-   **Automatic transcript routing** — When a teammate supplies a client-call transcript for project understanding, delegate the complete task to the project-understanding subagent automatically.
-   `/refine` — Formulate complete specs from raw feature prompts before coding.
-   `/new-feature` — Implement a new feature using BLoC + TaskEither repository architecture.
-   `/change-flow` — Modify existing screen flow, layout, navigation, or interaction logic.
-   `/fix-bug` — Diagnose root cause and apply minimal fixes with verification.
-   `/pr-review` — Pre-PR audit of the codebase against architecture, BLoC, app_ui, localization, logging, and security best practices (writes `pr-review-report.md`).
-   `/dependency-audit` — Read-only audit of monorepo packages, find deprecations and outdated versions, and safely migrate one dependency at a time.
-   `/code-gen` — Automatically run code generation tools for translations, assets, routes, models, and widgetbook.
-   `/unit-test` — Author unit tests for BLoCs, Cubits, Repositories (`TaskEither`), and Models using `bloc_test` and `mocktail`.
-   `/widgetbook-component` — Build isolated widget preview use-cases in `packages/widgetbook` using `@widgetbook.UseCase`.
