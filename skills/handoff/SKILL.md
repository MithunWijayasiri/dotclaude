---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
---

Summarise this conversation for a fresh agent to continue. Save to ~/Downloads/ with a descriptive filename, like handoff-TICKETID.md or handoff-topic.md. If the folder is missing or unwritable, ask for another destination. Report the saved path.

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

Include:
- Current state — what's working, what's broken, what's in progress
- Blockers — anything stopping progress
- Decisions made — architectural choices, trade-offs accepted
- Next steps — what needs to happen next
- Open questions — unresolved decisions the next agent should address
- Key file paths — locations of relevant code/configs

Use this structure:

# Handoff: [Topic]

## Context
[1-2 sentences on what we were working on]

## Current State
[What's working, what's broken, what's in progress]

- Mark assumptions and unverified claims explicitly.
- Record the latest validation status, including failures and checks not run.

## Blockers
[Anything stopping progress]

## Decisions Made
[Key choices and trade-offs]

## Next Steps
[Prioritized list of concrete actions, including dependencies or conditions when a step cannot start immediately]

## Open Questions
[Unresolved decisions for the next agent]

## Key Files
[Relevant paths]

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
