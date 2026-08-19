---
name: compact-markdown
description: Writing style for markdown files. Strips filler, writes telegraphic and content-only — docs are for AI agents, not prose. Trigger whenever creating or editing ANY .md file (skills, rules, CLAUDE.md, feature specs, design notes, guides, etc.), for the new/edited content you produce. Do NOT trigger for README.md, and do NOT trigger for non-markdown files.
---

# Compact Markdown

Markdown docs here exist for AI agents, not human reading pleasure. Write content only. No filler, no scaffolding.

## Scope

- Apply to any `.md` being created or edited — **except `README.md`** (skip this skill entirely for README.md).
- Apply only to **content you write or edit**. Do not rewrite existing surrounding prose you weren't asked to touch.
- Human-facing prose in `.md` (a doc written for people, not agents) → use `humanize` instead.
- Compress wording; keep markdown valid and navigable.
- Authoring a `SKILL.md`? Read `references/skill-authoring.md` for skill-specific rules (frontmatter, triggering, what not to compact).

## Core rule

Telegraphic. Drop articles, filler verbs, and pronouns where meaning survives.

- "You should run the command before testing" → "Run command before testing."
- "This function is responsible for parsing the config" → "Parses config."
- "In order to do X, you need to do Y" → "X requires Y."
- Imperative fragments are fine: "Fail → check trace." "No output → test passed."

Judgment overrides compression. **Never compress if it loses important info.** When in doubt, keep the words.

## Strip

- Emojis, Badges.
- Filler headers — empty `## Overview` / `## Introduction` whose body just restates the title. Collapse into actual content or open straight with facts.
- Congratulatory / motivational lines — "Great!", "Congrats!", "That's it!", "Happy coding!", "Now you're ready to...".
- Hedging and throat-clearing — "It's worth noting that", "Basically", "Simply", "Of course", "As you can see".
- Restating the prompt or the section title in the first sentence.
- Summary / Conclusion sections that only restate the doc. Keep summaries that
  capture decisions, risks, or takeaways.
- Table of contents for docs short enough to scan.
- Bold on every other phrase — everything emphasized = nothing emphasized.
- Horizontal rules (`---`) between every section.

## Keep

- Code blocks, inline code, CLI commands — verbatim, never paraphrased.
- Examples and sample snippets — they carry the most signal per token. Drop only a duplicate/low-value example, never a useful one.
- Tables — keep structured, do not flatten into prose.
- Heading hierarchy — keep for navigation. Just cut filler headers.
- Any concrete detail: paths, flags, names, values, edge cases, gotchas.

## Shape

- Prefer lists and tables over paragraphs.
- One fact per line where it reads cleanly.
- `→` for cause/result, conditions, flows.
- Lead with the rule, then the why (only if non-obvious), then example.

## Self-check

Before finishing:

- Remove anything that adds no information.
- Restore any detail whose removal changes meaning, scope, or conditions.
- Check that Markdown structure remains valid.

## Example

Verbose:

````markdown
## Introduction

This section will walk you through the process of setting up the
authentication flow. It's worth noting that you'll need to make sure
the environment variables are configured correctly before you begin.

Great! Once that's done, you can run the setup command. 🎉
````

Compact:

````markdown
## Auth setup

Configure env vars first, then run:

```bash
npm run setup:auth
```
````
