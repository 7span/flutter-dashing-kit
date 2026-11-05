# /code-gen — Automated Code Generation Workflow

**Usage:** `/code-gen [scope]`

---

## What This Workflow Does

Automatically triggers code generators based on modified project files across the Melos monorepo.

---

## Trigger Mappings

| Modified Area | Command | Purpose |
|---|---|---|
| `packages/app_translations/assets/i18n/*.json` | `melos run locale-gen` | Slang translation classes |
| `packages/app_ui/assets/**` | `melos run asset-gen` | FlutterGen `Assets` class |
| Routes, models, or BLoCs | `melos run build-runner` | AutoRoute, JSON serializable, injectable |
| Widgetbook use-cases | `melos run widgetbook-gen` | Widgetbook component directory |

---

## Instructions

When the user types `/code-gen`:

1. Check `git status` to identify which assets, translations, models, or routes changed.
2. Run only the relevant generation scripts.
3. Run `flutter analyze` on affected packages to confirm zero errors or warnings.
4. Report generated files and status.

