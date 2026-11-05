# Flutter Dependency Audit

**Audit date:** 2026-10-12  
**Scope:** Read-only dependency, SDK, deprecation, analyzer, and test baseline review of the full Melos workspace.

## Executive summary

- The workspace has one deployable Flutter app (`app_core`), six shared/workspace Flutter packages, and a root Melos package. Workspace membership is declared in the root `pubspec.yaml`; there is no separate `melos.yaml`.
- No Dart test or integration-test files were found in the app or workspace packages. The baseline has no runnable Dart test suite.
- Workspace analysis reports **35 diagnostics**: one warning and 34 informational lint findings; no analyzer errors. Five dry-run fixes are available for closure parameter annotations in `apps/app_core/lib/app/app.dart`.
- No deprecated Flutter/Dart API use was reported by analysis. Deprecated annotations occur in generated `app_ui` asset helper code; no app call sites passing those deprecated parameters were found.
- No dependency was confirmed as discontinued. `data_connection_checker_nulls` is a maintenance concern: pub.dev lists version 0.0.2, published four years ago, and describes the package as beta; this is not enough evidence to label it discontinued.
- **P1 compatibility risk:** current CI pins Flutter 3.29.2, while the checked-out resolution requires Dart >=3.12.0 and Flutter >=3.44.0. The current dependency manifests and lockfile therefore do not establish a compatible CI baseline. See the recommendation caveat below.

## Environment and workspace

