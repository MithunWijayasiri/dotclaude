---
name: svg-craft
description: Use when creating, redesigning, or polishing SVG art — scenes, abstract backdrops, illustrations, animated SVG. Handles depth layering, lighting, placement, and smooth seamless CSS motion. Not for charts → `dataviz`; not for icons-only tweaks.
---

# SVG Craft

Turn flat or empty SVG into art with depth and fluid motion. Process: source → baseline render → classify kind (polish keeps it) → diagnose → layer → sanity-check plausibility → place → animate → verify by render.

## Kind — scene or abstract

Classify from the baseline render, not the file or theme name:

- Scene: depicts a subject — sky, landscape, keyboard, map, objects.
- Abstract: gradients, glows, shapes, patterns; no subject.

Polish keeps the kind. Abstract never gains subjects (coals, sparks, horizons, objects) — a name like "Ember" is not a brief. Unclear → ask.

## Creative freedom

The brief sets the goal, not every detail. Go beyond the literal ask when it serves the scene: add elements, effects, or motion that make it richer (e.g. lensed starlight round a black hole, glints on a few bright stars), as long as they stay within the art's kind and pass §5.

Several strong directions and the choice changes the result (concept, mood, composition, palette shift, what gets added) → ask the user before building: 2–4 concrete suggestions, each a short description of what they'd see, recommended one first with why. Abstract → options vary colour, light, texture, composition; never subject. Small choices inside an agreed direction → decide, mention in the final reply.

## 1. Find the real source

- Generated SVG (built by a script/TS function) → edit the generator, re-run it. Never hand-edit output; drift checks or the next regen wipe it.
- Read the project's constraints before designing: size cap, banned elements (`<script>`, `<image>`, external `url()`, `data:`), reduced-motion rule, min animation cycle, light/dark handling, tests that parse the SVG.
- Procedural content → seeded RNG, so output is identical every build (changed source can force re-renders/flashes in hosts).

## 2. Baseline render — look before changing

Never judge SVG from source. Screenshot it and Read the PNG:

```bash
# Windows (Git Bash): screenshot path in Windows form
"/c/Program Files/Google/Chrome/Application/chrome.exe" --headless=new --disable-gpu --hide-scrollbars \
  --window-size=1600,1000 --screenshot="<scratchpad-win-path>\\before.png" "file:///C:/path/to/art.svg"

# macOS
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --hide-scrollbars \
  --window-size=1600,1000 --screenshot="<scratchpad>/before.png" "file:///path/to/art.svg"

# Linux: google-chrome, google-chrome-stable, chromium or chromium-browser (whichever exists)
google-chrome --headless=new --disable-gpu --hide-scrollbars \
  --window-size=1600,1000 --screenshot="<scratchpad>/before.png" "file:///path/to/art.svg"

# later frame of the animation: add --virtual-time-budget=25000
```

Window size = the viewBox aspect; also try narrow/wide sizes when `preserveAspectRatio` is `slice`.

## 3. Diagnose

| Symptom | Usual cause | Fix |
|---|---|---|
| Flat | one layer, uniform opacity, no light falloff | back→front layers, glow under crisp edges, rim light |
| Empty | big dead areas | background tiers (faint dust → stars → accents → small hero objects) |
| Grey / washed out | low-saturation colour (cream/white) at partial opacity over black | warmer/more saturated stops; check what each gradient stop lands on |
| Wrong colour on a squashed shape | radial gradient measured in round space on a flattened ellipse | `gradientTransform="scale(1 <ry/rx>)"` so stops follow the shape's own radius |
| Hard edges / "scratches" | thin strokes with no falloff, too long, too opaque | shorter, fainter, round caps, fade by distance |

## 4. Depth layering — scenes (back → front)

1. Background fill/gradient.
2. Far sky: many tiny faint dots, varied opacity; mix tints (mostly warm/neutral white, few cool `#e6ecff`, few warm `#ffdcae`).
3. Mid objects: small hero shapes (galaxies, clouds) — radial-gradient halo + bright core + detail (spiral arms = log-spiral polyline, wide faint stroke + thin brighter stroke + dots along it).
4. Focal object back half (hidden where the front/halo covers it via a soft radial mask).
5. Focal glow/halo — large blurred stroke or radial gradient; asymmetric brightness (one side lit) reads as 3D.
6. Focal solid shape — crisp edge, faint rim gradient just inside the edge.
7. Edge definition — thin crisp line + same line wider and blurred beneath (glow) + faint outer echo line.
8. Focal front half / foreground — drawn last so it passes over the solid shape.

Few bright accents only (e.g. 4 glint stars with a 4-point cross) — everything bright = nothing bright.

### Abstract polish

Rework what's there; add no new kinds of shape.

