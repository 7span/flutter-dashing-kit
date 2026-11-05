---
name: widgetbook-component
description: Create and register Widgetbook use-cases for UI components in packages/app_ui and packages/widgetbook. Trigger when adding new design system components or modifying UI atoms/molecules/organisms.
---

# Widgetbook Component Skill

Guidelines for documenting and cataloging UI components from `packages/app_ui` into `packages/widgetbook`.

---

## 1. Directory Structure

Mirror the component level (atoms, molecules, organisms) inside `packages/widgetbook/lib/widgets/`:

```
packages/widgetbook/lib/widgets/
├── atoms/
│   ├── app_text.dart
│   └── spacing.dart
├── molecules/
│   ├── app_button.dart
│   └── app_text_field.dart
└── organisms/
    └── custom_dialog.dart
```

---

## 2. Writing a Use-Case

Use the `@widgetbook.UseCase` annotation and configure knobs so developers can test variations interactively:

```dart
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: [ComponentName],
)
Widget default[ComponentName]UseCase(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Sample Text',
  );

  final isEnabled = context.knobs.boolean(
    label: 'Is Enabled',
    initialValue: true,
  );

  return Center(
    child: [ComponentName](
      text: label,
      isEnabled: isEnabled,
    ),
  );
}
```

---

## 3. Code Generation Command

After adding or updating a `@widgetbook.UseCase`:

```bash
melos run widgetbook-gen
```

This updates `packages/widgetbook/lib/main.directories.g.dart`.

---

## 4. Verification

Run static analysis on the widgetbook package:
```bash
flutter analyze packages/widgetbook
```
Confirm zero errors and zero warnings.