| Item | Observed |
|---|---|
| Installed Flutter | 3.44.1 stable (read from Flutter's version metadata; the launcher bootstrap attempts a protected SDK-cache write in this environment) |
| Installed Dart | 3.12.1 stable |
| Root declared Dart floor | `>=3.7.2 <4.0.0` |
| Locked SDK floor | Dart `>=3.12.0`; Flutter `>=3.44.0` |
| Melos locked version | 7.8.1; root constraint `^7.3.0` |
| Workspace layout | Pub workspace and Melos configuration in root `pubspec.yaml`; all six member packages use `resolution: workspace` |
| Lockfile | Root `pubspec.lock` resolves the workspace and is currently untracked in Git; `.gitignore` was already changed to make it visible |

### Applications and packages inspected

| Workspace name | Kind | Relationship |
|---|---|---|
| `app_core` | Flutter application | Depends on `api_client`, `app_notification_service`, `app_subscription`, `app_translations`, and `app_ui` |
| `api_client` | Shared Flutter package | API/Dio and Hive CE code |
| `app_notification_service` | Shared Flutter package | OneSignal integration |
| `app_subscription` | Shared Flutter package | In-app purchase abstraction |
| `app_translations` | Shared Flutter package/tooling | Slang localization generation |
| `app_ui` | Shared Flutter package | Shared UI, assets, and generators |
| `widgetbook_workspace` | Flutter tooling/workspace package | Depends on `app_ui` |
| Root package | Melos/workspace tooling | Owns workspace, overrides, and Melos scripts |

The root analysis options use `flutter_lints`; `app_core` and `app_ui` use `very_good_analysis`; package-specific options differ. `app_translations/analysis_options.yaml` excludes `lib/**`, so the root analysis run does not meaningfully analyze that package's library source.

CI in `.github/workflows/main.yml` installs Flutter **3.29.2**, runs `melos bs`, generators, and a production APK build. It does not run tests. Android tooling currently declares AGP **8.9.1**, Kotlin **2.0.0**, and Gradle **8.11.1**.

## Baseline checks

| Check | Result |
|---|---|
| `dart analyze .` | 35 diagnostics: one `unawaited_futures` warning at `packages/app_notification_service/lib/src/onesignal_service.dart:25`; 34 informational findings, primarily discarded Futures and closure parameter annotations. No analyzer errors. The command exits nonzero because diagnostics are configured; Dart also reports a telemetry-file permission issue when sandboxed. |
| `dart fix --dry-run` | Five proposed `avoid_types_on_closure_parameters` fixes in `apps/app_core/lib/app/app.dart`; no files changed. |
| Test inventory | No `*_test.dart`, `test/`, or `integration_test/` files found under `apps/` or `packages/`; no test suites to execute. |
| `dart pub outdated` | Completed read-only against pub.dev. It reports **38 dependencies constrained below a resolvable version**; full direct-dependency values are below. |
| Git baseline | Existing changes were present before this report: `.gitignore`, `apps/app_core/pubspec.yaml`, `packages/api_client/pubspec.yaml`, untracked root `pubspec.lock`, an untracked Cursor rule, and untracked IDE run configurations. These were preserved. |

## Prioritized findings

### P1 — CI/toolchain compatibility does not match the resolved workspace

The CI workflow pins Flutter 3.29.2, but the current lockfile says Dart >=3.12.0 and Flutter >=3.44.0. The selected graph includes packages whose cached pubspecs require Flutter >=3.44.0, including `hive_ce_flutter 2.4.0`, `webview_flutter_android 4.14.1`, and `widgetbook 3.25.0`. The current `hive_ce_generator 1.11.2` also depends on analyzer ^12, whose SDK floor is Dart 3.9.0. This conflicts with the repository's declared Dart floor of 3.7.2 and the CI Flutter 3.29.2 toolchain.

Treat the CI SDK baseline and the declared SDK floors as unresolved release compatibility work before relying on CI as a migration gate. This report does not change the SDK, manifests, or lockfile.

### P2 — `data_connection_checker_nulls` is stale and explicitly beta

`app_core` depends on `data_connection_checker_nulls ^0.0.2`, used by `network_helper.service.dart`. Pub.dev lists only version 0.0.2, published four years ago, and describes it as beta with an unverified uploader. The audit found no newer version, deprecation notice, or discontinued status, so this is a maintenance review item rather than a confirmed discontinued dependency. Evaluate a maintained replacement separately because this would be a package/API migration.

### P2 — `google_sign_in` has a major, contained modernization path

`app_core` resolves `google_sign_in 6.3.0`; the latest/resolvable release is 7.2.0. The dependency is used in `core/data/services/google_auth_helper.dart`. Version 7 changes to a singleton and requires explicit initialization; authentication and scope authorization are separate, the app should track sign-in state with authentication events, and `signIn`/`signInSilently` are replaced by the new flow. The current helper uses the old constructor, `.signIn()`, `.currentUser`, and `.authentication` token flow, so this needs focused source migration and sign-in behavior verification. The package changelog documents Flutter 3.29 / Dart 3.7 as its minimum for 7.2.0; the existing CI pin meets that package floor, though the broader workspace SDK mismatch above remains. See the [official changelog](https://pub.dev/packages/google_sign_in/changelog) and [6.x-to-7.x migration guide](https://github.com/flutter/packages/blob/main/packages/google_sign_in/google_sign_in/MIGRATION.md).

### P2 — `connectivity_plus` 7 requires Android toolchain work

`app_core` resolves `connectivity_plus 6.1.5`; 7.3.2 is the latest/resolvable release. Version 7 is a breaking release and requires Android Gradle Plugin >=8.12.1, Gradle >=8.13, and Kotlin 2.2.0. The repository currently has AGP 8.9.1, Gradle 8.11.1, and Kotlin 2.0.0, so do not treat this as a dependency-only update. See the [official changelog](https://pub.dev/packages/connectivity_plus/changelog).

### P2 — Melos 8 is a major tooling migration, not a routine bump

The root resolves Melos 7.8.1; 8.9.0 is latest. The repository already uses Pub workspaces and root `pubspec.yaml` Melos configuration, but Melos 8 requires Dart >=3.9 and changes version/build-number behavior. The current root and CI SDK floors are below that requirement. Defer until SDK policy and release-versioning behavior are addressed. See the [official Melos migration notes](https://pub.dev/packages/melos).

### Generated deprecated API surface

`packages/app_ui/lib/src/gen/assets.gen.dart` contains deprecated generated helper parameters (`color`, `colorBlendMode`, and `cacheColorFilter`) and deprecated generated package arguments. Analyzer emitted no `deprecated_member_use` diagnostics and no application call site supplying those parameters was found. These are generated declarations, not confirmed deprecated API use in handwritten app code.

## Dependency freshness data

Values below are from the workspace-level `dart pub outdated` output on 2026-10-12. `Upgradable` respects the current constraints; `Resolvable` is the newest version the current graph can resolve after compatible constraint changes; `Latest` is the newest published stable version. A newer `Resolvable`/`Latest` across a major boundary is not automatically a safe update.

| Package | Owning workspace package(s) | Current | Upgradable | Resolvable | Latest |
|---|---|---:|---:|---:|---:|
| `animated_custom_dropdown` | `app_ui` | 3.1.1 | 3.1.1 | 4.0.0 | 4.0.0 |
| `cached_network_image` | `app_core`, `app_ui` | 3.4.1 | 3.4.1 | 4.0.3 | 4.0.4 |
| `connectivity_plus` | `app_core` | 6.1.5 | 6.1.5 | 7.3.2 | 7.3.2 |
| `cupertino_icons` | `app_core` | 1.0.9 | 1.0.9 | 2.0.0 | 2.0.0 |
| `device_info_plus` | `app_core` | 11.5.0 | 11.5.0 | 13.3.0 | 13.3.0 |
| `dio_cache_interceptor` | `api_client` | 3.5.1 | 3.5.1 | 3.5.1 | 4.0.7 |
| `equatable` | `app_core`, `api_client`, `app_subscription`, `app_ui` | 2.1.0 | 2.1.0 | 3.0.0 | 3.0.0 |
| `firebase_auth` | `app_core` | 5.7.0 | 5.7.0 | 6.7.0 | 6.7.0 |
| `firebase_core` | `app_core` | 3.15.2 | 3.15.2 | 4.15.0 | 4.15.0 |
| `firebase_crashlytics` | `app_core` | 4.3.10 | 4.3.10 | 5.4.0 | 5.4.0 |
| `firebase_remote_config` | `app_core` | 5.5.0 | 5.5.0 | 6.7.0 | 6.7.0 |
| `google_sign_in` | `app_core` | 6.3.0 | 6.3.0 | 7.2.0 | 7.2.0 |
| `image_cropper` | `app_core` | 11.0.0 | 11.0.0 | 12.2.1 | 13.0.0 |
| `package_info_plus` | `app_core` | 8.3.1 | 8.3.1 | 10.2.2 | 10.2.2 |
| `permission_handler` | `app_core` | 12.0.3 | 12.0.3 | 13.0.2 | 13.0.2 |
| `pinput` | `app_ui` | 6.0.2 | 6.0.2 | 7.0.0 | 7.0.0 |
| `sign_in_with_apple` | `app_core` | 7.0.1 | 7.0.1 | 8.2.0 | 8.2.0 |
| `skeletonizer` | `app_ui` | 2.1.3 | 2.1.3 | 3.0.0 | 3.0.0 |
| `build_runner` | `app_core`, `app_translations`, `app_ui`, root tooling | 2.15.1 | 2.15.1 | 2.15.1 | 2.16.2 |
| `hive_ce_generator` | `app_core`, `api_client` | 1.11.2 | 1.11.2 | 1.11.2 | 1.11.3 |
| `melos` | root tooling, `app_translations` | 7.8.1 | 7.8.1 | 7.8.1 | 8.9.0 |
| `very_good_analysis` | `app_core`, `app_ui`, `app_notification_service` | 10.3.0 | 10.3.0 | 10.3.0 | 11.0.0 |

The report also identified transitive release lines to review when their direct packages are migrated: Firebase platform packages, cached image platform packages, Google Sign-In platform packages, image-cropper platform packages, `permission_handler_android`, `analyzer`, `_fe_analyzer_shared`, `build`, and `source_gen`. The root overrides `source_gen ^4.1.1` and `web ^1.1.1`; override constraints should be reviewed deliberately rather than relaxed as part of unrelated upgrades.

## First dependency recommendation from the read-only audit

**Recommend `google_sign_in` in `app_core`, from 6.3.0 to 7.2.0**, as the first focused package migration after confirming the workspace's Flutter/Dart CI baseline. It has a maintained, stable target; the package changelog reports a minimum of Flutter 3.29 / Dart 3.7 for 7.2.0; and usage is concentrated in one helper. Its API migration is significant but bounded to sign-in initialization, authentication events, scope authorization, and user/token handling. Verify cancellation/error cases and Android/iOS sign-in behavior, then analyze and build the affected app. No package or source changes are included in this audit.

## Approved update and verification

After approval, `google_sign_in` was upgraded to 7.2.0 in `app_core`, and the helper was migrated to the singleton initialization, `authenticate`, separate scope authorization, and new authentication token APIs. Cancellation continues to use the localized operation-cancelled message. The root lockfile now resolves `google_sign_in 7.2.0`, Android 7.2.17, iOS 6.3.6, platform interface 3.1.0, and web 1.1.3.

Verification on the installed Flutter 3.44.1 / Dart 3.12.1 SDK:

- `dart analyze apps/app_core` completed with no errors or warnings; 30 pre-existing informational lint notices remain.
- The production Android APK build (`flutter build apk -t lib/main_production.dart --flavor prod`) succeeded.
- `git diff --check` passed. No tests exist in the workspace to run.

The P1 SDK mismatch has been resolved by updating `.github/workflows/main.yml` from Flutter 3.29.2 to Flutter 3.44.1. This matches the installed SDK used for the successful build and satisfies the lockfile's Flutter >=3.44.0 / Dart >=3.12.0 requirements. The Android build also emitted existing Gradle/Kotlin toolchain deprecation warnings.

The workflow's local build steps were then rerun in order: `melos bs`, app code generation, localization generation, asset generation, and the production APK build. All completed successfully. A workspace-wide analysis still reports the same 35 baseline diagnostics (one warning and 34 info notices), with no analyzer errors. The newer `build_runner` reports `--delete-conflicting-outputs` as removed and ignored, but both generator runs succeeded. The CI workflow's Firebase App Distribution step was not run locally.

### Follow-up resolution

The previously noted analyzer findings were resolved: detached futures are now explicitly handled or awaited, and the OneSignal initialization is awaited. The removed `build_runner --delete-conflicting-outputs` option was removed from the Melos scripts. A fresh `dart analyze .` on the workspace now reports **No issues found**; `git diff --check` also passes.

To satisfy the Android requirements of the upgraded plugins, the app's Android toolchain was raised to AGP 8.12.1, Kotlin Gradle Plugin 2.2.20, and Gradle 8.14.6. (Gradle 8.14.0 was not a published distribution; the wrapper now uses the available patched 8.14.6 release.) The CI workflow remains pinned to Flutter 3.44.1, matching the local SDK and the resolved workspace floor. The Firebase dependency family was upgraded together to Core 4.15.0, Auth 6.7.0, Crashlytics 5.4.0, and Remote Config 6.7.0 to satisfy their cross-package constraints. `device_info_plus` 13.3.0, `sign_in_with_apple` 8.2.0, and `package_info_plus` 10.2.2 were also upgraded to meet the Android plugin migration/tooling requirements. The workspace lockfile records the resolved versions.

Verification after these changes:

- `dart analyze .`: **No issues found**.
- `flutter build apk -t lib/main_production.dart --flavor prod`: **passed**, producing `apps/app_core/build/app/outputs/flutter-apk/app-prod-release.apk` (63.5 MB).
- `git diff --check`: passed.
- Build notices remain for the app and Firebase plugins applying Kotlin Gradle Plugin, and for Java 8 source/target options in some Android dependencies. The app's Kotlin build migration cannot be completed safely under the pinned Flutter 3.44.1 toolchain because Flutter's built-in Kotlin migration requires a newer Flutter/Android plugin baseline. These notices do not prevent the current build.
- The CI Firebase App Distribution command remains unrun: executing it publishes the APK to the configured Firebase project. The build artifact is ready, but that external distribution action has not been approved in this session.

### Migration of `connectivity_plus` (6.1.5 -> 7.3.2)

- **Target Package**: `apps/app_core/pubspec.yaml`
- **Version Bump**: `connectivity_plus: ^6.1.3` -> `^7.3.2` (locked at `7.3.2`, transitive `dbus 0.8.0`, `nm 0.6.0`).
- **Source Code Verification**: Existing calls in `connectivity_service.dart` (`Connectivity().onConnectivityChanged.listen(...)`, checking `result.first != ConnectivityResult.none`) remain fully compatible with v7.
- **Analysis**: `dart analyze apps/app_core` returned **No issues found**.
- **Build Verification**: `flutter build apk -t lib/main_production.dart --flavor prod` passed in 211.4s, producing `app-prod-release.apk` (63.9 MB).

