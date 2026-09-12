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

An **output style** is a markdown file that replaces Claude Code's default response voice with your own. Drop it in `~/.claude/output-styles/`, select it, and every answer follows your rules.

> [!TIP]
> The [project page](https://mithunwijayasiri.github.io/dotclaude/) answers one question in both styles and in Claude Code's default voice, side by side — the fastest way to see the difference.

### ASD-STE100

Structured output following [ASD-STE100](https://www.asd-ste100.org/) English standards. Short sentences, one word per meaning, active voice. Every answer opens with the result, then labelled bullets (`Verified:`, `Updated:`, `Skipped:`, `Remaining:`, `Next:`). Code, paths, and commands are never reworded.

Pick this when you want to scan an answer fast.

### Always Friday

Plain-English prose, no label protocol — short, simple, and easier to read. Everyday words, one idea per sentence; every fact and path kept. No rigid structure or sign-off — you understand the answer right away.

> [!NOTE]
> Pick **ASD-STE100** to get the job done with minimal words and structured output. Use **Always Friday** when you collaborate with AI on tasks beyond coding.

Both style files are short and plain — open one and edit it. To stop Claude reaching for a word you dislike, keep a vocabulary table in your own style and add a row whenever a word annoys you:

```markdown
### Word choice

Prefer plain words. Keep a long word if a short word changes the meaning.

| Avoid | Use |
|---|---|
| stale | out of date / no longer needed — specify |
| initiate, commence, kick off | start |
| utilize, leverage | use |
| in order to / prior to / subsequent to | to / before / after |
```

> [!TIP]
> The abstract rule *one term per meaning* doesn't hold on its own — an explicit row does. The same goes for examples: rules describe the shape, an example shows it.

## CLAUDE.md

`CLAUDE.md` holds the instructions that apply everywhere, so it stays short: engineering defaults, comment style, and when to look a library up instead of answering from memory.

Copy it to `~/.claude/CLAUDE.md` for global scope, or to a repo root to scope it to one project:

```bash
cp dotclaude/CLAUDE.md ~/.claude/CLAUDE.md
```

> [!NOTE]
> Its `## Response Style` section is a lightweight fallback — lead with the result, skip filler — for sessions where a different output style is selected, or none at all.

Its `## External Docs` section sends library, framework, and CLI questions to [context7](https://context7.com/) instead of letting Claude answer from memory. That is an MCP server, not a file in this repo — copy `CLAUDE.md` without it and the instruction quietly falls back to a web search. Connect it once, at user scope:

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
- **zoom-out** — map an unfamiliar code area before touching it. Nothing is edited and no mutating command runs until the map is done. Manual: `/zoom-out`.

## Install

Clone the repo, or grab the [latest release](https://github.com/MithunWijayasiri/dotclaude/releases/latest) — the ZIP bundles the output styles, skills, `CLAUDE.md`, README, and license at the top level, so its contents unpack straight into `~/.claude/`.

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

Then pick one. Type `/config` in a session and choose under **Output style** — that saves per project. To make it your default everywhere, set the field directly in `~/.claude/settings.json`:

```json
{
  "outputStyle": "ASD-STE100"
}
```

The value is the `name:` field from the file's frontmatter, not the filename. A style is part of the system prompt, so it takes effect after `/clear` or in your next session.

> [!TIP]
> Output styles are project-scoped too. A `.claude/output-styles/` folder inside a repo only applies while you're working in that repo — useful if one project wants terse reports and another wants prose.

## Credits

Thank you to both of these projects.

- **[mattpocock/skills](https://github.com/mattpocock/skills)** — Matt Pocock's skills, and the knowledge he shared along with them.
- **[gvzdv/claudish-to-english](https://github.com/gvzdv/claudish-to-english)** — where the Always Friday style came from.

## License

MIT. Take whatever is useful.
