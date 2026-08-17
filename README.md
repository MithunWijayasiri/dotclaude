<h1 align="center">dotclaude</h1>

<p align="center">
  My Claude Code setup, shared — output styles, CLAUDE.md, skills, and rules.
</p>

<p align="center">
  <a href="https://github.com/MithunWijayasiri/dotclaude/stargazers"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/stars/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Stars" src="https://www.shieldcn.dev/github/stars/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
  <a href="https://github.com/MithunWijayasiri/dotclaude/graphs/contributors"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/contributors/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Contributors" src="https://www.shieldcn.dev/github/contributors/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
  <a href="https://github.com/MithunWijayasiri/dotclaude/commits/main"><picture><source media="(prefers-color-scheme: dark)" srcset="https://www.shieldcn.dev/github/last-commit/MithunWijayasiri/dotclaude.svg?mode=dark"><img alt="Last commit" src="https://www.shieldcn.dev/github/last-commit/MithunWijayasiri/dotclaude.svg?mode=light"></picture></a>
</p>

---

## What this is

Claude Code is configurable in more places than most people use: output styles for tone, skills for repeatable jobs, rules for project conventions, and `CLAUDE.md` for standing instructions.

This repo holds my working set, so it survives a machine rebuild and anyone else can take the parts they want.

| Part | Folder | Status |
|---|---|---|
| Output styles | `output-styles/` | **Available** |
| Global instructions | `CLAUDE.md` | **Available** |
| Skills | `skills/` | Planned |
| Rules | `rules/` | Planned |

Everything below covers the two parts that have shipped.

## Output styles

Claude Code's default voice is dense prose: long paragraphs, formal vocabulary, the important sentence buried three lines down.

An **output style** replaces that default response guidance with your own — a single markdown file. Drop it in `~/.claude/output-styles/`, select it, and every answer follows your rules instead. Two are here.

> [!TIP]
> The [project page](https://mithunwijayasiri.github.io/dotclaude/) answers one question in both styles and in Claude Code's default voice, side by side. It is the fastest way to see the difference.

### ASD-STE100

Named after the real aerospace writing standard — [ASD-STE100 Simplified Technical English](https://www.asd-ste100.org/), the controlled English used in aircraft maintenance manuals so a non-native reader can follow a repair procedure without ambiguity. The same constraints work well for engineering answers.

The style enforces:

- One term per meaning, kept consistent across the whole answer
- Maximum 20 words per sentence, simple tenses, no `-ing` forms
- Active voice and imperative instructions
- A six-row vocabulary table (`utilize` → `use`, `initiate` → `start`)
- Result first, then labelled bullets: `Verified:` `Updated:` `Skipped:` `Remaining:` `Next:`
- Each label appears once; two or more items go in a nested list

Technical names, file paths, code, commands, and quoted log output are exempt and never reworded.

### Simple English

The lighter option. Short sentences and everyday words, no label protocol, no grammar limits — it reads as ordinary prose. Use it for a handover note or a summary for someone who wasn't in the debugging session.

> [!NOTE]
> Simple English uses *simpler* words but usually *more* of them. It trades scannability for readability. Pick ASD-STE100 if you want to skim, Simple English if you want to read.

## Install the output styles

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

## Make it yours

Both style files are short and plain — open one and edit it.

**Keep the vocabulary table.** The abstract rule *one term per meaning* doesn't hold on its own; an explicit row does. Add one whenever a word annoys you.

**Keep at least one worked example.** Rules describe the shape; an example shows it. Formatting held up far more reliably with a concrete example present.

## CLAUDE.md

`CLAUDE.md` holds the instructions that apply everywhere, so it stays short. Engineering defaults, comment style, and when to look a library up instead of answering from memory. Claude Code loads it at the start of every session, in every project.

Copy it to `~/.claude/CLAUDE.md` for global scope, or to a repo root to scope it to one project:

```bash
cp dotclaude/CLAUDE.md ~/.claude/CLAUDE.md
```

> [!NOTE]
> Its `## Response Style` section is a lightweight fallback — lead with the result, skip filler — for sessions where a different output style is selected, or none at all.

## Roadmap

| Item | Status |
|---|---|
| Output styles | Available |
| `CLAUDE.md` — my global instruction file | Available |
| Skills — reusable task workflows in `skills/` | Planned |
| Rules — scoped `.claude/rules/` files for project conventions | Planned |
| Hooks and settings reference | Considering |

The `skills/` and `rules/` folders are placeholders for now.

## Credits

Thank you to both of these projects.

- **[mattpocock/skills](https://github.com/mattpocock/skills)** — Matt Pocock's skills, and the knowledge he shared along with them.
- **[gvzdv/claudish-to-english](https://github.com/gvzdv/claudish-to-english)** — where the Simple English style came from.

## License

MIT. Take whatever is useful.
