---
name: fuckingwebsite
description: Use when building a cheat sheet, checklist, field guide, quick-reference page, or pocket calculator as one offline HTML file for phone use. Handles task-adapted, slop-free styling and saved state. Not for landing pages → `html-landing-page`, app UI or framework components, or concept explainers → `visualize-it`.
argument-hint: "What the page is for — topic, scenario, or source notes"
---

# FuckingWebsite — Zero-Slop Reference & Utility Builder

Target feel: well-printed pocket field manual or industrial tool — legible, tactile, offline-portable.

## 1. Core rules

- Information first: exact numbers, specs, steps, or answers on screen immediately. No hero sections, taglines, or "Welcome to..." intros.
- Simple text: all copy in ASD-STE100 (Simplified Technical English). Steps ≤20 words, descriptions ≤25. One idea per sentence. Everyday words, one meaning per word; explain a technical term on first use. Active voice, imperative for steps. No idiom, slang, or metaphor. Specs, part numbers, commands, and code stay exact.
- No AI slop: no purple/indigo/cyan gradients, glassmorphic cards, decorative blobs, gratuitous drop shadows, or filler copy.
- One self-contained `.html` file → user saves it to phone (iOS Files / Android), AirDrops it, opens it offline at a garage, kitchen, airport, or server rack.
- Mobile-first: one-handed reading in bright outdoor or workshop light; scales cleanly to desktop.
- Facts: specs and numbers come from the user, given files, or a web lookup. Can't confirm one → ask; never invent. A wrong number read off a phone at the counter is the main failure.
- Output: save to `~/Downloads/<slug>.html`; give the path.

## 2. Adapt aesthetic to the task

Rows below are examples, not rules. Fit visual system, typography, and micro-interactions to where the page is used — invent a different palette, type pairing, layout, or affordance whenever the task suits it better. Only constraint: every element earns its place.

| Domain / Use Case | Visual Direction & Palette | Tailored Utility Features |
| :--- | :--- | :--- |
| **Garage, Hardware & Repairs** | Warm workshop paper (`#F7F7F5`), ink zinc (`#18181B`), crisp `1px` borders, safety amber warnings, monospace part numbers. | Persistent inspection checkboxes, "Flag to Replace" toggles, copyable parts shopping list. |
| **Kitchen, Coffee & Recipes** | Warm parchment/cream, espresso or terracotta ink, large step numbers, generous line height. | Ingredient multiplier (`1x / 2x`), tap-to-cross-off ingredients, built-in step timers, screen wake-lock toggle. |
| **Code, CLI & Sysadmin** | High-contrast slate or crisp light terminal sheet, strict grid alignment, `JetBrains Mono` code blocks. | One-tap copy buttons on commands, live search/filter by flag or keyword, OS/shell switcher tabs. |
| **Travel, Medical & Pocket Cards** | Stark high-contrast white/black, emergency red/emerald callouts, extra-large tap targets (`>= 48px`). | Tap-to-copy addresses/phrases, quick currency/unit converter, pinned critical numbers at top. |
| **Reading, Essays & Guides** | Editorial serif + clean sans pairing, `62ch–68ch` reading measure, subtle margin/footnote callouts. | Clean section jump bar, reading progress line, zero distractions. |

## 3. Visual & typographic defaults

Starting points, not rules — override when the task's aesthetic calls for it. Fixed: numbers align, text stays legible in bright light, color carries meaning instead of decoration.

- Typography: Google Fonts with system fallbacks. Default pair: `Inter` or `Plus Jakarta Sans` for UI, `JetBrains Mono` for specs, quantities, part codes, shortcuts, data. `tabular-nums` / monospace for measurements, prices, capacities, counters.
- Surfaces: default to `1px` borders and subtle background contrast over heavy drop shadows; restrained radius (around `6px`–`10px`).
- Color: default to 1 background neutral, 1 card surface, 1 primary ink, 1–2 semantic accents (e.g. emerald = done, amber/red = warning or flagged).

## 4. Technical & interactive standards

1. Single file: Tailwind CDN (`<script src="https://cdn.tailwindcss.com"></script>`), custom CSS, and vanilla JS all inline in the one `.html`.
2. State: checklists, flags, notes, or toggles → persist in `localStorage` under a unique, versioned key, wrapped in `try/catch` so private browsing never breaks the script.
3. Micro-utilities:
   - Filters / search: more than 10 items → instant filter pills (e.g. `All`, `Remaining`, `Flagged`, `Done`) or a zero-latency search input.
   - Copy / export: button copies a clean plain-text summary (flagged parts, shopping list, selected commands). Use `navigator.clipboard.writeText`; missing or throws (file://, iframes) → `textarea` + `document.execCommand('copy')` fallback.
   - Feedback: never `alert()`, `confirm()`, or `prompt()`. Bottom toast for copy confirmations; inline two-step buttons (`Reset` → `Yes, Reset / Cancel`) for destructive actions.
4. Offline: Tailwind and fonts don't load offline → page renders unstyled but must stay readable and usable. Toggle visibility with the HTML `hidden` attribute or inline `style`, never Tailwind classes alone, so hidden confirm groups, empty states, and toasts stay hidden. Semantic HTML, system font fallbacks.

## 5. Pre-output checklist

- [ ] Critical specs/numbers visible in the first mobile viewport without scrolling.
- [ ] Interactive controls have mobile tap targets (`p-2.5` / `min-h-[44px]`); no horizontal page overflow.
- [ ] Content complete and tailored to the user's real-world scenario; no placeholder text.