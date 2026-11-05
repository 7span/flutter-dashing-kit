---
trigger: always_on
glob:
description: Enforce consistent color + typography usage in Flutter UI. Apply this rule whenever editing widgets/screens so colors come from the theme via `context.colorScheme` (no hardcoded hex) and text uses `AppText`/`context.textTheme` instead of raw `Text`/ad-hoc `TextStyle`.
---


## Overview
This rule enforces consistent usage of **colors** and **typography** across the project.

Use the theme extensions in `extensions.dart` (e.g. `context.colorScheme`, `context.textTheme`).
We follow Material conventions, so to use any color, prefer `context.colorScheme`:

```dart
Container(color: context.colorScheme.primary)
```

Use `AppText` instead of `Text` to utilize typography.

```dart
AppText.medium(
  text: context.t.login,
  color: context.colorScheme.primary,
),
```

Likewise, use `context.textTheme` for `TextStyle`s.

```dart
RichText(
  text: TextSpan(
    text: context.t.login,
    style: context.textTheme.medium,
  ),
)