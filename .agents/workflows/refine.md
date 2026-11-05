# /refine — Prompt Sharpening Workflow

**Usage:** `/refine <raw prompt>`

**Purpose:** Turn a raw feature idea into a precise, edge-case-complete spec before a single line of code is written. This workflow **does not touch the codebase** and **does not produce code**.

---

## What This Workflow Does

1.  Loads the `prompt-refiner` skill.
2.  Runs its 3-step loop (Restate → Edge Cases → Output) against the raw prompt you provide.
3.  Outputs a `FINAL PROMPT` block you can feed directly into `/new-feature`.

---

## Instructions

When the user types `/refine <raw prompt>`:

1.  **Do not open AGENTS.md.** Do not read any source files.
2.  **Do not write any code or modify any files.**
3.  Load and follow `.agent/skills/prompt-refiner/SKILL.md` exactly.
4.  Execute Step 1 (Restate) and Step 2 (Edge Cases) and present them to the user in a single response.
5.  Wait for the user to answer the questions (or say "use your assumptions").
6.  Execute Step 3 (Output) and present the `FINAL PROMPT` block.
7.  Stop. Your work is done. Tell the user:
    
    > "Feed this FINAL PROMPT into `/new-feature` to begin implementation."
    

---

## What This Workflow Does NOT Do

-   It does not implement anything.
-   It does not create files.
-   It does not plan architecture.
-   It does not read existing code.
-   It does not check for conflicts with existing features.

All of that happens in `/new-feature`.