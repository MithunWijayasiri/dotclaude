# Picking visuals

Choose by shape of the information, not by what looks impressive. Hand-written SVG coordinates are about half the tokens of a hand-made page, so render diagrams from text (Mermaid) and everything else in plain HTML/CSS.

| Shape of the information | Visual | Render with |
|---|---|---|
| What connects to what, architecture, decision branches | Flowchart (`LR` wide, `TB` layered) | Mermaid `flowchart` |
| States + events between them, lifecycle, handshake | State machine (self-transitions, start/end) | Mermaid `stateDiagram-v2` |
| Entities, fields, relations | ER diagram (PK/FK, cardinality) | Mermaid `erDiagram` |
| Classes, interfaces, dependencies | Class diagram | Mermaid `classDiagram` |
| Messages between actors over time | Sequence diagram (phases as `rect`/notes) | Mermaid `sequenceDiagram` |
| Branch/merge history | Git graph | Mermaid `gitGraph` |
| HTTP/RPC contract | API card: method + path, params, request/response shapes | HTML |
| Hierarchy, folders, taxonomy | Tree | HTML nested list / `<details>` |
| History, phases, release order | Timeline (highlight the key point) | HTML |
| One value vs one limit per row | Limit bars (`13 / 20 unit`), axis from 0, over-limit red | HTML/CSS bars |
| Numbers: shares of a whole / one simple series | Pie (≤6 slices) / bar / line | Mermaid `pie` / `xychart` |
| Numbers: several series, tooltips needed | Bar / line chart | Chart.js |
| Comparison across ≥3 dimensions, can/cannot list | Table; status as icon + colour (✓ ✗ !), never colour alone; sort/filter when long | HTML |
| Word-level comments on one sentence or line | Annotated text | HTML |
| Metadata, title block | Key-value grid | HTML |
| Conclusion, warning, risk | Callout (info / ok / warn / err) | HTML |
| Real screen or UI | Existing screenshot file only | `<img>` |
| Existing code | Quoted code block | HTML |
| Code change | Diff block | HTML |
| Code that doesn't exist yet, a command | Code block labelled "sketch" | HTML |

Hand-drawn SVG → only for a drawing neither Mermaid nor HTML can make; keep it small. Never use PlantUML, Kroki, or any remote renderer: they send the diagram text to an outside server.

Wide table or diagram → scrolls inside its own wrapper (`overflow-x: auto`), never the page.

## Mermaid

User's choice; overrides the `artifact-diagramming` skill's inline-SVG / no-library mechanics. Its "what to draw" rules still apply: depict the mechanism, label every arrow with what moves (`writes`, `polls every 30s`), draw the difference when comparing.

Diagram markup, both outputs:

```html
<figure>
  <pre class="mermaid" role="img" aria-label="Request path from client to DB">flowchart LR
  client["Client"] -->|"POST /orders"| api["API"]
  api -->|"writes"| db[("DB")]</pre>
  <figcaption>Request path from client to DB.</figcaption>
</figure>
```

- **Artifact** → markup only. The artifact host renders `<pre class="mermaid">` natively; never load Mermaid there.
- **Standalone file** → add the loader once, end of `<body>`. Pinned version must be exact and ≥2 weeks old; bump only to one that is. Mermaid's `base` theme takes colours from the page's tokens (hex values only — it derives shades from them); `--cat-1…n` are the categorical tokens shared with charts:

