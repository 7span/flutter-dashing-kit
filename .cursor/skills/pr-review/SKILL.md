---
name: pr-review
description: Pre-PR audit of the Flutter monorepo project against its documented best practices (architecture, BLoC/Repository/TaskEither, app_ui, i18n, logging/PII, generated files, bugs and risk). Use before opening a PR, or when asked to review, audit, or check the code. Read-only; writes only pr-review-report.md.
---

# pr-review

Audit the project against `resources/best-practices.md` (the single source of truth; read it first).
Never edit source files. The only file you may write is `pr-review-report.md` at the repo root.

## Input
Optional path argument (e.g. `apps/app_core/lib/modules/auth`). Default: whole repo (`apps/`, `packages/`).
Always skip: `*.g.dart`, `*.gr.dart`, `**/gen/**`, `packages/app_translations/lib/gen/**`, Hive registrar files, `.dart_tool/`, `build/`, `bricks/`.
Hand-edited generated files (G1): only checkable for tracked files via `git diff -- '*.g.dart' '*.gr.dart'` etc. If the scope is untracked or has no git history, say G1 was not checked.

## Steps
1. **Read** `resources/best-practices.md`.
2. **Tooling** (summarise output, never fix):
   - Prerequisite: analyze is meaningless without resolved dependencies. If `.dart_tool/package_config.json` is missing in a package, run `flutter pub get` or `melos bootstrap` (dependency resolution only, allowed). If that fails, G2 is `unknown`.
   - `dart format --output=none --set-exit-if-changed <scope>`
   - `melos run analyze` (fallback: `flutter analyze` or `dart analyze . --fatal-infos`). If the output is dominated by unresolved-package/`override_on_non_overriding_member` noise, the environment is broken: report G2 as `unknown` and why, do not report the noise as findings.
   - Do NOT run `build_runner`, `locale-gen`, `asset-gen`, or any build. If routes/translations/assets changed and generated output looks stale (G4), say which generator to run. If generated files do not exist locally (e.g. `app_router.gr.dart` missing or gitignored), G4 is `unknown`; say that a generator must be run, do not call it stale.
3. **Mechanical rules**. Use ripgrep (`rg`) or git grep with regex patterns. Exclude generated files. Count per rule, keep ~5 examples:
   - U1 `Scaffold(` not preceded by `App`
   - U2 `SizedBox(` with `height:`/`width:` only (instead of `VSpace`/`HSpace`)
   - U3 `Text(` not `AppText(`/`RichText`/`SelectableText`
   - U4 `ElevatedButton|TextButton|OutlinedButton` (instead of `AppButton`)
   - U5 `Color(0x` and `Colors\.` except `transparent` (instead of `context.colorScheme`)
   - U6 `Image.asset(|SvgPicture.asset(` with string literal (instead of `Assets.*`)
   - U7 methods/functions returning `Widget` (`^\s*Widget \w+\(`), excluding the preceding line `@override` and the names `build`/`wrappedRoute`/`createState` (extract `StatelessWidget` instead)
   - U8 hardcoded user-facing literals: `text: ['"]`, `Text\(['"]`, `title: ['"]`, `hintText: ['"]`, `SnackBar\(.*['"]` followed by a letter (instead of `context.t.*`; ignore keys, routes, assets, log messages; borderline cases such as share-sheet subjects are nits, not should-fix)
   - L1 `\bprint\(|debugPrint\(|dart:developer` `log(` (instead of `flog()` or `getIt<Logger>()`)
   - L2 any log call (`flog`, `logger.*`, `print`) whose argument mentions token/otp/phone/mobile/email/password/selfie/secret
   - A2 `ApiClient|Dio|Hive` referenced directly from `*/screen*/` files
   - A3 repositories lacking `abstract interface class I`
   - A4 `try`/`catch` inside `*/repository/*` (use `TaskEither`)
   - A7 states with `.loading()`/`._(` constructors (prefer single const constructor with `copyWith`)
   - A10 `package:\w+/src/` (importing private src across packages)
   - I1 `../` imports or `/lib/` in import paths; inside `app_core` use `package:app_core/...`
   - L3 secrets: key/secret/token literals, committed `.env*`
   - L4 repo-wide (not scope-limited): `git diff` of `AndroidManifest.xml`, `Info.plist`/entitlements for overly broad permissions
   Always confirm a hit by reading context before counting it; drop false positives (e.g. inside `packages/app_ui` which defines the primitives).
4. **Read-the-code checks** ("Bugs and risk" in the checklist). Prioritise recently modified files (`git log -n 30 --name-only`, `git status`) and Bloc/Cubit/repository/screen files. Read the code; do not infer from names. Report only issues you can point to at `file:line` with a concrete failure scenario.
5. **Report.**

## Severity
Blocker (B) / Should-fix (S) / Nit (N) exactly as tagged in the checklist. A rule violated 800 times is still one rule: give the count.

## Output
Write `pr-review-report.md` (overwrite) and print a short summary in chat.

```
# PR review report - <date> - scope: <path|whole project>
Verdict: READY / NOT READY / INCOMPLETE (any blocker => NOT READY; a blocker rule that could not be evaluated, e.g. G2 analyze, => INCOMPLETE, never READY)
## Tooling      format: pass/fail, analyze: pass/fail (+ key errors)
## Blockers     <rule id> <title> - file:line - why it matters - suggested fix
## Should-fix   per rule: count, ~5 examples (file:line), fix hint
## Nits         per rule: count only
## Bugs and risk  file:line, scenario, fix
## Not checked  what was skipped and why
```

Be honest in "Not checked" (e.g. analyze could not run, generator staleness unknown). After the report, offer to fix; do not fix unprompted.

