---
trigger: always_on
description: Convert Figma UI into app_ui based Flutter UI
---

# Figma to Flutter UI Rules

When generating UI from a Figma design, follow the **AgentsAt design system**.

The UI must use components from the **app_ui package**.

---

# Component Mapping

Prefer these components instead of raw Flutter widgets.

Text

Use:
AppText.small
AppText.medium
AppText.large

Avoid:
Text

---

Buttons

Use:
AppButton
AppButton.secondary
AppButton.outline
AppButton.text
AppButton.destructive

Avoid:
ElevatedButton
TextButton
OutlinedButton

---

Text Fields

Use:
AppTextField

Avoid:
TextField
TextFormField

---

Spacing

Use:
VSpace.*
HSpace.*

Avoid:
SizedBox(height:)
SizedBox(width:)

---

Cards / Containers

If a reusable container exists in app_ui, use it.

Avoid creating custom containers unless necessary.

---

# Layout Rules

Follow standard Flutter layout patterns:

Column  
Row  
Expanded  
Flexible  
Padding  

Do not introduce unnecessary nesting.

Keep layout readable.

---

# Asset Usage

Assets must be referenced through flutter_gen:

Assets.icons.*
Assets.images.*

Never use raw asset paths.

---

# Localization

All user-facing text must use:

context.t.*

Never hardcode text.

Example:

AppText.large(
  text: context.t.login.title,
)

---

# Component Reuse Strategy

When implementing a UI element:

1. Check if a similar component exists in **app_ui**
2. If it exists → reuse it
3. If it does not exist → create a reusable component inside **app_ui**

Example:

AppTagChip  
AppFilterChip  
AppSectionHeader

---

# Screen Implementation

Generate **one main screen widget**.

Example:

LoginScreen

Sub-widgets can be extracted if UI becomes complex.

---

# Mobile Scope

Layouts should target **mobile only**.

Do not generate responsive layouts for:

tablet  
web  
desktop

---

# Code Quality

Generated UI must:

- follow existing project architecture
- reuse app_ui components
- avoid duplicate widgets
- remain readable