---
name: ask-first
description: Ask the user clarifying questions before acting, instead of filling gaps with guesses. Use when starting to implement a feature, fix a bug, write or change tests, refactor, or plan any change where intent, scope, expected behavior, values, or done-criteria aren't fully stated. Also use mid-task when a new unknown surfaces. Skip for fully-specified asks, pure questions, and read-only lookups.
argument-hint: "[bug|feature|improvement|refactor|test|docs] - what needs doing"
---

# Ask First

Goal: shared understanding before code. User knows what I'll build; I know what they want. Guessed gap → wrong work baked in, costs a rework cycle.

## Input

- Shape: `<type> - <what needs doing>`, e.g. `bug - after I turn off save history, I cannot turn it on`. Often short or lazy — expected. Fill gaps by reading code, then asking.
- Types: bug, feature, improvement, refactor, test, docs. Type picks the gap checklist below.
- No type → infer from wording + code. Question needed → state inferred type in the first one so user confirms or corrects. Fully specified → proceed, no type confirmation.
- Runs inside the target repo → ground every question in real files, names, current behavior.

## Loop

1. **Read first.** Explore relevant code, config, tickets, logs. Answerable from the code → read, don't ask. Verify claims against code; contradiction → surface it as a question.
2. **Find gaps.** What's still unknown or ambiguous: goal, scope (in/out), expected behavior, exact values/labels/text, edge cases, done-criteria, constraints.
3. **Ask one at a time.** Wait for the answer before the next. Order by dependency — answers that change later questions go first.
4. **Always recommend.** Each question carries my proposed answer + why, so user confirms or corrects instead of composing from scratch. Never a blank question.
5. **Repeat** until no gap would change what I build.

## Question shape

- Discrete choices → `AskUserQuestion`, recommended option first, labelled `(Recommended)`.
- Open-ended (a value, a label, what's on screen) → plain text question.
- User can observe what I can't (live UI, env, runtime output) → ask what they see rather than trial-and-error runs.
- Targeted and concrete: real paths, names, values. Not "any other requirements?".

## Gaps by type

Check on top of the generic gaps. Ask only what code/logs don't answer.

- **Bug** — expected vs actual, repro steps, env, when it started, what changed. Don't propose a root cause as fact — ask to confirm.
- **Feature** — who uses it and when, entry point (UI, CLI, config), behavior incl. error/edge cases, scope out, existing pattern to follow, done-criteria.
- **Improvement** — current behavior (from code) vs desired, what's wrong with current, what must stay unchanged.
- **Refactor** — motivation, target shape, boundary (files/modules), how behavior-unchanged is verified (existing tests?).
- **Test** — what's under test, level (unit/integration/e2e), cases incl. negative, test data/fixtures. Flaky → failure evidence.
- **Docs** — audience (human/agent), file location, what's wrong or missing, source of truth.

## Playback

Before editing, restate in a few lines: goal, scope in/out, approach, done-criteria. Get a yes. Correction → update and replay.

## Mid-task

New unknown surfaces during implementation → stop and ask. Don't pick a default silently.
