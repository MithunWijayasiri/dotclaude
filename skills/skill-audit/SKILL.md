---
name: skill-audit
description: Use when reviewing, auditing, or tightening an existing Claude Code skill via `/skill-audit <name | path>...`. Handles SKILL.md, references, and description fixes. Not for writing new skills → `anthropic-skills:skill-creator`.
disable-model-invocation: true
---

# Skill Audit

Report-first. Edit only approved findings.

## Setup

1. Load `compact-markdown`; read its `skill-authoring.md` reference — that is the rubric. Don't restate it in the report or here.
2. Resolve targets:
   - Path to a folder → use it. Path to `SKILL.md` → its parent folder.
   - Name → `<repo>/.claude/skills/<name>/`, then `~/.claude/skills/<name>/`. Both exist → ask which.
   - No args → list skills in both locations, ask which.

## Read

Per target:

- `SKILL.md` and every file under the skill folder (`references/`, scripts).
- What it delegates to or cites: subagent defs (`.claude/agents/`, `~/.claude/agents/`), sibling skills it routes to, rules and CLAUDE.md files it references.
- Every other skill's name + description: both skill locations plus plugin skills in the session's skill listing. Feeds the collision check.

## Checks

Rubric from `skill-authoring.md`: description shape, triggering, ladder, failure modes (premature completion, duplication, sediment, sprawl, no-op). Rationale lines are content — don't flag as filler.

Audit-only additions:

- **Stale refs** — every cited path, file, agent, skill, command, script, and folder exists. Verify with Glob/Grep, never from memory. Missing → finding; unclear replacement → ask, don't guess.
- **Frontmatter conflict** — `disable-model-invocation: true` alongside auto-trigger prose ("when the user asks…", "do NOT trigger for…").
- **Instruction conflict** — contradicts global/project CLAUDE.md or a rule (e.g. routes to a skill/agent CLAUDE.md doesn't sanction, auto-runs checks CLAUDE.md forbids).
- **Cross-file duplication** — restates its subagent's contract, CLAUDE.md, or a rule → pointer or cut.
- **Collision** — triggers overlap another skill or a built-in slash command, with no `Not for → <sibling>` clause on either side. Manual-only → name collision only.
- **Approval gate** — step that deletes, pushes, writes externally (Jira, PR, message), or overwrites, with no ask-first step before it.
- **Scope fit** — body does more than the description promises, or `allowed-tools` doesn't match the tools the steps use.
- **Failure path** — step that can fail (tool missing, command errors, ref not found) with no stated next action. Silent continue = finding.
- **Description** — see below.

### Description

Decides when the skill fires, so it must make the model invoke the skill rather than answer from the description.

- Pattern: `Use when <triggers>. Handles <scope>.` plus optional `Not for <X> → <sibling>.`
- Triggers: user intents, action verbs, keywords, file types. Specific enough not to hijack unrelated prompts.
- Target 20–35 words. Go over only for a needed `Not for` or routing clause.
- No how-it-works, steps, models/subagents, or answers. That belongs in the body.
- Manual-only (`disable-model-invocation: true`): same pattern, with the slash invocation replacing auto-trigger phrasing.
- Trigger test (auto-invocable only) — draft 3 should-fire prompts (names the skill; describes the task without naming it; task buried in a realistic request) and 1–2 near-miss should-not-fire prompts, ideally a sibling's territory. Judge current and proposed description against them; any misfire → finding. Show the prompts in the report.

## Report

Per skill:

| # | Category | Finding | Location | Fix |
|---|---|---|---|---|

Categories: Outdated, Conflict, Duplication, Collision, Gate, Scope, Failure path, No-op, Sprawl, Description. Include the proposed description verbatim.

`Not verified` list after the table: anything not confirmed (unreadable file, unresolved ref, sibling not readable). Never fold an unchecked item into a pass.

User approves by number or "all".

## Apply

- Edit approved findings only, compact-markdown style. Code blocks, examples, and prompts sent to subagents stay verbatim unless a finding targets them.
- Prefer targeted edits. Full-file rewrite only if the approved report said so.
- Sibling files (agents, rules, CLAUDE.md) untouched unless an approved finding names them.
- Finish with per-skill applied/skipped list and line count before → after.
