---
name: writing-rules
description: Author Claude Code rule files (.claude/rules/*.md). Use when asked to create, add, edit, or review a project or user "rule" — covers paths: frontmatter, lazy-load vs always-on loading, glob scoping, and when a rule beats CLAUDE.md or a skill. Invoke before writing any file under .claude/rules/.
---

# Writing Claude Code rules

Rules = topic-scoped instruction files. Official memory feature. Get the loading model right or the rule either bloats every session or never fires.

## Loading model (the thing that's easy to get wrong)

- File under `.claude/rules/` (project) or `~/.claude/rules/` (user).
- **No `paths:` frontmatter → loaded at session start, always-on**, same priority as CLAUDE.md. Costs context every turn.
- **`paths:` frontmatter (YAML list of globs) → lazy-loaded**, injected only when a file matching a glob is read/edited. Zero cost until then.
- Precedence: user rules load first, project rules after (project wins).

**Default to `paths:`-scoped.** Omit `paths:` ONLY when the rule genuinely governs all work (rare — that's usually CLAUDE.md's job).

## Frontmatter

- The **only** recognized key is `paths:`. No `name`, `description`, or `alwaysApply` — adding them does nothing.
- Globs: gitignore-style, relative to project root. Brace expansion ok.

```yaml
---
paths:
  - "src/**/*.ts"
  - "src/**/*.tsx"
  - "tests/**/*.ts"
---
```

- Scope to the files the rule actually governs. A rule about the locator engine → `src/locator-engine/**` + the specific files it touches, not `src/**`.
- Want it always-on → emit NO frontmatter at all (not empty `paths:`).

## Never `@import` a rule into CLAUDE.md

Forces it always-on, defeating lazy-load. Reference it in prose if needed (`detail in .claude/rules/x.md`), don't `@import`.

## Rule vs CLAUDE.md vs skill

- **CLAUDE.md** — always-relevant core: commands, architecture map, project-wide conventions. Always loaded. Project copy lives at `./CLAUDE.md` or `.claude/CLAUDE.md`; ancestor directories load too.
- **Rule** — instructions that only matter when touching a file area. Lazy-load via `paths:`.
- **Skill** — a task-specific procedure invoked on demand (only its description sits in context). Reach for a skill when it's a *how-to-do-X* workflow, not a *constraint-on-area-Y*.

When CLAUDE.md approaches ~200 lines, split area-specific detail out into path-scoped rules.

## One fact, one place — no overlap, no conflict

A fact stated in two places drifts: one copy gets updated, the other lies. Before writing a rule, check what already exists.

- **Don't duplicate.** If CLAUDE.md, another rule, or the code already states it, don't restate it — reference it (`see .claude/rules/x.md`) or leave it where it is.
- **Don't overlap scopes silently.** Two rules whose `paths:` match the same files both load together. That's fine only if they cover *different* topics. Same topic across two files → merge into one.
- **Don't contradict.** A new rule must not assert the opposite of an existing rule or CLAUDE.md. If reality changed, update the existing statement in place — don't add a competing one.
- When a fact spans areas, put it in the single most-specific home and cross-link with a pointer, not a copy.
- Editing a rule → grep the other rules + every loaded `CLAUDE.md` (`./CLAUDE.md`, `.claude/CLAUDE.md`, ancestors, `~/.claude/CLAUDE.md`) for the same term first; fix every stale copy in the same edit, or collapse them to one.

## Content style

- Lead with the rule, then the why only if non-obvious, then example. Telegraphic, present tense, one fact per line.
- Encode invariants and the failure they prevent ("violating this is how the PR shipped bug X") — concrete beats abstract.
- Tie heuristics to their source of truth. A rule that restates a priority/order list will drift from the code; instead point at the authoritative table and state the invariant ("scores live in SCORE, lower wins").
- One topic per file, kebab-case filename. Subdirs allowed (recursive discovery): `rules/frontend/`, `rules/backend/`.

## Checklist

- [ ] `paths:` present and scoped to the governed files? (omit entirely only if truly always-on)
- [ ] No `@import` of this rule anywhere in CLAUDE.md.
- [ ] Content is invariants/constraints, not a duplicate of code that will drift.
- [ ] One topic, focused. Not a second CLAUDE.md.
- [ ] Doesn't restate what CLAUDE.md or the code already says.
