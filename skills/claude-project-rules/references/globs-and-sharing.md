# Glob gotchas, sharing, excluding

## Glob gotchas

- Brace budget: a rule's whole `paths:` list shares 1,000 expanded patterns / 4 MiB. Each group multiplies (`{a,b}/{c,d}/*.{ts,tsx}` = 8). Over budget → the pattern is used **unexpanded**, so its literal braces match nothing. Keep brace groups shallow; prefer extra list entries over nested groups.
- `[` starts a bracket expression. `photos [2024/**` is invalid and matches nothing (other patterns in the rule still work). Escape as `photos \[2024/**`.
- Symlinked checkouts: matching works through a symlinked path to the project dir.

## Sharing and excluding

- **Symlink to share across projects.** `.claude/rules/` resolves symlinked dirs and files; circular links handled.
  ```bash
  ln -s ~/shared-claude-rules .claude/rules/shared
  ln -s ~/company-standards/security.md .claude/rules/security.md
  ```
  A target outside the working dir counts as an external import: nothing loads until external imports are approved for the project, and then only rules **without** `paths:`. Approval is prompted only by an `@path` import in a project memory file, never by a symlink alone — no such import, no prompt, no linked rules. `~/.claude/rules/` avoids all of it.
- **Exclude noisy inherited rules** with `claudeMdExcludes` (glob vs absolute path) in `.claude/settings.local.json`. Arrays merge across settings layers. For a symlinked rule, a pattern matching *either* the `.claude/rules/` path or the link target excludes it.
  ```json
  { "claudeMdExcludes": ["/home/user/monorepo/other-team/.claude/rules/**"] }
  ```
- Project rules are skipped when `project` is excluded from `--setting-sources`, lazy ones included.
- `--add-dir` dirs contribute rules only with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`.
