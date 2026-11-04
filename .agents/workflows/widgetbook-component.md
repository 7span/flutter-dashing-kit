# /widgetbook-component — Widgetbook Preview Workflow

**Usage:** `/widgetbook-component <widget_path>`

---

## What This Workflow Does

1. Creates an isolated Widgetbook use-case preview for an existing `app_ui` or screen widget.
2. Follows `.agents/skills/widgetbook-component/SKILL.md`.
3. Places preview use-cases in `packages/widgetbook/lib/use_cases/`.
4. Runs `melos run widgetbook-gen` to regenerate the catalog.
5. Verifies with `flutter analyze`.

---

## Instructions

When the user types `/widgetbook-component <widget>`:

1. Locate the component widget file and review its properties and dependencies.
2. Read `.agents/skills/widgetbook-component/SKILL.md`.
3. Create the preview file in `packages/widgetbook/lib/use_cases/` with `@widgetbook.UseCase(...)`.
4. Provide realistic mock data or fallback values.
5. Run `melos run widgetbook-gen`.
6. Run `flutter analyze` to ensure zero compilation or analyzer errors.

