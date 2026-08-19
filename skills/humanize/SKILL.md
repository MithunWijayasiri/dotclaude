---
name: humanize
description: Remove AI writing patterns from prose. Use when drafting, editing, or reviewing text to eliminate predictable AI tells. For .md docs read by AI agents (skills, rules, specs — where machine-terse is the goal), use compact-markdown instead.
---

# Humanize

Eliminate predictable AI writing patterns from prose.

## Scope

Rewrite phrasing, not meaning. Preserve facts, numbers, file paths, key names,
API names, links, claims, uncertainty, scope, modality, and intentional voice.
If a cleaner sentence changes what the document asserts, leave the sentence
unchanged.

Identify the document type before editing. Prose, marketing copy, technical
docs, policies, changelogs, licenses, and agent instructions need different
levels of compression and different registers.

Do not rewrite code blocks, commands, headings, tables, links, or quoted text
unless explicitly asked. Preserve intentional fragments, repetition, parallel
structure, and rhetorical phrasing when they improve navigation or emphasis.

## Core Rules

1. **Cut filler phrases.** Remove throat-clearing openers, emphasis crutches,
   generic transitions, and empty intensifiers. Keep adverbs that carry a fact,
   such as `locally`, `manually`, `asynchronously`, or `optionally`. See
   [references/phrases.md](references/phrases.md).

2. **Break formulaic structures.** Avoid binary contrasts, negative listings,
   dramatic fragmentation, rhetorical setups, and false agency when they add no
   meaning. See [references/structures.md](references/structures.md).

3. **Prefer active voice.** Use it when it improves clarity. Keep passive voice
   when the actor is unknown, irrelevant, intentionally omitted, or required by
   technical, legal, or privacy wording. Avoid inanimate objects performing
   human actions ("the complaint becomes a fix").

4. **Be specific.** Replace vague declaratives ("The reasons are structural")
   with the specific fact. Keep precise qualifiers such as `every`, `always`,
   and `never` when the claim requires them.

5. **Match the reader and register.** Use direct instructions for user-facing
   guidance. Use the established technical, legal, or product register for
   specialized documents. Do not force conversational "you" into policies,
   API docs, or agent instructions.

6. **Vary rhythm where the format allows it.** Mix sentence lengths and avoid
   repetitive paragraph endings. Keep consistent structure in tables, lists,
   changelogs, and reference material.

7. **Trust readers.** State facts directly. Remove softening, justification, and
   hand-holding unless the context requires an explanation or warning.

8. **Keep the register.** Never trade a term of art, an API name, or legal
   phrasing for a livelier word. "The extension clears history" holds because
   the code calls it `clearHistory`; "wipes" is punchier and wrong. Keep
   "was preferred" over "won" and "manually" over "by hand". This rule
   outranks every style rule in privacy policies, licenses, security notes, API
   docs, and reviewer-facing material.

## Quick Checks

Before delivering prose:

- Any filler, empty intensifier, or generic transition? Cut it.
- Did any edit change a fact, number, path, key name, link, claim, scope, or
  qualifier? Restore the original meaning.
- Did a rewrite alter a term of art, API name, or legal phrase? Put it back.
- Does active voice improve the sentence? Use it. Otherwise keep accurate
  passive voice.
- Is an inanimate thing doing a human action? Name the actor or use a precise
  system verb.
- Any vague declarative ("The implications are significant")? Name the specific
  implication.
- Any "here's what/this/that" throat-clearing? Cut to the point.
- Any "not X, it's Y" contrast that adds no distinction? State Y directly.
- Did the edit damage intentional structure in a list, table, heading, quote,
  changelog, policy, or reference section? Restore it.
- Did the final text preserve the document's register and intended audience?
- Did the final fact check preserve names, numbers, claims, examples, links,
  and code terms?

## Scoring

Use the score as a revision prompt, not a pass/fail gate. Rate 1–10 on each:

| Dimension | Question |
|-----------|----------|
| Directness | Does each sentence reach its point quickly? |
| Rhythm | Does the prose avoid a metronomic pattern? |
| Trust | Does it respect reader intelligence? |
| Authenticity | Does it fit the document's voice? |
| Density | Does each phrase carry useful information? |

## Examples

See [references/examples.md](references/examples.md) for before/after transformations.
