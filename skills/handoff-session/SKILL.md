---
name: handoff-session
description: Use when the user wants to hand off the session, continue in a new one, or pass the current work to another agent. Handles a compact handoff document saved to ~/Downloads. Not for one stuck problem → `offload-task`.
argument-hint: "Next session's focus (optional)"
---

Summarise this conversation for a fresh agent to continue.

- Save to `~/Downloads/`, descriptive hyphenated filename prefixed by the project name in square brackets: `[Project]-handoff-TICKETID.md` or `[Project]-handoff-topic.md`.
- Project = repo name from the `origin` remote URL, else the folder name; cut to 20 characters.
- Name already exists → append a timestamp; never overwrite.
- Folder missing or unwritable → ask for another destination.
- Report the saved path.

Link to existing artifacts (PRDs, plans, ADRs, issues, commits, diffs) instead of copying their content.

Keep the doc compact by excluding:
- Exploratory questions ("how does X work?", "explain this code")
- Cancelled or abandoned work — branches, experiments, approaches that were started but dropped
- Dead-end debugging — investigation paths that led nowhere
- Failed attempts — exclude them unless they explain the current state, reveal a constraint, or prevent repeating the same path
- Tool/command usage details — focus on results, not mechanics
- Fully resolved issues — exclude them unless the resolution affects future work
- Off-topic tangents — side discussions unrelated to the main work
- Redundant iterations — multiple rounds of the same fix/tweak

In Current State: mark assumptions and unverified claims explicitly; record the latest validation status, including failures and checks not run.

Use this structure:

```markdown
# Handoff: [Topic]

## Context
[1-2 sentences on what we were working on]

## Current State
[What's working, what's broken, what's in progress]

## Blockers
[Anything stopping progress]

## Decisions Made
[Key choices — architectural, trade-offs accepted]

## Next Steps
[Prioritized list of concrete actions, including dependencies or conditions when a step cannot start immediately]

## Open Questions
[Unresolved decisions for the next agent]

## Key Files
[Relevant file paths]
```

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
