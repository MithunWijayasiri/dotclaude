# Markdown output (Obsidian and plain)

One `.md` file per course, named `<Course Title>.md`. Same heading structure, level emojis, and blocks as Notion; only the syntax changes.

## Location

- Obsidian → `<vault>/<folder>/<Course Title>.md`. Vault path must contain `.obsidian/`; missing → confirm the path with the user before writing.
- Plain → given path, else current folder.
- Insert into an existing note with targeted edits; never rewrite the whole file.

## Blocks

| Block | Obsidian | Plain markdown |
|---|---|---|
| Divider between chapters | `---` | `---` |
| Keywords / gray detail | `*Keywords: ...*` | `*Keywords: ...*` |
| Objective line | `` `Objective`: Explain ... `` | `` `Objective`: Explain ... `` |
| Definition line | `*term = meaning*` | `*term = meaning*` |
| Critical point | `==plaintext password==` | `**plaintext password**` |
| Callout | `> [!tip] Limitations` + `> - item` | `> **Limitations**` + `> - item` |
| Table | GFM pipe table, multi-line cell `a<br>b` | same |

No spacer blocks — a blank line separates blocks.

Obsidian only: frontmatter with tags.

```markdown
---
tags: [study, ctal-tae]
source: ISTQB_CTAL-TAE_Syllabus_v2.0.pdf
---
```

Pros/cons table header: `| Approach | What it is | ✅ Pros | ❌ Cons |` — markdown has no text color.
