# AI Agent Operating Contract

This file is a generic entrypoint for AI agents working in this repository. It must remain capability-neutral: do not treat any one skill, workflow, or agent as the only supported future capability.

## Discover available instructions

Before acting, inspect the current project and relevant parent directories for instruction and capability files. The list is extensible and may grow over time; do not assume it is complete.

Look for:

- `AGENTS.md` files in the current and parent directories (see detailed monorepo guidelines in [.agents/AGENTS.md](.agents/AGENTS.md)).
- `.agents/skills/*/SKILL.md`.
- `.agents/workflows/*`.
- `.agents/rules/*`.
- Environment-specific instructions such as `.cursor/rules/*`, `.cursor/skills/*`, `.trae/rules/*`, `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md`.

Load only the instructions relevant to the current request. A skill’s description and trigger determine whether it applies; do not invoke unrelated skills.

## Instruction precedence

When instructions conflict, apply this order:

1. The user’s current request.
2. The closest applicable project instruction.
3. Parent-directory or global instructions.
4. General agent behavior.

Follow explicit safety and scope boundaries from the applicable skill. Ask the user when an unresolved decision materially changes the requested outcome; do not invent requirements.

## 10 Golden Rules of the Monorepo

For deep technical best practices, refer to [.agents/skills/pr-review/resources/best-practices.md](.agents/skills/pr-review/resources/best-practices.md) and [.agents/AGENTS.md](.agents/AGENTS.md):

1. **Architecture**: 4-layer structure (`bloc/`, `model/`, `repository/`, `screen/`) under `lib/modules/[feature]/`.
2. **Repositories**: Return `TaskEither<Failure, T>` using functional error handling from `fpdart`; never throw unhandled exceptions.
3. **BLoC & State**: Sealed events in past tense; private constructor states (`FeatureState._()`) with named constructors, `copyWith`, and `Equatable`.
4. **UI Components**: Always use `app_ui` components (`AppText`, `AppButton`, `VSpace`, `HSpace`, `AppScaffold`). Never use raw `SizedBox` for spacing or raw Material buttons.
5. **Color & Typography**: Use `context.colorScheme` and `context.textTheme` via theme extensions; never hardcode colors or raw text styles.
6. **Localization**: Always use `context.t.[key]` via Slang; never hardcode user-facing strings. Run `melos run locale-gen`.
7. **Assets**: Place assets in `packages/app_ui/assets/` and reference with `Assets.[category].[name].[method]()`. Run `melos run asset-gen`.
8. **Logging & Security**: Use `flog()` or `getIt<Logger>()`. Never use raw `print()` or log sensitive PII.
9. **Imports**: Prefer package imports within app (`package:app_core/...`). Never use `../` to cross packages or import from private `/lib/src/`.
10. **Zero Hand Edits on Generated Code**: Never hand-edit `*.g.dart`, `*.gr.dart`, `strings.g.dart`, `assets.gen.dart`, or Hive registrars.

## Change discipline

Inspect before modifying. Keep changes within the user’s requested scope. Preserve unrelated work already present in the repository. Before reporting completion, verify the requested outcome and identify files changed and checks performed.

## Project-specific capability discovery

Project-specific skills and rules are stored under `.agents/` and mirrored under `.cursor/`. Future capabilities should be added there with their own focused instructions and workflows.
