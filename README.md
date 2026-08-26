<h1 align="center">dotclaude</h1>

<p align="center">
  My Claude Code setup — output styles, CLAUDE.md, and skills.
</p>

<p align="center">
  <a href="https://github.com/MithunWijayasiri/dotclaude/stargazers"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/stars/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Stars" src="https://www.shieldcn.dev/github/stars/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
  <a href="https://github.com/MithunWijayasiri/dotclaude/graphs/contributors"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/contributors/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Contributors" src="https://www.shieldcn.dev/github/contributors/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
  <a href="https://github.com/MithunWijayasiri/dotclaude/commits/main"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/last-commit/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Last commit" src="https://www.shieldcn.dev/github/last-commit/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
</p>

---

Plain markdown in `~/.claude` — *output styles* shape how Claude answers, *skills* add repeatable jobs, and `CLAUDE.md` sets the defaults. 

## Table of contents

- [Output styles](#output-styles)
- [CLAUDE.md](#claudemd)
- [Skills](#skills)

## Output styles

An **output style** is a single markdown file that replaces Claude Code's default response voice with your own. Drop it in `~/.claude/output-styles/`, select it, and every answer follows your rules instead. Two are here.

> [!TIP]
> The [project page](https://mithunwijayasiri.github.io/dotclaude/) answers one question in both styles and in Claude Code's default voice, side by side. It is the fastest way to see the difference.

### ASD-STE100

Structured output following [ASD-STE100](https://www.asd-ste100.org/) English standards that any reader can understand.

Short sentences, one word per meaning, active voice. Every answer opens with the result, then labelled bullets (`Verified:`, `Updated:`, `Skipped:`, `Remaining:`, `Next:`). Code, paths, and commands are never reworded.

Pick this style when you want to scan an answer fast.

### Always Friday

Simple, clear output that's easy to read — like Friday afternoon.

Plain, everyday words in ordinary sentences. No label protocol — it reads like a normal explanation.

Pick this style for a handover note or a summary for someone who wasn't in the debugging session.

> [!NOTE]
> Pick **ASD-STE100** to get the job done with minimal words and structured output. Use **Always Friday** when you collaborate with AI on tasks beyond coding.

### Install

```bash
git clone https://github.com/MithunWijayasiri/dotclaude.git
cp dotclaude/output-styles/*.md ~/.claude/output-styles/
```

<details>
<summary>Windows PowerShell</summary>

```powershell
git clone https://github.com/MithunWijayasiri/dotclaude.git
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\output-styles"
Copy-Item dotclaude\output-styles\*.md "$env:USERPROFILE\.claude\output-styles\"
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
> Output styles are project-scoped too. A `.claude/output-styles/` folder inside a repo only applies while you're working in that repo, which is useful if one project wants terse reports and another wants prose.

Both style files are short and plain — open one and edit it. To stop Claude reaching for a particular word, keep a vocabulary table in your own style and add a row whenever a word annoys you:

```markdown
### Word choice

Prefer plain words. Keep long word if short word changes meaning.

| Avoid | Use |
|---|---|
| stale | out of date / no longer needed — specify |
| initiate, commence, kick off | start |
| utilize, leverage | use |
| in order to / prior to / subsequent to | to / before / after |
```

> [!TIP]
> The abstract rule *one term per meaning* doesn't hold on its own — an explicit row does. The same goes for examples: rules describe the shape, an example shows it. Formatting held up far more reliably with at least one worked example in the file.

## CLAUDE.md

`CLAUDE.md` holds the instructions that apply everywhere, so it stays short. Engineering defaults, comment style, and when to look a library up instead of answering from memory.

Copy it to `~/.claude/CLAUDE.md` for global scope, or to a repo root to scope it to one project:

```bash
cp dotclaude/CLAUDE.md ~/.claude/CLAUDE.md
```

> [!NOTE]
> Its `## Response Style` section is a lightweight fallback — lead with the result, skip filler — for sessions where a different output style is selected, or none at all.

## Skills

A skill is a task procedure Claude Code loads on demand — repeatable, one way to do one job. See [`skills/README.md`](skills/README.md) for usage.

- **compact-markdown** — telegraphic markdown for AI-facing docs. Strips filler, keeps code and examples. Compact and still human-readable.
- **humanize** — remove AI writing patterns from prose. Use for human-facing writing where voice matters.
- **handoff** — compact the current conversation into a handoff doc for the next session.
- **writing-rules** — author `.claude/rules/*.md` with correct `paths:` scoping and lazy-load.
- **html-landing-page** — design a distinctive static landing page. Plan palette, type, and one signature element before any HTML; bans the AI-default look.
- **git-merge** — merge a branch into yours without losing local unstaged work. Diagnose each conflict, then run the repo's own checks to catch the ones git merged cleanly but wrongly.

## Credits

Thank you to both of these projects.

- **[mattpocock/skills](https://github.com/mattpocock/skills)** — Matt Pocock's skills, and the knowledge he shared along with them.
- **[gvzdv/claudish-to-english](https://github.com/gvzdv/claudish-to-english)** — where the Always Friday style came from.

## License

MIT. Take whatever is useful.
