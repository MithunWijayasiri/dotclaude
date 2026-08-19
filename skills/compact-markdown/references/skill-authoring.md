# Authoring SKILL.md

SKILL.md-specific rules. Read when creating/editing a skill. General compact-markdown style still applies on top.

## Goal

A skill buys **predictability** — a consistent process from a stochastic model. Judge every line by whether it changes behavior vs. the default.

## Description field

The description does the invocation work — it decides when the skill fires.

- Front-load the strongest trigger word.
- One trigger per branch. Synonyms renaming the same branch are duplication.
- Cut identity already in the body. Keep it to triggers + any "when another skill needs…" reach clause.

## Triggering

- `disable-model-invocation: true` in frontmatter makes the skill manual-only — it cannot auto-trigger.
- On a manual-only skill, strip redundant "never auto-trigger / do not reach for this on your own" prose from the description and body; the flag enforces it mechanically. Keep only what the skill does, its manual triggers, and routing to sibling skills.

## Progressive disclosure (the ladder)

- Inline what every branch needs; push behind a pointer (linked file) what only some branches reach.
- Co-location: keep a concept's definition, rules, and caveats under one heading — don't scatter them.

## Compaction caveat

- Rationale/"why" lines in a SKILL.md are content, not filler — keep them. Compact genuine filler (hedging, restated titles, motivational lines) only. Skill instructions perform better when the model understands why; do not strip reasoning.

## Self-check — failure modes

- **Premature completion** — a step ends before it's done. Sharpen the completion criterion; if still fuzzy, split post-completion steps into a later stage.
- **Duplication** — same meaning in two places. Costs tokens and inflates that meaning's apparent importance.
- **Sediment** — stale lines that pile up because adding feels safe, removing feels risky. Prune deliberately.
- **Sprawl** — too long even when every line is live. Cure with the ladder: pointers + split by branch/sequence.
- **No-op** — a line the model already obeys by default. Test: does it change behavior vs. default? If not, cut it.
