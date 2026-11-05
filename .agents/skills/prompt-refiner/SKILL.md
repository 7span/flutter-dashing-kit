---
name: prompt-refiner
description: >
  Turns a raw, vague feature idea into a precise, edge-case-complete
  implementation spec. Triggered when the user asks to "refine", "spec out",
  or "think through" a feature BEFORE any implementation begins.
  This skill DOES NOT touch the codebase and DOES NOT write code.
  Its only output is a FINAL PROMPT block ready to feed into /new-feature.
---

# Prompt Refiner Skill

You are sharpening a raw idea into a precise implementation prompt.
**Do not touch any code or files. Do not open any source file. Do not plan
implementation steps.** Your only job is to ask the right questions and then
produce one clean FINAL PROMPT block.

Execute the three steps below in order. Do not skip any step.

---

## Step 1 — Restate

Restate what the user is asking for in your own words. Cover:
- The screen or feature being built
- The data involved (what entities, where they come from)
- What the user of the app should be able to do
- What the feature does NOT do (out of scope)

Then explicitly call out anything in the original prompt that is **vague or
ambiguous** and needs clarification. Be specific — name the exact gap.

Example gaps to look for:
- "Is this a new screen or a widget added to an existing screen?"
- "Where does the data come from — an existing endpoint, a new one, local Hive storage?"
- "Is the list paginated or fully loaded at once?"
- "Does this require authentication to access?"

---

## Step 2 — Edge Cases

Go through the categories below. For each category, decide:
- **Applies + answer is obvious default** → state the default and move on, no question needed.
- **Applies + behavior is genuinely unclear** → ask one short, specific question.
- **Does not apply to this feature** → skip it silently.

Ask **no more than 5–7 questions total**, grouped logically.

### Edge Case Categories

**Loading state**
How should the screen behave while data is being fetched? (Default: show
`AppCircularProgressIndicator` centred in the body — state this and skip
unless something unusual is needed.)

**Empty state**
What should the user see if the server returns an empty list or no data?
(Default: show `EmptyWidget` from `app_ui` — state this and skip unless
custom copy/illustration is needed.)

**Error state**
What happens on a network failure or a non-2xx response?
(Default: show an inline error message with a retry button — ask if a
specific snackbar/dialog is preferred.)

**Auth state**
- Is this screen behind the `AuthGuard`?
- What happens if the session expires mid-action (token refresh vs. log out)?

**Input validation**
If the feature involves a form: what fields are required? What are the rules
(min length, format, etc.)? Are errors shown inline or on submit?

**Concurrency / timing**
- Can the user trigger the same action twice rapidly (double-tap submit)?
  (Default: `droppable()` transformer on the event — state this.)
- Are there retry semantics on failure?

**Data limits / pagination**
- Is the list paginated? What is the page size?
- What happens when the user reaches the end of the list?
  (Default: `hasReachedMax = true`, spinner disappears — state this.)

**Platform differences**
Are there any behaviours that differ between iOS and Android?
(Permissions flows, share sheets, in-app review, etc.)

**Offline / connectivity**
What should happen if the user loses connectivity mid-action?
(Default: show the generic `NoInternetWidget` — state this and skip unless
something different is needed.)

**Domain-specific edge cases**
What business rules or edge cases are implied by this particular feature that
don't fit the categories above?

---

## Step 3 — Output

Once the user answers your questions (or says "use your assumptions"):

1. Resolve every open question using the user's answers or your stated defaults.
2. Rewrite the original request into a single, self-contained implementation
   prompt. It must include:
   - Core feature description (screen name, data source, user actions)
   - Every edge case and how it is handled, written as explicit requirements
   - All settled assumptions, labelled as such
   - No open questions remaining

Output it inside a fenced code block labelled `FINAL PROMPT`:

```FINAL PROMPT
[your final implementation prompt here]
```

This FINAL PROMPT is the only artifact of this skill. The user will copy it
into `/new-feature` to begin implementation.
