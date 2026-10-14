# Skills

Reusable task workflows. A skill loads on demand when the task matches its description. Install steps are in the [root README](../README.md).

- **compact-markdown** — telegraphic markdown for AI-facing docs. Strips filler, keeps code, examples, and concrete detail. The result stays readable for people.
- **ask-first** — ask clarifying questions before acting instead of guessing. Reads the code first, asks one question at a time with a recommended answer, and restates the plan before editing.
- **handoff-session** — hand the whole session over: state, decisions, blockers, next steps. Drops detail that no longer matters.
- **offload-task** — write one stuck problem into a standalone brief for a fresh session: goal, failing behaviour, repro, and every attempt with its result, whether a code change or a manual check.
- **claude-project-rules** — author `.claude/rules/*.md`. Covers `paths:` scoping, lazy-load against always-on, symlinked shared rules, exclusions, and when to use a rule instead of CLAUDE.md or a skill.
- **html-landing-page** — design a distinctive static landing page with the `frontend-design` skill. Plan palette, type, and one signature element before any HTML, and never ship the AI-default look. Manual: run it with `/html-landing-page`.
- **git-merge** — merge a branch into yours without losing local unstaged work. A recon script maps the conflicts first. Claude then resolves each one and runs the repo's own checks to catch changes git merged without a conflict but wrongly.
- **git-worktree** — create, switch to, or remove a git worktree with `node_modules` junctioned and `.env` copied, so it runs without a reinstall. Reports a lockfile mismatch instead of linking anyway. Windows and PowerShell only.
- **empty-commit** — push an empty commit to re-run CI on the current branch when a pipeline failed on something unrelated. Refuses to run with staged files, on the default branch, or without an upstream. Manual: run it with `/empty-commit`.
- **zoom-out** — map an unfamiliar code area before touching it: purpose, flow, callers, boundaries, risks, and the questions the codebase does not answer. Claude edits nothing and runs no mutating command until the map is done. Manual: run it with `/zoom-out`.
- **skill-audit** — audit an existing skill and report findings before editing: outdated references, conflicts with CLAUDE.md or rules, trigger collisions, missing approval gates, and a new description tested against sample prompts. Edits only what you approve. Manual: run it with `/skill-audit`.
- **readme-craft** — scaffold or restyle a README: centered icon header, badges from one source (shieldcn.dev or shields.io) without vanity or duplicate badges, and GitHub markdown patterns such as admonitions, collapsibles, diagrams, and tables.
- **visualize-it** — explain a concept, feature, problem, or piece of code as a visual page. Picks diagrams, charts, tables, and interactive or animated sections to fit the topic. The page is a Claude artifact when the Artifact tool is available, otherwise a standalone HTML file in the current folder. Manual: run it with `/visualize-it`.

## Deprecated

`deprecated/` holds retired skills for reference. The release zip leaves them out.

- `humanize` — remove AI writing patterns from prose. Replaced by [`unslop`](https://github.com/cursor/plugins/blob/main/pstack/skills/unslop/SKILL.md) by poteto, which is simpler, better, and maintained.
- `pr-review` — review a PR, branch, or diff for defects. Replaced by Claude Code's built-in code review. The skill's diff handling used too many tokens, and the built-in review handles diffs better.
