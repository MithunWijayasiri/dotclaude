# Skills

Reusable task workflows. A skill loads on demand when the task matches its description — see the roadmap in the [root README](../README.md).

- **compact-markdown** — telegraphic markdown for AI-facing docs. Strips filler, keeps code, examples, and concrete detail. Compact and still human-readable.
- **ask-first** — ask clarifying questions before acting instead of guessing. Reads the code first, asks one question at a time with a recommended answer, and restates the plan before editing.
- **handoff-session** — hand the whole session over: state, decisions, blockers, next steps. Detail that no longer matters is dropped.
- **offload-task** — write one stuck problem into a standalone brief a fresh session can attack: goal, failing behaviour, repro, and every attempt with what it produced — code and manual checks alike.
- **claude-project-rules** — author `.claude/rules/*.md`: `paths:` scoping, lazy-load vs always-on, symlinked shared rules, exclusions, and when a rule beats CLAUDE.md or a skill.
- **html-landing-page** — design a distinctive static landing page on top of `frontend-design`. Plan palette, type, and one signature element before any HTML; bans the AI-default look. Manual: invoke it with `/html-landing-page`.
- **git-merge** — merge a branch into yours without losing local unstaged work. Diagnose each conflict, then run the repo's own checks to catch the ones git merged cleanly but wrongly.
- **zoom-out** — map an unfamiliar code area before touching it. Purpose, flow, callers, boundaries, risks, and the questions the codebase does not answer. Nothing is edited and no mutating command runs until the map is done. Manual: invoke it with `/zoom-out`.

## Deprecated

`deprecated/` holds retired skills, kept for reference. Not installed by the release zip.

- `humanize` — remove AI writing patterns from prose. Replaced by [`unslop`](https://github.com/cursor/plugins/blob/main/pstack/skills/unslop/SKILL.md) by poteto: simpler, better, and actively maintained.
- `pr-review` — review a PR, branch, or diff for defects. Replaced by Claude Code's built-in code review: the skill's diff handling used too many tokens and the built-in handles diffs better.