```html
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@12.2.0/dist/mermaid.esm.min.mjs';
  const diagrams = [...document.querySelectorAll('pre.mermaid')].map(el => [el, el.innerHTML]);
  async function render() {
    const css = getComputedStyle(document.documentElement), v = n => css.getPropertyValue(n).trim();
    mermaid.initialize({ startOnLoad: false, theme: 'base', themeVariables: {
      fontFamily: v('--font-body'), background: v('--panel'), primaryColor: v('--panel'),
      primaryTextColor: v('--fg'), primaryBorderColor: v('--muted'), lineColor: v('--muted'),
      textColor: v('--fg'), edgeLabelBackground: v('--panel'),
      actorBkg: v('--panel'), actorBorder: v('--muted'), signalColor: v('--fg'), signalTextColor: v('--fg'),
      pie1: v('--cat-1'), pie2: v('--cat-2'), pie3: v('--cat-3'), pie4: v('--cat-4'),
      pieStrokeColor: v('--panel'), pieSectionTextColor: '#ffffff', pieLegendTextColor: v('--fg')
    } });
    // run() skips elements marked data-processed
    for (const [el, src] of diagrams) { el.removeAttribute('data-processed'); el.innerHTML = src; }
    await mermaid.run();
  }
  await render();
  new MutationObserver(render).observe(document.documentElement, { attributeFilter: ['data-theme'] });
</script>
```
- Quote every label: `id["Text (x)"]`, edge `-->|"text"|`. Unquoted `( ) [ ] { } : ;` → syntax-error box instead of a diagram.
- Short ids without spaces; text lives in the label.
- `<` / `&` in labels → `&lt;` / `&amp;` (the source sits inside HTML).
- Layout: Mermaid 12 uses ELK by default — no config needed.

## Diagram quality

- No edge through a node or another edge's label. Crowded → flip `LR`/`TB` or split into two diagrams; never squeeze.
- ~15 nodes max per diagram; more → split.
- Wide `LR` flowchart (>4 nodes across) → full-width section, or its text shrinks to unreadable.
- Diagrams on one page at a similar scale — none much larger than its neighbour.
- Wrap each in `<figure>` + `<figcaption>` stating the one claim it shows; same claim in `aria-label`.

## Plans and refactors

Show a structural change as **one** diagram (flow, state, tree, ER) with change markers, not a before and an after:

- Added / removed / changed nodes → Mermaid `classDef added`, `classDef removed` (dashed stroke), `classDef changed`, applied with `class id added`. Unchanged nodes plain. Legend with `+` / `-` / `~` so meaning isn't colour alone.
- Changed link/relation → old edge removed, new edge added. Flowchart → dash the old edge via `linkStyle`. State diagram has no `linkStyle` (parse error) → label the old transition `removed`.
- Before / After toggle → keep the before and after sources as two more `pre.mermaid` blocks, show one at a time.

## Code

- Existing code → quote 10–40 real lines that make the point, with `path:line` range and the key line highlighted. Copy from the file; never retype from memory.
- Code block >40 lines → cut to the lines that matter.
- Diff → every line starts with `+`, `-`, space, or `@@`; no `...` cuts — split into hunks instead.

## Data and images

- No chart or limit bars without real numbers from the source. Sample numbers → label "illustrative" on the page.
- Plain numbers, unit in the axis/label, highlight the one row the reader must see; grey the rest.
- Bar axis starts at 0; line axis may start above 0.
- Collapsed data table (`<details>`) under every chart.
- Chart.js → `https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.6.1/chart.umd.min.js`, before the inline script that uses it. Colours from the page tokens via `getComputedStyle`; redraw on `data-theme` change (`MutationObserver`). Marks per the `dataviz` skill when available.
- Images only for what a diagram can't show (real UI), from existing files. Never generate or invent one.

## Page recipes by question type

Starting points, not templates — drop any section the subject doesn't need.

| Question | Sections in order |
|---|---|
| Decision / plan | Today (current state) → proposed sketch (change-marked diagram) → numbered steps → open decisions last |
| Comparison (A vs B) | Status table → verdict callout → key facts grid |
| History / evolution | Full-width timeline, turning point highlighted → old → new mapping table → why it happened (≤3 bullets) |
| Codebase / repo tour | Trimmed folder tree → call-graph flowchart with `subgraph` groups → numbered "where to start reading" |
| Process / protocol | Sequence diagram → "why this way" warn callout → state machine → reference table |
| Writing / output review | Annotated text → limit bars → rule table with Before / After (`~~wrong~~` for counter-examples) |
| Debugging / failure | Conclusion callout (cause) → sequence or flow of the failing path, failing hop highlighted → evidence (`path:line`, log line) → fix |
