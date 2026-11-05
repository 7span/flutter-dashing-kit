---
name: flutter-dependency-audit
description: Safely audit, analyze, and migrate dependencies one-by-one in a Flutter/Dart Melos monorepo.
---

# Flutter Dependency Audit Skill

## Objective

Safely maintain a Flutter/Dart Melos monorepo by identifying deprecated packages and APIs, recommending compatible stable versions, and upgrading one dependency at a time.

## Phase 1: Read-only discovery

1. Inspect Git status and preserve all user changes.
2. Identify the Flutter and Dart SDK versions.
3. Inspect the root `pubspec.yaml`, Melos configuration, workspace packages, application manifests, lockfiles, analysis options, and existing scripts.
4. Identify shared packages, application dependencies, code generators, platform plugins, and build flavors.
5. Identify the workspace mechanism:
   - Check if root `pubspec.yaml` defines `workspace: [...]` (Dart/Pub Workspaces standard in Melos 7+ / Dart 3.5+).
   - Or if packages are managed via standalone configs requiring Melos bootstrapping.
6. Never assume every package uses the same SDK constraints or build commands.

Do not modify project files during the initial audit.

## Phase 2: Dependency and API audit

Use the relevant commands suited to the repository's workspace architecture:

- **Pub Workspaces (Root-level execution)**:
  When `workspace:` is declared in the root `pubspec.yaml`, run:
  - `flutter pub outdated` (or `dart pub outdated`) directly from the workspace root to assess all member packages within a unified resolution graph.
  - `flutter pub deps` / `dart pub deps` from the workspace root.
- **Package-specific & Legacy Melos execution**:
  When inspecting an isolated package or running package-scoped checks:
  - Run `flutter pub outdated` for Flutter packages and `dart pub outdated` for pure Dart packages inside that package directory, or use `melos exec -- flutter pub outdated`.
- **Static Analysis & Diagnostics**:
  - `melos run analyze` or `flutter analyze` / `dart analyze`.
  - `dart fix --dry-run` to detect automated deprecation remedies without applying them.

Choose Flutter commands for Flutter packages and Dart commands for pure Dart packages. Use existing Melos scripts where available (`melos.yaml` or root `pubspec.yaml` scripts block). Do not blindly run every command in every directory.

Inspect package changelogs, pub.dev metadata, official documentation, repository maintenance notices, and migration guides.

Distinguish:
- Outdated but supported packages.
- Deprecated packages or APIs.
- Discontinued or unmaintained packages.
- Major upgrades with breaking changes.
- SDK or transitive dependency conflicts.
- Existing analyzer errors unrelated to upgrades.

Never label a package deprecated solely because a newer version exists.

## Phase 3: Report findings

Write `docs/dependency-audit/REPORT.md` (creating the directory if it does not already exist) after verifying it will not unintentionally overwrite unsaved user work.

Include:
- Audit date and SDK versions.
- Workspace packages and applications inspected.
- Baseline analysis and test results.
- Current, upgradable, resolvable, and latest versions when reported by Pub.
- Deprecation evidence, maintenance status, and official source links.
- Recommended target version.
- Breaking changes and affected packages/apps.
- Priority, risk, and verification status.

Priorities:
- P0: Confirmed critical security or compatibility issue.
- P1: Release-blocking or urgent maintenance issue.
- P2: Important deprecation or migration.
- P3: Routine compatible maintenance.

Do not invent version numbers, deprecation claims, vulnerabilities, or compatibility guarantees.

## Phase 4: Select and approve one dependency

Present the prioritized report and recommend exactly one first dependency to migrate.

Explain:
- Why it is the best first candidate (e.g., low-risk leaf dependency vs. prerequisite core package).
- Current and proposed versions.
- SDK compatibility.
- Migration steps and official references.
- Affected apps and shared packages.
- Required tests, code generators, and platform builds.

**Wait for explicit approval before changing dependencies or source code.**

## Phase 5: Migrate one dependency

1. Recheck Git status.
2. Review the package's changelog and migration guide.
3. Update only the approved dependency in the relevant `pubspec.yaml` (root or specific package).
4. Change only the source code and configuration strictly required for that migration.
5. Run `flutter pub get` or `dart pub get` in the appropriate workspace context (at the root for Pub Workspaces, or via `melos bootstrap` / package dir).
6. Investigate dependency conflicts rather than hiding them with dependency overrides.
7. If the dependency involves code generation (`build_runner`, `freezed`, `json_serializable`, `auto_route_generator`, etc.):
   - Run the appropriate generator script (e.g. `dart run build_runner build --delete-conflicting-outputs` or `melos run build-runner`).
8. Review all manifest, lockfile, and source changes.
9. Stop and request approval if another dependency must change beyond the approved scope.

Never run a bulk upgrade or discard unrelated user changes.

## Phase 6: Verify

Run relevant checks for the affected package and its dependents:

- **Dependency resolution**: Confirm clean pub get without conflicting overrides.
- **Code generation**: Invalidate/regenerate code if generators or annotated models were touched.
- **Static analysis**: Run `melos run analyze` or `flutter analyze` / `dart analyze`.
- **Unit and widget tests**: Run targeted tests for affected modules (`flutter test` / `dart test`).
- **Native Platform & Plugin Verification**:
  - If the upgraded package contains an iOS/macOS plugin: run `pod install` (or `pod repo update`) in the app's `ios/` directory to verify CocoaPods specs and deployment targets resolve cleanly.
  - If the package contains an Android plugin: verify Gradle synchronization, Kotlin version compatibility, and minimum `compileSdk` alignment.
- **Application Builds**:
  - Android builds (`flutter build apk --debug` or flavor-specific) for affected apps.
  - iOS builds when macOS/Xcode is available.

Compare results against the baseline. Report pre-existing failures separately.

If verification fails, investigate a minimal correction or revert only the migration's own changes without overwriting user work.

Do not report success when a required check failed or was skipped.

## Phase 7: Complete one migration

Report:
- Dependency and version before/after.
- Files changed.
- Migration steps performed.
- Analyzer, generator, test, and build results.
- Remaining warnings and risks.
- Completion, rollback, or blocked status.

Update `docs/dependency-audit/REPORT.md` with verified results. Stop after one dependency and ask whether to proceed to the next.

## Safety rules

- No bulk dependency upgrades.
- No destructive Git commands.
- No unapproved commits, pushes, or releases.
- No unrelated refactoring or formatting.
- No automatic application of unrelated Dart fixes.
- No false claims about tests, builds, or package deprecation.
- If network access or a platform tool is unavailable, explicitly mark verification as pending.

