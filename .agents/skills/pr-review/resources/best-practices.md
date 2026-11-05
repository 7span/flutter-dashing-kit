# Flutter Monorepo Best Practices

Approved by the project owner. Single source of truth for `/pr-review`.

Severity: B = blocker, S = should-fix, N = nit. "Real API" names were read from `packages/app_ui`.

## Architecture
| # | Rule | Sev |
|---|------|-----|
| A1 | Features live in `apps/app_core/lib/modules/<feature>/` with `bloc|cubit/`, `model/`, `repository/`, `screen|screens/`. | S |
| A2 | Widgets never call `ApiClient`/Dio/Hive/repositories directly; they go through a Bloc/Cubit. | B |
| A3 | Repository file has `abstract interface class I<Feature>Repository` + implementation in the same file. Blocs/Cubits take the interface via constructor. | S |
| A4 | Repository methods return `TaskEither<Failure, T>`; no `try/catch` in repositories (use `TaskEither.tryCatch`). Use `RepositoryUtils` where it fits. Failures: `APIFailure`, `ModelConversionFailure`. | S |
| A5 | Blocs/Cubits fold the `TaskEither` result and emit explicit loading/loaded/error states. `try/catch` is allowed in Blocs but never empty. | S |
| A6 | Events: `sealed class ...Event extends Equatable`, concrete `final class`. | N |
| A7 | State: `final class ...State extends Equatable`, ONE const constructor with defaults, `copyWith`, full `props`. No `.loading()/.error()` named constructors, no `._()`. | S |
| A8 | Screens with Bloc/Cubit use `@RoutePage()` + `AutoRouteWrapper` and are registered in `app_router.dart`. | S |
| A9 | No Bloc-to-Bloc direct calls; coordinate with `BlocListener` in UI. | S |
| A10 | No import of another package's `lib/src`. | B |

## UI (`packages/app_ui`)
| # | Rule | Sev |
|---|------|-----|
| U1 | `AppScaffold`, never raw `Scaffold`. | S |
| U2 | Spacing: `VSpace.xxsmall4()/xsmall8()/small12()/medium16()/large24()/xlarge32()...` and `HSpace.*`; never `SizedBox(height|width: n)` for spacing. Paddings use `Insets.*`, radii use `AppBorderRadius.*`. | S |
| U3 | Text: `AppText` (constructors `AppText.base`, `AppText.paragraph`, `AppText.s`, `AppText.L`, `AppText.XL`, `AppText.brand`, `AppText.regular10`, `AppText.subTitle10`, `AppText.xsSemiBold`, etc. or `level:`), never raw `Text(`. | S |
| U4 | Buttons: `AppButton` (`buttonType: ButtonType.*`); never `ElevatedButton/TextButton/OutlinedButton`. | S |
| U5 | Colors: `context.colorScheme.*`. `Color(0x...)` banned (S). `Colors.*` banned except `Colors.transparent` (S). | S |
| U6 | Assets via FlutterGen `Assets.*`; no `Image.asset("...")` / `SvgPicture.asset("...")` strings. | S |
| U7 | No method/function returning `Widget` (incl. private `_buildX`); extract a `StatelessWidget` class. | S |
| U8 | User-facing strings via `context.t.*` (Slang, `packages/app_translations/assets/i18n/en.i18n.json`); no hardcoded literals. | S |
| U9 | Dispose controllers/focus nodes/animation controllers/subscriptions; `mounted` check after `await` before using `BuildContext`/`setState`. | S |
| U10 | `const` constructors/literals where possible; no expensive work in `build`. | N |

## Logging / privacy / security
| # | Rule | Sev |
|---|------|-----|
| L1 | `print`, `debugPrint`, `dart:developer log` banned. Log only via the registered `Logger` (`getIt<Logger>()`) or `flog()`. | S |
| L2 | Tokens, OTPs, phone numbers, emails, passwords, selfie/image data, or other PII in ANY log call. | B |
| L3 | Secrets/keys/credentials in source or committed `.env*`. | B |
| L4 | Android/iOS permission, entitlement, or URL-scheme changes (`AndroidManifest.xml`, `Info.plist`) that are broader than the feature needs. | B |
| L5 | Tokens/PII stored outside the existing secure storage/Hive service. | B |

## Generated code / tooling
| # | Rule | Sev |
|---|------|-----|
| G1 | Hand-edited `*.g.dart`, `*.gr.dart`, FlutterGen, Slang output, Hive registrar. | B |
| G2 | `melos run analyze` (`flutter analyze` / `dart analyze . --fatal-infos`) fails. | B |
| G3 | `dart format` would change files. | N |
| G4 | Routes/translations/assets changed but generator not re-run (generated file stale). | S |

## Bugs and risk (read-the-code checks)
Emit after Bloc close; unawaited futures; missing droppable/sequential transformer on tap-spam events; unhandled `Either` left side; null-assertion `!` on API data; setState/context use after await without `mounted`; stream/timer leaks; race between async handlers; pagination off-by-one / `hasReachedMax`; shared mutable state in singletons.

## Imports
| # | Rule | Sev |
|---|------|-----|
| I1 | Inside `app_core` use `package:app_core/...` imports (project style). No `../` across package boundaries, no `/lib/` in paths, no other package's `lib/src`. | N |
| I2 | Remove unused imports. | N |

## Sanctioned helpers
`flog()` (`apps/app_core/lib/app/helpers/logger_helper.dart`) wraps `getIt<Logger>()` and counts as the approved logging entry point (see L1).

