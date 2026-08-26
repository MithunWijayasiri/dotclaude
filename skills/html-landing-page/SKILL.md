---
name: html-landing-page
description: Design distinctive static landing pages — single/few-file HTML/CSS/JS (project sites, GitHub Pages, product one-pagers). Trigger when creating, redesigning, or reviewing a landing page. Not for app UIs, dashboards, or framework SPAs.
---

# HTML Landing Page

Goal: a page that could not be mistaken for anyone else's. Every design decision derives from the subject — no house style. The enemy is the "AI-default look" (see Banned defaults).

## Process — plan before code, always

1. **Ground.** Name the subject, its audience, and the page's single job (usually one action). Mine the project's real material first: files, structure, vernacular, concrete numbers. The subject's own world is where distinctive choices come from.
   - Example: Cleanfox is literally a patch applied to Betterfox → hero = animated diff in an editor window; sections named after the file's own comment banners.
2. **Plan.** Write a short design plan before any HTML:
   - Palette: 4–6 named hex values.
   - Type: display + body (+ mono if code appears), each a deliberate pick. Google Fonts allowed.
   - Layout: one-sentence concept + ASCII sketch.
   - Signature: the ONE element the page will be remembered by. Must embody something true about the subject.
3. **Self-check.** Would this plan come out for any similar brief? If any part matches Banned defaults or feels interchangeable → revise that part before coding.
4. **Build.** Follow the plan exactly; derive every color/type value from it.
5. **Critique.** Reread as a design lead: remove one accessory (Chanel). Verify every factual claim in the copy against the project — never ship a plausible-but-false line.

## Banned defaults

The three looks AI design clusters around — never spend a free axis on them:

- Warm cream bg (~#F4F1EA) + high-contrast serif display + terracotta accent.
- Near-black bg + single acid-green or vermilion accent + hairline rules.
- Broadsheet: hairline rules, zero border-radius, dense newspaper columns.

Common tells to avoid:

- Numbered 01/02/03 markers when content isn't a real sequence. Numbers only for actual order (install steps qualify).
- Hero = big number + small label + supporting stats + gradient accent.
- Purple-blue gradients, gradient text, glassmorphism cards.
- Emoji as feature icons. Decorative ✨/🚀 anywhere.
- Scattered scroll animations on everything.
- Same layout every time: centered hero → 3 feature cards → CTA band.

## Design rules

- **Hero is a thesis.** Open with the most characteristic artifact of the subject — a live demo, a diff, a file, an interactive moment — not a template headline block.
- **Typography carries personality.** The display face is a memorable choice, used with restraint. If the subject is code, mono is a first-class citizen, not decoration.
- **Structure is information.** Eyebrows, dividers, labels, section names must encode something true about the content (e.g. section names taken from the actual file), never decorate.
- **Spend boldness in one place.** The signature element is the one loud thing; everything around it stays quiet and disciplined. Not taking a risk is also a risk — take exactly one, justifiable.
- **Contrast as concept.** A page can encode an idea in its surfaces (e.g. clean light page, dark code objects = "the page is clean; the file is the machine").

## Motion

- One orchestrated load moment (hero sequence) + quiet hover micro-interactions. That's the default budget.
- Scroll reveals allowed but subtle; never on every element.
- Micro-interactions should teach, not decorate (hover-to-uncomment teaches how the file works).
- Always: `@media (prefers-reduced-motion: no-preference)` wraps all motion; no-JS/no-IO fallback shows everything.

## Copy

Copy is half of why pages read as AI-made.

- Specific > clever. Real numbers, names, and pref/file/command strings from the project ("3 defaults relaxed", "17 telemetry prefs off").
- Buttons say exactly what happens: "Download user.js", not "Get started".
- Banned slop: Unleash, Elevate, Seamless, Effortless, Supercharge, Empower, Revolutionize, "Built for the modern web".
- Active voice, user-side naming (what people control, not how the system is built).
- Verify every claim against the source before shipping. Wrong-but-nice copy gets cut.

## Quality floor (build silently, never announce)

- Responsive to mobile; wide code/tables scroll in own `overflow-x: auto` container, body never scrolls horizontally.
- Visible `:focus-visible` styles; semantic HTML; `aria-label` on figure-like code blocks.
- Favicon (inline SVG/emoji data URI) + `<title>` + meta description + og tags.
- Watch CSS specificity — section/element selectors cancelling each other's spacing is a classic self-inflicted bug.
- Assets: Google Fonts OK; everything else self-contained (inline SVG, data URIs, no icon/JS CDNs).