- Colour: richer gradient stops, deeper darks to brighter highlights, slight hue shift across the field.
- Light falloff: soft edges (blur, radial masks), one brighter zone, the rest quieter.
- Texture: faint grain via `feTurbulence`, low opacity.
- Rhythm: vary size, spacing, opacity of existing shapes.
- Balance: highlights where nothing covers them.

## 5. Plausibility — the scene must make sense

Abstract → coherence only: one palette, one light direction, consistent rhythm. The rest of this section is for scenes.

Every element obeys the scene's own logic; one wrong element breaks the illusion more than a missing one. Ask per element: where is it, how far, what lights it, what covers it?

- Depth order: far things never draw over near or opaque things. A glowing star on top of black-hole rings reads as a speck on the glass, not space behind it → keep it off, or behind and hidden.
- Brightness follows distance: background stays fainter than the focal object; nothing in the far layer outshines the hero.
- Scale follows distance: distant galaxies small; nothing in the background rivals the hero's size.
- One light logic: glows, rims, and lit sides agree on where light comes from (the hot source, or one direction).
- Motion follows physics/story: orbiting parts turn the same way, inner faster than outer; background drifts slower than foreground (parallax); nothing jitters or reverses without reason.
- Palette cohesive: accents come from the scene's palette; a foreign hue needs a reason (e.g. faint cool star tints for contrast against a warm hero).
- Effects belong to their source: lensing arcs, glare, halos sit around the object causing them, not floating free.

## 6. Placement — nothing overlaps the focal object

Enforces the depth rule above in code.

- Write `clear(x, y, pad)`: false inside the focal object's full extent (glow, halo, any tilted band — transform the point into the band's local frame to test it).
- Random items → rejection sampling with `pad` = item radius + its drift amplitude; cap tries, `throw` when no spot found.
- Hand-placed items → assert `clear()` at build time and `throw` with the coordinates. Fail fast beats a silently overlapping object.
- With `slice` cropping, keep important items away from the cropped edges.

## 7. Motion — fluid, seamless

| Motion | Timing | Why |
|---|---|---|
| Rotation, flowing dashes | `linear infinite` | constant speed; any easing visibly pulses each loop |
| Pulse, twinkle, breathe, sway | `cubic-bezier(.37,0,.63,1) infinite alternate`, keyframes `from`/`to` only | sine-like swing, zero velocity only at ends, no snap back to start |
| Drift / float | nested `<g>`: outer X, inner Y, each alternate + sine, different periods (Y ≈ 0.7–0.95 × X) | Lissajous path that never stops or repeats visibly |

- Dash flow seamless: animate `stroke-dashoffset` by an exact multiple of the dash period (`--p:-<period*4>px`, `@keyframes flow{to{stroke-dashoffset:var(--p)}}`).
- Per-item amplitude via custom property: `@keyframes dx{from{transform:translateX(calc(var(--a) * -1))}to{transform:translateX(var(--a))}}`, `style="--a:14px"`.
- Desync with negative `animation-delay` (`-rnd*period`), so it starts mid-motion with no visible start.
- Slow is calm: drifts 40–70s, galaxy spin 260–460s, halo spin 60–150s, twinkle 2.5–6.5s.
- Base (non-animated) state must look right — reduced motion (`@media (prefers-reduced-motion: reduce){*{animation:none!important}}`) shows it.
- No cycle under 1/3s (WCAG 2.3.1 flashing).

## 8. Gotchas

- CSS `transform` animation replaces the element's `transform` attribute → put static translate/rotate/scale on a parent `<g>`, animate a child.
- `transform-origin`: root-space spin → `transform-origin:<cx>px <cy>px`; inside a translated group → `transform-origin:0 0`.
- Shorthand per class: `.dx,.dy{animation:dx 50s … }.dy{animation-name:dy}` — a lone `.dy{animation-name:dy}` has no duration.
- Filter region defaults to bbox ±10% of geometry (stroke excluded) → thin wide shapes (flat arcs) get blur clipped. Give that filter a tall region (`y="-300%" height="700%"`).
- Masks/gradients with `userSpaceOnUse` resolve in the referencing element's local coords — inside a `translate(...) rotate(...)` group, centre is `0,0`.
- Half-ellipse arcs: front `M rx 0 A rx ry 0 0 1 -rx 0`, back `M -rx 0 A rx ry 0 0 1 rx 0` (y-down, sweep 1 = clockwise).
- Performance: animated elements under filters re-blur every frame. Small moving things → radial gradients, not blur. Keep blurred animated areas few and slow.
- Light theme: hide night-sky layers (`display:none` on one wrapping group) rather than recolouring each.

## 9. Verify

- Re-render, Read the PNG, compare to baseline; also a later frame (`--virtual-time-budget`). Check: kind unchanged, no overlaps, no clipped glows, no grey bands, focal object reads first, every element passes §5 (depth, brightness, scale, light, motion make sense).
- Check output size against any cap.
- Update mirrors of the art (alt text, captions, previews) when the description changes.
