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

Read the real source first: code, docs, logs, the reply being explained. Names, numbers, steps, and order on the page come from the source — a wrong picture teaches the wrong model, and looks convincing. Something inferred, not verified → label it on the page.

## Design

Format, layout, and content are your call per subject. Pick whatever explains it most simply: diagrams, flowcharts, sequence/state views, tables, charts, step-through or animated walkthroughs, interactive controls, side-by-side comparisons, worked examples. One clear idea beats many decorations; skip any section that adds no understanding.

## Output

- **Artifact tool available (Claude)** → publish as a Claude artifact, following its design/skill guidance.
- **Otherwise (Codex, VS Code, other harness)** → write one self-contained file `./visualize-<slug>.html` in the current working directory. Opens by double-click: no build step, no local server, CSS/JS inline. File already exists → ask before overwriting.

## Done

Reply with the artifact link or file path, plus one line on what the page shows.
