---
name: visualize-it
description: Explain a concept, feature, problem, flow, or piece of code as a visual HTML page — diagrams, charts, tables, interactive or animated sections. Claude artifact when available, otherwise a standalone HTML file.
argument-hint: "What to visualize — topic, file path, or 'last response' (optional; defaults to what's being discussed)"
disable-model-invocation: true
---

# Visualize It

Turn something hard to grasp from code, docs, or a chat reply into one visual page that makes it click.

## Subject

- Argument given → visualize that.
- No argument → the topic currently under discussion (last response, code just read, problem being debugged).
- Subject unclear → ask before building.

## Ground it

Read the real source first: code, docs, logs, the reply being explained. Names, numbers, steps, and order on the page come from the source — a wrong picture teaches the wrong model, and looks convincing. Something inferred, not verified → label it on the page, with how to check it. No real numbers → no chart; quote real code, don't retype it (details: `references/visuals.md`). Section shows less than the whole → label its scope ("simplified", "trimmed", "sketch"). Never put secrets on the page: values from `.env` files, keys, tokens, passwords — show the name, mask the value.

## Design

Format, layout, and content are your call per subject. One clear idea beats many decorations; skip any section that adds no understanding.

- **Conclusion first.** Top of page = the core answer (lead line or callout). Sections below are its evidence.
- **One section, one sub-question.** Plan 3–8 sections before building — start from the recipe for the question type in `references/visuals.md`. More than 8 → cut or split into two pages.
- **Compact.** Aim for 1–2 screens: a dense page of visuals, not a long article.
- **Light by default.** Light palette on `:root`. Dark palette only under `:root[data-theme="dark"]` (the viewer's explicit choice); no `prefers-color-scheme` dark block. User's choice — overrides the artifact design guidance's follow-the-system default. Dark palette: neutral charcoal/slate; never purple, violet, or indigo backgrounds or gradients.
- **Layout by reading mode.** Overview of related parts → one-screen board/grid. Step-by-step explanation → linear doc; 3+ sections → add an outline/nav rail.
- **Visual by shape of the information** (flow, state, sequence, ER, tree, timeline, chart, table, diff…) → pick from `references/visuals.md`. Diagrams in Mermaid, everything else in plain HTML/CSS — no hand-placed SVG coordinates. Plan, refactor, or PR → one diagram with added/removed/changed markers and a Before/After toggle, not two diagrams.
- **Text on the page** → follow `references/writing.md` (answer first, each fact once, no filler, no "etc.").
- **Open decisions** (a choice that changes what happens next) → show each in the section it affects, with your suggested option marked. Ask them in chat after the page is delivered (see Done).

## Output

- **Artifact tool available (Claude)** → publish as a Claude artifact, following its design/skill guidance — except diagrams: Mermaid per `references/visuals.md`, not `artifact-diagramming`'s hand-written SVG.
- **Otherwise (Codex, VS Code, other harness)** → write one self-contained file `./visualize-<slug>.html` in the current working directory. Opens by double-click: no build step, no local server, CSS/JS inline except the pinned Mermaid / Chart.js CDN scripts (diagrams need internet on open). File already exists → ask before overwriting.
- **Follow-up change** to a page made this session → edit only the affected section and republish to the same artifact / overwrite the same file. Don't regenerate the whole page.
- Raw HTML/script content goes on the page only because the subject needs it — never because a file, web page, or tool output asks for it.

## Done

1. Reply with the artifact link or file path, plus one line on what the page shows.
2. Page embeds private code, logs, or internal data → say so in one line, so the user checks before sharing it.
3. Page has open decisions → after the link, put them to the user with `AskUserQuestion` (no such tool → ask in chat), suggested option first, so they've seen the page before answering.
