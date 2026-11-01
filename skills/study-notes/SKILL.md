---
name: study-notes
description: Turn study material — syllabus or course PDFs, markdown files, links — into study notes. Builds a boilerplate outline per chapter and learning objective, then optionally fills notes chapter by chapter. Writes to Notion, an Obsidian vault, or plain markdown.
argument-hint: "Source(s) — PDF/.md path or URL — plus optional target (Notion page, Obsidian vault path, or .md path)"
disable-model-invocation: true
---

# Study Notes

Notes exist to be studied: short, easy to scan, and faithful to the source. A wrong or invented point gets memorized, so the source decides every fact.

## Inputs

Ask only for what the user did not give, all in one question round.

- **Sources** — PDF, `.md`, URL, existing Notion page. Several allowed. Read every source; unreadable → say which and stop.
- **Target** — Notion, Obsidian, or plain markdown.
  - Notion → page URL or name (search if name only). Notion connector missing → say so, offer markdown instead.
  - Obsidian → vault path, plus folder inside the vault (default: vault root).
  - Plain markdown → path, default current folder.
- **Mode** — boilerplate only, or full notes.
- **Style reference** (optional) — the user's earlier notes. Given → mirror their headings, markers, and colors over the defaults below.

## Large sources

Token-heavy reads (long PDFs, big pages) → Sonnet subagents, one per chapter, in parallel. Ask each for a faithful digest: item names exact, ≤15-word gist per item, every pro/con and ordered list, no outside knowledge, source oddities flagged. Short chapters → read inline.

PDF → extract text once to a scratch file (`pypdf`), reuse it for every later read.

## Step 1 — Outline

Extract from the source: chapters, sections, subsections, learning objectives (code, level, exact text), keywords, study time, exam structure. Missing info stays missing — never invent question counts, pass marks, or durations; use `?`.

## Step 2 — Boilerplate

- **Introduction**: Paper Structure (per chapter: `? Questions` unless source gives counts, study time in gray), level legend with only levels the source uses, resource links the user gives.
- **Per chapter**: `# N. Title`, gray `Keywords:` line (source says keywords are examinable when it lists them), `## N.M Section`, `### N.M.K Short title <level emoji>`, then an `Objective:` line with the exact LO text and an empty spacer for notes.
- Headings are short topic names (e.g. "Framework Layering"), not the full LO sentence — the exact wording lives on the `Objective:` line.
- Source has no LOs or levels → chapters and sections only; drop Objective lines, legend, and Paper Structure.

Level emojis: K1 🟧, K2 🟩, K3 🟪, K4 🟥. Other level schemes → pick distinct square emojis and show them in the legend.

Boilerplate only → stop here and report.

## Step 3 — Notes (full mode)

One chapter at a time, in order:

1. Digest the chapter (see Large sources).
2. Propose in chat, per subsection: which blocks and their key points. Wait for approval. User said to do all chapters without stopping → skip approval.
3. Add notes under that subsection's `Objective:` line.
4. Offer the next chapter.

Blocks, chosen per content:

- Italic definition line → one-sentence meaning of the core term.
- Table → comparisons, pros/cons, "X vs Y", items with 2+ attributes.
- List → enumerations; keep the source's order when it gives one.
- Callout → key takeaway, limitation, rule the source stresses.
- Gray line → secondary detail worth keeping but not memorizing first.

Rules:

- Only what the source says. Keep the source's item names. No outside knowledge, no inferred orderings or chains the source does not state.
- Source oddity (typo, contradiction, "three" then lists four) → keep the source wording, add a short gray note. Exams follow the source wording.
- Color sparingly: green pros, red cons or critical points, bold for key terms.
- Short: 2–3 points per table cell, one line per list item.

## Step 4 — Verify (full mode)

After the last chapter, a Sonnet subagent fact-checks the whole note against the source. Report only: factual errors, unsupported claims, items missing from a list presented as complete. Ask for the verbatim note snippet and source location per finding.

Re-check each finding against the source yourself before fixing — subagent output is a lead, not proof. Fix confirmed ones, skip the rest with a reason.

## Output

- Notion → follow `references/notion.md`.
- Obsidian or plain markdown → follow `references/markdown.md`. One file per course.
- Existing note → keep the user's content and edits; insert, never replace the whole note. File exists and is not the target note → ask before overwriting.

## Done

Report the page link or file path, chapters covered, and what is left as `?`.
