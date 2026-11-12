# Authoring SKILL.md

SKILL.md-specific rules. Read when creating/editing a skill. General compact-markdown style still applies on top.

## Goal

A skill buys **predictability** — a consistent process from a stochastic model. Judge every line by whether it changes behavior vs. the default.

## Align with the user first

Skill encodes the user's process, not the agent's assumptions. Before writing, ask until both share the same picture:

- Triggers — when should it fire, when not.
- Steps and order; what "done" looks like.
- Inputs, outputs, tools, sibling skills it routes to.
- Edge cases and hard rules.

Ask targeted questions, one at a time (`ask-first` skill has the loop). Don't fill gaps with guesses — a wrong assumption gets baked into every future run.

## Description field

The description does the invocation work — it decides when the skill fires, so it must make the model invoke the skill rather than answer from the description.

- Pattern: `Use when <triggers>. Handles <scope>.` plus optional `Not for <X> → <sibling>.` No identity sentence — that lives in the body.
- Triggers: user intents, action verbs, keywords, file types. Strongest trigger word first after `Use when`. Specific enough not to hijack unrelated prompts.
- One trigger per branch. Synonyms renaming the same branch are duplication.
- Target 20–35 words. Go over only for a needed `Not for` or routing clause.
- No how-it-works, steps, models/subagents, or answers. That belongs in the body.

## Triggering

- `disable-model-invocation: true` in frontmatter makes the skill manual-only — it cannot auto-trigger.
- On a manual-only skill, strip redundant "never auto-trigger / do not reach for this on your own" prose from the description and body; the flag enforces it mechanically. Keep only what the skill does, its manual triggers, and routing to sibling skills.
- Manual-only description: same pattern, minus auto-trigger phrasing. Don't mention the slash command — it's the only way in.

## Argument hint

- Add `argument-hint: "<what to pass>"` in frontmatter when the skill takes input after the slash command (path, ref, pasted text, ticket key). It shows in the slash menu.
- State the input plainly, with a default or `(optional)` where one exists. Skip skills that take no input.

## Progressive disclosure (the ladder)

- Inline what every branch needs; push behind a pointer (linked file) what only some branches reach.
- Co-location: keep a concept's definition, rules, and caveats under one heading — don't scatter them.

## Compaction caveat

- Rationale/"why" lines in a SKILL.md are content, not filler — keep them. Compact genuine filler (hedging, restated titles, motivational lines) only. Skill instructions perform better when the model understands why; do not strip reasoning.

## Self-check — failure modes

- **Premature completion** — a step ends before it's done. Sharpen the completion criterion; if still fuzzy, split post-completion steps into a later stage.
- **Duplication** — same meaning in two places. Costs tokens and inflates that meaning's apparent importance.
- **Sediment** — outdated lines that pile up because adding feels safe, removing feels risky. Prune deliberately.
- **Sprawl** — too long even when every line is live. Cure with the ladder: pointers + split by branch/sequence.
- **No-op** — a line the model already obeys by default. Cut it.
- **Missing gate** — step that deletes, pushes, overwrites, or writes externally (ticket, PR, message) with no ask-first step before it. Add the ask.
- **Silent failure** — step that can fail (tool missing, command errors, ref not found) with no stated next action. State it.
