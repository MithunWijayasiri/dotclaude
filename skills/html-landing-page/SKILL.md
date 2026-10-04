---
name: html-landing-page
description: Static landing pages — single/few-file HTML/CSS/JS for project sites, GitHub Pages, product one-pagers. Build, redesign, or review. Layers on frontend-design; not for app UIs, dashboards, or framework SPAs.
disable-model-invocation: true
---

# HTML Landing Page

Landing-page layer on top of `frontend-design:frontend-design`.

## Precedence

- Invoke `frontend-design:frontend-design` via Skill tool first, unless already loaded this session. It owns: grounding, plan → self-check → build → critique passes, AI-default looks, typography, motion budget, copy voice, general quality floor, screenshot critique.
- This file adds only static-landing-page specifics. frontend-design updates far more often than this file → never restate or override its guidance here.
- Conflict on design taste → frontend-design wins. Conflict on landing-page constraints (checkpoint, copy verification, assets, deploy, Quality floor below) → this file wins.
- Editing this skill: before adding a rule, check frontend-design doesn't already cover it; delete rules here once it does.

## Modes

- **Build** — new page → full Process.
- **Review** — existing page → audit against frontend-design's AI-default list, Landing-page tells, Quality floor, copy accuracy (Process step 6). Report findings, most severe first. Wait for go-ahead before changing anything.
- **Redesign** — Review, then run Process only on what failed; keep what passes.

## Process

Runs inside frontend-design's passes; adds these steps.

1. **Mine the project.** Read real material first: files, structure, vernacular, concrete numbers, command strings. Distinctive choices come from the subject's own world.
2. **Extend the plan.** Beyond frontend-design's token plan, add:
   - Signature: the ONE element the page is remembered by; must embody something true about the subject.
   - Contrast: every text/bg pair ≥ 4.5:1 (body), ≥ 3:1 (large text, UI). Distinctive palettes fail this most often.
   - Theme: light-only, dark-only, or follows `prefers-color-scheme`. State it — otherwise it gets decided by accident.
3. **Checkpoint.** Show plan (palette, type, layout sketch, signature, theme); wait for approval before writing HTML. Skip only if user said to build without review. Plan changes are cheap; built-page changes aren't.
4. **Build** to the approved plan.
5. **Render.** Open page in a browser; screenshot at ~375px and ~1280px; check console for errors. Judge screenshots, not source — overflow, spacing, and specificity bugs only show rendered.
6. **Verify copy.** Check every factual claim against project source. Plausible-but-false → cut.

## Examples

Copy the reasoning, never the output — reusing an example's hero is itself a template.

- Cleanfox (literally a patch applied to Betterfox) → hero = animated diff in an editor window; section names taken from the file's own comment banners; hover-to-uncomment teaches how the file works; clean light page vs dark code objects = "the page is clean; the file is the machine".
- Bakery pre-order page (hypothetical) → hero = tomorrow's real bake schedule, one oven-timer countdown per loaf; sections follow the day's bake order; sold-out items stay listed, struck through, so the page shows what sells.

## Landing-page tells

Additions to frontend-design's AI-default list; same rule — use only when the brief asks.

- Same skeleton every time: centered hero → 3 feature cards → CTA band.
- Bento-grid feature sections.
- "Trusted by" logo strips; invented testimonials or user counts (also fail step 6).
- Purple-blue gradients, gradient text, glassmorphism.
- Glowing blurred blobs behind hero; dotted-grid or noise-texture backgrounds.
- Emoji as feature icons; decorative sparkle/rocket emoji anywhere.
- Scroll reveal on every section.

## Copy

frontend-design owns voice. Additions:

- Specific > clever: real numbers, names, and file/pref/command strings from the project ("3 defaults relaxed", "17 telemetry prefs off", "Download user.js").
- Banned slop: Unleash, Elevate, Seamless, Effortless, Supercharge, Empower, Revolutionize, "Built for the modern web".

## Quality floor

Build silently, never announce.

- Body never scrolls horizontally; wide code/tables scroll in own `overflow-x: auto` container.
- `aria-label` on figure-like code blocks.
- All motion inside `@media (prefers-reduced-motion: no-preference)`. No JS / no IntersectionObserver → all content visible (content starts visible; JS hides it pre-reveal).
- `<title>`, meta description, favicon (inline SVG or emoji data URI), og tags. `og:image` = absolute URL to a real image (~1200×630); relative URLs break link previews.
- Self-contained assets: inline SVG, data URIs; no icon/JS CDNs. Google Fonts is the only allowed external.
- Fonts: `preconnect` to `fonts.googleapis.com` and `fonts.gstatic.com` (crossorigin), `display=swap`, request only weights actually used.
- Relative asset paths only. GitHub Pages project sites serve from `/<repo>/` → root-absolute `/style.css` 404s.
