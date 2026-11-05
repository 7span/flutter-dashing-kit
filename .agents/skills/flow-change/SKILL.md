---
name: flow-change
description: >
  Modifies an existing feature's behaviour, navigation flow, or user
  interaction without creating a brand new feature from scratch. Covers
  changing screen order, adding/removing steps in a flow, updating BLoC
  logic, swapping data sources, altering UI layout on an existing screen,
  or wiring up a new route between two existing screens. Triggered when
  the user says "change", "update", "modify", "refactor", "move",
  "rename", "add [something] to existing screen", or "change the flow".
---

# Flow Change Skill

You are modifying existing code in a Flutter monorepo codebase.
The goal is to apply the requested change cleanly, without breaking
existing behaviour outside the intended scope.

Execute the five steps below in order.

---

## Step 1 — Understand the Change

### 1a. Restate the Request
In your own words, describe:
- Which screen(s) or feature(s) are affected
- What the flow looks like **today** (current behaviour)
- What it should look like **after the change** (desired behaviour)
- What is explicitly **out of scope** (what must NOT change)

### 1b. Classify the Change
Identify which layers are touched:

| Layer | Examples |
|---|---|
| **UI only** | Label text, button colour, widget layout, spacing |
| **Navigation** | Route order, guard logic, pushing a new route, replacing a route |
| **BLoC logic** | New event, new state field, changed handler, added/removed state transition |
| **Repository** | New API call, changed endpoint, different query parameters |
| **Model** | New field, removed field, changed JSON key |
| **Cross-cutting** | DI change, global auth/token logic, translation keys |

### 1c. Identify Impact Surface
List every file that will change. Consider:
- Does the BLoC state change? → `copyWith` and `props` must be updated.
- Does a new event exist? → Register it in the BLoC constructor.
- Does a new route exist? → Router config + `melos run build-runner`.
- Does UI text change? → `en.i18n.json` + `melos run locale-gen`.
- Do assets change? → `packages/app_ui/assets/` + `melos run asset-gen`.
- Does an interface change? → Every implementing class must be updated.

---

## Step 2 — Read Before You Write

**Read every file you plan to change before editing any of them.**

For each file:
1. Understand its current structure fully.
2. Identify the exact lines that need to change.
3. Check for other callsites that depend on the code you are about to modify.

Use `grep_search` to find all references to a class, method, event name, or route before renaming or removing it.

---

## Step 3 — Apply the Change

### Rules for Modifying Existing Code

**Minimal diff.** Change only what the request specifies. Do not clean up
unrelated formatting, rename unrelated variables, or refactor adjacent code.

**Maintain architectural consistency.** All changes must follow the rules
in `.agents/AGENTS.md` and `.agents/rules/flutter-dart.md`:
- BLoC state changes go through `copyWith`.
- New events are `final class` extending the feature's `sealed class` event base.
- New UI elements use `AppText`, `AppButton`, `VSpace`/`HSpace`, `AppScaffold`.
- New strings go through `context.t.[key]`.

---

## Step 4 — Verify

### 4a. Static Analysis
```bash
flutter analyze
```
Zero errors. Zero warnings.

---

## Step 5 — Report

```
## Flow Change: [Short Description]

### What Changed
**Before:** [description of the old behaviour]
**After:**  [description of the new behaviour]

### Files Changed
- [MODIFIED] path/to/file.dart — [what changed and why]

### Verification Results
flutter analyze: 0 errors, 0 warnings
```
