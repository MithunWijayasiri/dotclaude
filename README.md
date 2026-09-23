<h1 align="center">dotclaude</h1>

<p align="center">
  My Claude Code setup — output styles, CLAUDE.md, and skills.
</p>

<p align="center">
  <a href="https://github.com/MithunWijayasiri/dotclaude/releases/latest"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/release/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Latest release" src="https://www.shieldcn.dev/github/release/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
  <a href="https://github.com/MithunWijayasiri/dotclaude/stargazers"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/stars/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Stars" src="https://www.shieldcn.dev/github/stars/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
  <a href="https://github.com/MithunWijayasiri/dotclaude/commits/main"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/last-commit/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Last commit" src="https://www.shieldcn.dev/github/last-commit/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
</p>

---

Plain markdown in `~/.claude` — *output styles* shape how Claude answers, *skills* add repeatable jobs, and `CLAUDE.md` sets the defaults. 

## Table of contents

- [Output styles](#output-styles)
- [CLAUDE.md](#claudemd)
- [Skills](#skills)
- [Install](#install)

## Output styles

> [!TIP]
> The [project page](https://mithunwijayasiri.github.io/dotclaude/) compares ASD-STE100 with Claude Code's built-in `Concise` and `Default` on the same question.

### ASD-STE100

Structured output following [ASD-STE100](https://www.asd-ste100.org/) English standards: short sentences, everyday words, one word per meaning, active voice. The result comes first, then labelled bullets (`Verified:`, `Updated:`, `Skipped:`, `Remaining:`, `Next:`). Code and commands are never reworded.

## CLAUDE.md

Standing instructions for every session: General, Engineering, File & Command Safety, Comments, External Docs. Copy it to `~/.claude/CLAUDE.md`, or to a repo root for one project.

`## External Docs` sends library questions to [context7](https://context7.com/), an MCP server. Without it, Claude falls back to a web search. Connect it once:

```bash
claude mcp add --scope user --transport http --header "Authorization: Bearer YOUR_API_KEY" context7 https://mcp.context7.com/mcp
```

> [!TIP]
> A free key comes from the [context7 dashboard](https://context7.com/dashboard). Prefer a local server? `claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY`.

## Skills

A skill is a task procedure Claude Code loads on demand — one way to do one job. See [`skills/README.md`](skills/README.md) for usage.

- **compact-markdown** — telegraphic markdown for AI-facing docs. Strips filler, keeps code and examples.
- **humanize** — remove AI writing patterns from prose. Use for human-facing writing where voice matters.
- **handoff-session** — hand the whole session over: state, decisions, blockers, next steps. Detail that no longer matters is dropped.
- **offload-task** — write one stuck problem into a standalone brief a fresh session can attack: goal, failing behaviour, repro, and every attempt with what it produced — code and manual checks alike.
- **claude-project-rules** — author `.claude/rules/*.md` with correct `paths:` scoping, lazy-load, and shared-rule symlinks.
- **html-landing-page** — design a distinctive static landing page. Plan palette, type, and one signature element before any HTML.
- **git-merge** — merge a branch into yours without losing local unstaged work. Diagnose each conflict, then run the repo's own checks to catch the ones git merged cleanly but wrongly.
- **pr-review** — review a PR, branch, commit, or uncommitted work for defects. Findings grouped Blocker / Should fix / Nit, each with `file:line`, the input that breaks it, and a fix. Manual: `/pr-review`.
- **zoom-out** — map an unfamiliar code area before touching it. Nothing is edited and no mutating command runs until the map is done. Manual: `/zoom-out`.

## Install

Clone the repo, or unzip the [latest release](https://github.com/MithunWijayasiri/dotclaude/releases/latest) straight into `~/.claude/`.

```bash
git clone https://github.com/MithunWijayasiri/dotclaude.git
mkdir -p ~/.claude/output-styles ~/.claude/skills
cp dotclaude/output-styles/*.md ~/.claude/output-styles/
cp dotclaude/CLAUDE.md ~/.claude/CLAUDE.md
cp -r dotclaude/skills/* ~/.claude/skills/
```

<details>
<summary>Windows PowerShell</summary>

```powershell
git clone https://github.com/MithunWijayasiri/dotclaude.git
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\output-styles", "$env:USERPROFILE\.claude\skills"
Copy-Item dotclaude\output-styles\*.md "$env:USERPROFILE\.claude\output-styles\" -Force
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

Then pick a style under `/config` → **Output style** (saved per project). For a global default, set it in `~/.claude/settings.json`:

```json
{
  "outputStyle": "ASD-STE100"
}
```

The value is the frontmatter `name:`, not the filename. It takes effect after `/clear` or in a new session.

## Credits

Thank you to this project.

- **[mattpocock/skills](https://github.com/mattpocock/skills)** — Matt Pocock's skills, and the knowledge he shared along with them.

## License

MIT. Take whatever is useful.
