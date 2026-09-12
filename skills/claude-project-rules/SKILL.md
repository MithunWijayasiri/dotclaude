---
name: claude-project-rules
description: Author Claude Code rule files (.claude/rules/*.md). Use when asked to create, add, edit, or review a project or user "rule" — covers frontmatter, lazy-load vs always-on loading, glob scoping, symlinked shared rules, exclusions, and when a rule beats CLAUDE.md or a skill. Invoke before writing any file under .claude/rules/.
---

# Claude Code project rules

Rules = topic-scoped instruction files under `.claude/rules/`. Official memory feature. Get the loading model right or the rule either bloats every session or never fires.

Rules are **context, not enforcement**. To hard-block an action, use a `PreToolUse` hook instead.

## Loading model (the thing that's easy to get wrong)

- File under `.claude/rules/` (project) or `~/.claude/rules/` (user). `.md` discovered recursively; subdirs allowed (`rules/frontend/`).
- **No `paths:` frontmatter → loaded at launch, always-on**, same priority as `.claude/CLAUDE.md`. Costs context every turn.
- **`paths:` frontmatter (YAML list of globs) → lazy-loaded**, injected when Claude reads a matching file. Zero cost until then.
- Precedence: user rules load first, project rules after (project wins).
- After `/compact`: a path-scoped rule reloads only once a matching file is read again. Don't put must-always-hold facts in one.

**Default to `paths:`-scoped.** Omit `paths:` ONLY when the rule genuinely governs all work (rare — that's usually CLAUDE.md's job).

## Frontmatter

- The **only** recognized key is `paths:`. No `name`, `description`, or `alwaysApply` — adding them does nothing.
- Globs: gitignore-style, relative to project root. Brace expansion ok.

```yaml
---
paths:
  - "src/**/*.{ts,tsx}"
  - "tests/**/*.test.ts"
---
```

- Scope to the files the rule actually governs. A rule about the locator engine → `src/locator-engine/**` + the specific files it touches, not `src/**`.
- Want it always-on → emit NO frontmatter at all (not empty `paths:`).

### Glob gotchas

- Brace budget: a rule's whole `paths:` list shares 1,000 expanded patterns / 4 MiB. Each group multiplies (`{a,b}/{c,d}/*.{ts,tsx}` = 8). Over budget → the pattern is used **unexpanded**, so its literal braces match nothing. Keep brace groups shallow; prefer extra list entries over nested groups.
- `[` starts a bracket expression. `photos [2024/**` is invalid and matches nothing (other patterns in the rule still work). Escape as `photos \[2024/**`.
- Symlinked checkouts: matching works through a symlinked path to the project dir (v2.1.198+).

## Sharing and excluding

- **Symlink to share across projects.** `.claude/rules/` resolves symlinked dirs and files; circular links handled.
  ```bash
  ln -s ~/shared-claude-rules .claude/rules/shared
  ln -s ~/company-standards/security.md .claude/rules/security.md
  ```
  A target outside the working dir counts as an external import: nothing loads until external imports are approved for the project, and then only rules **without** `paths:`. Approval is prompted only by an `@path` import in a project memory file, never by a symlink alone — no such import, no prompt, no linked rules. `~/.claude/rules/` avoids all of it.
- **Exclude noisy inherited rules** with `claudeMdExcludes` (glob vs absolute path) in `.claude/settings.local.json`. Arrays merge across settings layers. For a symlinked rule, a pattern matching *either* the `.claude/rules/` path or the link target excludes it (v2.1.239+).
  ```json
  { "claudeMdExcludes": ["/home/user/monorepo/other-team/.claude/rules/**"] }
  ```
- Project rules are skipped when `project` is excluded from `--setting-sources` (lazy ones too, v2.1.211+).
- `--add-dir` dirs contribute rules only with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`.

## Never `@import` a rule into CLAUDE.md

Forces it always-on, defeating lazy-load. Reference it in prose (`detail in .claude/rules/x.md`), don't `@import`.

## Rule vs CLAUDE.md vs skill vs auto memory

- **CLAUDE.md** — always-relevant core: commands, architecture map, project-wide conventions. Always loaded. `./CLAUDE.md` or `.claude/CLAUDE.md`; ancestors load too.
- **Rule** — instructions that only matter when touching a file area. Lazy-load via `paths:`.
- **Skill** — a task-specific procedure invoked on demand (only its description sits in context). Reach for a skill when it's a *how-to-do-X* workflow, not a *constraint-on-area-Y*.
- **Auto memory** (`~/.claude/projects/<project>/memory/`) — Claude-written, machine-local, not source-controlled. Never hand-author a rule's content there, and don't put team-shared standards in it.

When CLAUDE.md approaches ~200 lines, split area-specific detail out into path-scoped rules.

## One fact, one place — no overlap, no conflict

A fact stated in two places drifts: one copy gets updated, the other lies. Before writing a rule, check what already exists.

- **Don't duplicate.** If CLAUDE.md, another rule, or the code already states it, reference it (`see .claude/rules/x.md`), don't restate it.
- **Don't overlap scopes silently.** Two rules whose `paths:` match the same files both load together. Fine only if they cover *different* topics. Same topic → merge into one file.
- **Don't contradict.** Conflicting instructions get picked arbitrarily. If reality changed, update the existing statement in place.
- When a fact spans areas, put it in the single most-specific home and cross-link with a pointer, not a copy.
- Editing a rule → grep the other rules + every loaded instruction file (`./CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md`, ancestors, nested ones in subdirs, `~/.claude/CLAUDE.md`) for the same term first.
- Edit only the requested rule and files this project owns. A stale or conflicting copy in an ancestor or in `~/.claude/` → report it and ask before touching it.

## Content style

- Lead with the rule, then the why only if non-obvious, then example. Telegraphic, present tense, one fact per line.
- Encode invariants and the failure they prevent ("violating this is how the PR shipped bug X") — concrete beats abstract.
- Tie heuristics to their source of truth. A rule that restates a priority/order list drifts from the code; point at the authoritative table and state the invariant ("scores live in SCORE, lower wins").
- One topic per file, kebab-case filename.

## Verify it loaded

- `/context` → **Memory files** lists what actually loaded this session.
- `/memory` lists locations and opens files for editing.
- `InstructionsLoaded` hook logs which instruction files loaded, when, and why — use it to debug a `paths:` rule that never fires.

## Checklist

- [ ] `paths:` present and scoped to the governed files? (omit entirely only if truly always-on)
- [ ] Globs valid — brace groups shallow, no unescaped `[`.
- [ ] No `@import` of this rule anywhere in CLAUDE.md.
- [ ] Content is invariants/constraints, not a duplicate of code that will drift.
- [ ] One topic, focused. Not a second CLAUDE.md.
- [ ] Doesn't restate what CLAUDE.md or the code already says.
- [ ] Needs hard enforcement, not guidance? → hook, not a rule.
