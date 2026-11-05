---
name: code-gen
description: >
  Runs code generation tools for translations, assets, or build runner in the
  agents-at-mobile-flutter monorepo. Triggered when strings in en.i18n.json change,
  new assets are added to app_ui, or routes/models/blocs are added/updated.
---

# Code Gen Skill

Automates running repository code generators based on modified assets or files.

---

## Trigger Mappings

| File / Folder Modified | Action / Command | Description |
|---|---|---|
| `packages/app_translations/assets/i18n/*.json` | `melos run locale-gen` | Regenerates slang translation classes |
| `packages/app_ui/assets/**` | `melos run asset-gen` | Generates type-safe `Assets` class |
| `@RoutePage()`, `AppRouter`, `@JsonSerializable` | `melos run build-runner` | Regenerates AutoRoute pages, router, and JSON serializers |
| Any Dart file | `flutter analyze` | Verifies zero errors or warnings after code generation |

---

## Verification Protocol
1. After running any generation command, run `flutter analyze` on affected module.
2. Confirm zero errors and zero warnings.
