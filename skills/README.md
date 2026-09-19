# Skills

Reusable task workflows. A skill loads on demand when the task matches its description — see the roadmap in the [root README](../README.md).

- **compact-markdown** — telegraphic markdown for AI-facing docs. Strips filler, keeps code, examples, and concrete detail. Compact and still human-readable.
- **humanize** — remove AI writing patterns from prose. Use for human-facing writing where readability and voice matter.
- **handoff-session** — hand the whole session over: state, decisions, blockers, next steps. Detail that no longer matters is dropped.
- **offload-task** — write one stuck problem into a standalone brief a fresh session can attack: goal, failing behaviour, repro, and every attempt with what it produced — code and manual checks alike.
- **claude-project-rules** — author `.claude/rules/*.md`: `paths:` scoping, lazy-load vs always-on, symlinked shared rules, exclusions, and when a rule beats CLAUDE.md or a skill.
- **html-landing-page** — design a distinctive static landing page. Plan palette, type, and one signature element before any HTML; bans the AI-default look.
- **git-merge** — merge a branch into yours without losing local unstaged work. Diagnose each conflict, then run the repo's own checks to catch the ones git merged cleanly but wrongly.
- **pr-review** — review a PR, branch, commit, or uncommitted work for defects. Bugs first, structure second, style last. Resolves the target explicitly and stops on a bad ref or an empty diff. Findings are grouped Blocker / Should fix / Nit, each with `file:line`, the input that breaks it, and a fix. Manual: invoke it with `/pr-review`.
- **zoom-out** — map an unfamiliar code area before touching it. Purpose, flow, callers, boundaries, risks, and the questions the codebase does not answer. Nothing is edited and no mutating command runs until the map is done. Manual: invoke it with `/zoom-out`.
