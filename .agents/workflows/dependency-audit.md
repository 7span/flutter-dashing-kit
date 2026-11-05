# /dependency-audit — Dependency & API Audit Workflow

**Usage:** `/dependency-audit`

---

## What This Workflow Does

1. Inspects the repository environment (Flutter/Dart SDK, Melos Pub Workspace).
2. Performs a read-only audit of all outdated and resolvable packages using `flutter pub outdated`.
3. Documents findings in `docs/dependency-audit/REPORT.md`.
4. Recommends exactly ONE prioritized dependency to upgrade first.
5. Waits for explicit user approval before modifying `pubspec.yaml` or source code.
6. Once approved, performs single-dependency migration, runs code generation / native checks, and verifies with `flutter analyze` and builds.

---

## Instructions

When the user types `/dependency-audit`:

1. **Load `.agents/skills/flutter-dependency-audit/SKILL.md`**.
2. **Execute Phase 1 & Phase 2** (read-only discovery and audit).
3. **Write / update `docs/dependency-audit/REPORT.md`** (Phase 3).
4. **Recommend exactly one upgrade candidate** and stop to wait for user approval (Phase 4).
5. Never perform bulk upgrades or apply unapproved changes.

