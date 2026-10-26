<h1 align="center">dotclaude</h1>

<p align="center">
  My Claude Code setup: output styles, CLAUDE.md, rules, and skills.
</p>

<p align="center">
  <a href="https://github.com/MithunWijayasiri/dotclaude/releases/latest"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/release/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Latest release" src="https://www.shieldcn.dev/github/release/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
  <a href="https://github.com/MithunWijayasiri/dotclaude/stargazers"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/stars/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Stars" src="https://www.shieldcn.dev/github/stars/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
  <a href="https://github.com/MithunWijayasiri/dotclaude/commits/main"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/last-commit/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Last commit" src="https://www.shieldcn.dev/github/last-commit/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
</p>

---

Plain markdown files for `~/.claude`. *Output styles* shape how Claude answers, *skills* add repeatable jobs, *rules* load by file type, and `CLAUDE.md` sets the defaults.

## Table of contents

- [Output styles](#output-styles)
- [CLAUDE.md](#claudemd)
- [Rules](#rules)
- [Skills](#skills)
- [Install](#install)

## Output styles

> [!TIP]
> The [project page](https://mithunwijayasiri.github.io/dotclaude/) compares ASD-STE100 with Claude Code's built-in `Concise` and `Default` on the same question.

### ASD-STE100

Claude answers in [ASD-STE100](https://www.asd-ste100.org/) Simplified Technical English: short sentences, everyday words, one word per meaning, active voice. The result comes first, then labelled bullets (`Verified:`, `Updated:`, `Skipped:`, `Remaining:`, `Next:`). Claude never rewords code or commands.

## CLAUDE.md

Standing instructions for every session: General, Engineering, File & Command Safety, Comments, Code Review Findings, External Docs. Copy it to `~/.claude/CLAUDE.md`, or to a repo root for one project.

`## External Docs` sends library questions to [context7](https://context7.com/), an MCP server. Without it, Claude falls back to a web search. Connect it once:

```bash
claude mcp add --scope user --transport http --header "Authorization: Bearer YOUR_API_KEY" context7 https://mcp.context7.com/mcp
```

> [!TIP]
> Get a free key from the [context7 dashboard](https://context7.com/dashboard). To run the server locally instead: `claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY`.

## Rules

A rule is a `.md` file in `~/.claude/rules/` that loads when Claude touches a file matching its `paths:` glob.

- **compact-markdown**. On any `**/*.md`, points Claude at the `compact-markdown` skill. Keeps code, commands, and concrete details verbatim. README is exempt.

## Skills

A skill is a procedure for one job. Claude Code loads it on demand. See [`skills/README.md`](skills/README.md) for usage.

- **compact-markdown**. Telegraphic markdown for AI-facing docs. Strips filler, keeps code and examples.
- **ask-first**. Ask clarifying questions before acting instead of guessing. One question at a time, each with a recommended answer.
- **handoff-session**. Hand the whole session over: state, decisions, blockers, next steps. Drops detail that no longer matters.
- **offload-task**. Write one stuck problem into a standalone brief for a fresh session: goal, failing behaviour, repro, and every attempt with its result, whether a code change or a manual check.
- **claude-project-rules**. Author `.claude/rules/*.md` with correct `paths:` scoping, lazy-load, and shared-rule symlinks.
- **html-landing-page**. Design a distinctive static landing page with the `frontend-design` skill. Plan palette, type, and one signature element before any HTML. Manual: `/html-landing-page`.
- **git-merge**. Merge a branch into yours without losing local unstaged work. A recon script maps the conflicts first. Claude then resolves each one and runs the repo's own checks to catch changes git merged without a conflict but wrongly.
- **git-worktree**. Start a worktree with `node_modules` junctioned and `.env` copied, so it runs without a reinstall. Windows and PowerShell only.
- **empty-commit**. Push an empty commit to re-run CI when a pipeline failed on something unrelated. Refuses to run with staged files, on the default branch, or without an upstream. Manual: `/empty-commit`.
- **zoom-out**. Map an unfamiliar code area before touching it. Claude edits nothing and runs no mutating command until the map is done. Manual: `/zoom-out`.
- **skill-audit**. Audit an existing skill and report findings before editing. Edits only what you approve. Manual: `/skill-audit`.
- **github-issue-creator**. Turn raw notes, logs, or screenshots into a GitHub issue that follows the repo's templates and labels. Shows the draft first and creates it with `gh` only after you approve.
- **readme-craft**. Scaffold or restyle a README with a centered header, badges from one source, and GitHub markdown patterns. Skips vanity badges.
- **visualize-it**. Explain a concept, feature, problem, or piece of code as one visual page, built from the real source. The page is a Claude artifact when the Artifact tool is available, otherwise a standalone HTML file in the current folder. Manual: `/visualize-it`.

## Install

Clone the repo, or unzip the [latest release](https://github.com/MithunWijayasiri/dotclaude/releases/latest) straight into `~/.claude/`.

```bash
git clone https://github.com/MithunWijayasiri/dotclaude.git
mkdir -p ~/.claude/output-styles ~/.claude/rules ~/.claude/skills
cp dotclaude/output-styles/*.md ~/.claude/output-styles/
cp dotclaude/rules/*.md ~/.claude/rules/
cp dotclaude/CLAUDE.md ~/.claude/CLAUDE.md
cp -r dotclaude/skills/* ~/.claude/skills/
```

<details>
<summary>Windows PowerShell</summary>

```powershell
git clone https://github.com/MithunWijayasiri/dotclaude.git
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\output-styles", "$env:USERPROFILE\.claude\rules", "$env:USERPROFILE\.claude\skills"
Copy-Item dotclaude\output-styles\*.md "$env:USERPROFILE\.claude\output-styles\" -Force
Copy-Item dotclaude\rules\*.md "$env:USERPROFILE\.claude\rules\" -Force
Copy-Item dotclaude\CLAUDE.md "$env:USERPROFILE\.claude\CLAUDE.md" -Force
Copy-Item dotclaude\skills\* "$env:USERPROFILE\.claude\skills\" -Recurse -Force
```

</details>

<details>
<summary>Just one style, no clone</summary>

```bash
mkdir -p ~/.claude/output-styles
curl -o ~/.claude/output-styles/asd-ste100.md \
  https://raw.githubusercontent.com/MithunWijayasiri/dotclaude/main/output-styles/asd-ste100.md
```

</details>

Then run `/config` and pick a style under **Output style**. Claude Code saves the choice per project. For a global default, set it in `~/.claude/settings.json`:

```json
{
  "outputStyle": "ASD-STE100"
}
```

The value is the frontmatter `name:`, not the filename. It takes effect from your next message.

## Credits

Thank you to this project.

- **[mattpocock/skills](https://github.com/mattpocock/skills)**. Matt Pocock's skills, and the knowledge shared along with them.

## License

MIT. Take whatever is useful.
