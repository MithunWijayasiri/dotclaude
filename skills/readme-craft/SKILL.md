---
name: readme-craft
description: README writing and restyling — scaffold a new README, restyle an existing one, or add/refresh its badges (shieldcn.dev or shields.io), header, admonitions, collapsibles, and GitHub markdown patterns.
---

# README craft

Two modes: **new** (scaffold from scratch) and **restyle** (upgrade an existing README's presentation). Same conventions either way.

## Step 1 — ask badge source

Before writing or touching any badge, ask via AskUserQuestion: **shieldcn.dev** or **shields.io**. Never default, never infer from existing badges, never mix sources in one README. Skip only if the user already named the source in this request.

Chosen source can't render a needed badge → tell user and drop it; don't silently fall back to the other source.

Markdown patterns beyond header/badges (admonitions, collapsibles, kbd, mermaid, diff, tables, footnotes, task lists, captions, back-to-top) → `references/markdown-patterns.md`. Read it before writing README body content.

## Header pattern

Centered icon above the title, tagline below:

```html
<p align="center">
  <img src="<path-to-icon>" width="64" height="64" alt="">
</p>

<h1 align="center">Project Name</h1>

<p align="center">
  One-line description.
</p>
```

Icon: prefer an existing favicon/app-icon asset (PNG/ICO). GitHub strips inline `<svg>` from rendered READMEs, so even if a `.svg` logo exists, reference it via `<img>` (rendered as a raster preview by GitHub) or use a PNG/ICO sibling if one exists. Look in `docs/assets/`, `public/`, `assets/`, or repo root; ask the user for a path if nothing obvious is found — don't guess a project's icon. Separate dark/light icon assets → themed logo pattern in `references/markdown-patterns.md`.

## Badges

Every badge: live or meaningful signal + `<a href>` to the page it represents (stargazers, npm page, workflow runs, `LICENSE`, funding page). No bare decorative badges.

### shieldcn.dev

Base `https://shieldcn.dev`. Wrap every badge in `<picture>` with dark `<source>` + light `<img>` fallback:

```html
<a href="<link-target>"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/<path>.svg?mode=dark"><img alt="<Label>" src="https://shieldcn.dev/<path>.svg?mode=light"></picture></a>
```

| Badge | Path |
|:--|:--|
| Stars | `github/<owner>/<repo>/stars` |
| Release | `github/<owner>/<repo>/release` |
| License | `github/<owner>/<repo>/license` |
| Last commit | `github/last-commit/<owner>/<repo>` |
| Contributors | `github/contributors/<owner>/<repo>` |
| Release downloads | `github/downloads/<owner>/<repo>` |
| npm version | `npm/<pkg>` |
| npm downloads (weekly / monthly) | `npm/<pkg>/downloads` / `npm/dm/<pkg>` |
| Homebrew | `homebrew/<formula>` |
| Discord members | `discord/members/<inviteCode>` |
| Static | `badge/<Label>-<value>-<hex>` |

Useful params: `variant` (`default`/`secondary`/`outline`/`ghost`/`branded`), `size` (`xs`/`sm`/`default`/`lg`), `logo`, `color`. Keep params identical across all badges in a README. Full reference: https://shieldcn.dev/docs/api-reference — check there for any path not in the table; don't guess one.

### shields.io

No dark/light wrapping:

```html
<a href="<link-target>"><img src="https://img.shields.io/<path>" alt="<Label>"></a>
```

CI: `github/actions/workflow/status/<owner>/<repo>/<file>.yml` — targets the real workflow file instead of guessing.

### Never add (both sources)

- **Vanity** — view/visitor counters (incl. shieldcn `views/*`), followers, X/Twitter follow, repo size, "PRs welcome", "maintained: yes", "made with love", novelty badges (NBA, Tokscale, flags).
- **Redundant** — info already stated elsewhere in the README or another badge: license badge when a License section exists, version badge when version is in the title/install command, two download badges for the same package, stars badge next to a stars chart.

Static tech-stack badges ("TypeScript", "React") are allowed — one row max, only for the project's core stack.

Metric structurally near-zero for this project (dependents on a leaf app, downloads on an unpublished package) → ask before including.

### Verify

Check every metric badge once before shipping — swap `.svg` for `.json` (both sources support it) and confirm the value and link are real. shieldcn `ci` picks a workflow itself → confirm its `link` points at the intended workflow; wrong one → use a static badge or drop it.

### Grouping / ordering

Rows by category, each inside one `<p align="center">`, rows separated by `<br>`:

1. **Social proof** — stars, contributors, last commit, CI
2. **Package registry** — version, downloads, license
3. **Stack** — static tech-stack badges
4. **Funding / links** — sponsor (Ko-fi / GitHub Sponsors / Open Collective), homepage, Discord

Empty category → drop the row.

## New README checklist (scaffold mode)

Ask before writing if any of these are unclear — don't guess a project's identity or scope:

1. Project name, one-line tagline, icon asset path.
2. Install method(s) — pick the one true "recommended" path; alternates go in a collapsible.
3. Badge set — which badges from the chosen source actually apply after the Never-add filter; whether the project publishes to a package registry (gates that row).
4. Core sections: What it does → Install → Usage/Config → How it works → FAQ → Support/Credits/License. Drop sections that don't apply; don't pad to match a template.

## Restyle checklist (existing README)

1. Convert every existing badge to the chosen source — existing mixed sources don't carry over.
2. Drop every badge hit by Never-add; list dropped badges in the final response so the user can object.
3. Check every badge's `<a href>` still points somewhere real; verify metrics per Verify.
4. Look for prose that should become an admonition, `<details>`, table, or diagram (`references/markdown-patterns.md`).
5. Confirm the header follows the icon+heading pattern if the project has a natural icon asset.

## Note

This skill file follows compact-markdown style (telegraphic, AI-facing). The README it produces does **not** — write normal human-facing prose there; this file's terseness doesn't carry over to the output.
