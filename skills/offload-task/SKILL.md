---
name: offload-task
description: Write one stuck problem into a standalone markdown brief so a fresh session in any coding agent can attack it without inheriting the dead ends. Use when the user says they want to offload a problem, take it to a new chat or another agent, or asks for a prompt/doc explaining a problem they need help with.
argument-hint: "Which problem to offload (optional)"
---

Extract ONE problem from this conversation into a markdown brief saved to `~/Downloads/`.

Not a session summary. `handoff-session` covers the whole session so work continues; this covers one unsolved problem so someone else solves it. Everything unrelated to that problem is excluded, even work done this session.

## Scope

- Arguments given → that is the problem. No arguments → the most recent unresolved problem.
- Unsure which of several → ask before writing.

## Reader

A coding agent with this repo checked out — no prior context, full file access.

- Reference `path/to/file.ts:123`. Do not paste code the reader can open.
- Inline only what cannot be opened: error output, terminal logs, user observations of the live UI, values from screenshots.
- Name the project rules that constrain the answer (`.claude/rules/*.md`, `CLAUDE.md`) by path — do not restate them.

## Attempts are the payload

The reason to offload is that the current thread burned attempts. List every one, one line each: what was tried → what happened. This is the section that stops the new session re-proposing a failed fix, so never compress it away.

Include attempts made in code AND things the user checked by hand.

## Facts, not theories

Report observations. Omit your own diagnoses, hunches, and "likely cause" reasoning — those are what the thread got stuck on, and repeating them anchors the new session onto the same track.

Unknowns belong in Open Questions as questions, not as answers.

Exception: a hypothesis already tested and disproved belongs in Attempts as a fact.

## Structure

```markdown
# [Problem in one line]

## Goal
What should happen, in the flow it belongs to.

## Failing behaviour
What happens instead. Verbatim error output. Exact file:line.

## Reproduce
Command, spec, or steps.

## Attempts
- Tried X → Y happened. Code attempts and manual checks both.

## Evidence
Observations from the live app, logs, screenshots, network/console.

## Open questions
Questions, unanswered.

## Constraints
Rule files that apply. Anything the new session must not do.
```

Drop any heading with nothing real to put under it.

## Output

- Save as `~/Downloads/offload-<TICKET>.md`, else `offload-<topic>.md`. Hyphenated.
- Name exists → append a timestamp. Never overwrite.
- `~/Downloads` missing or unwritable → ask for a destination.
- Redact secrets, credentials, PII.
- Report the saved path. Do not print the document in chat.
