---
name: orchestrate
description: Use when a large mechanical multi-file change — sweep, rename, translation, build/fix loop — should run in stages. Handles survey, per-stage briefs, diff review, and a commit per stage.
argument-hint: "Task or plan file to execute (optional: defaults to current task)"
disable-model-invocation: true
---

Main session = planner + reviewer. Sonnet subagents = workers. Goal: token-heavy edits (file sweeps, renames, translations, build/test loops) run on the cheaper model and stay out of main context; main spends tokens only on survey, briefs, and review.

## Pays off vs. not

- Pays: mechanical or repetitive edits across many files, long build/fix loops, work whose raw output (diffs, logs) main never needs to read.
- Doesn't: a handful of tool calls (round-trip + brief cost more than doing it), work needing many judgment calls the user must make, stages that can't be specified precisely. Say so and do it inline instead.

## 1. Survey + align (main)

- Read the plan/task, repo rules (CLAUDE.md), and grep the scope: hit counts per pattern, files per area, exact line numbers of non-mechanical spots. Precise briefs depend on this; vague briefs → wrong work.
- Working tree or index not clean (`git status --short` non-empty) → stop until the user commits or stashes; review needs a diff that holds only the stage.
- Collect open decisions → ask user (recommended option first). Ask once, upfront: "commit each stage after review + green build?" Declined → pause after each green stage until the user commits. Push/PR = separate ask, always.
- Create branch (repo convention) before any agent runs.

## 2. Split into stages

- One stage = one reviewable commit, at most one rename pair (e.g. rename structure → content/strings → second rename).
- Stages touching the same files → sequential. Disjoint files within one stage → parallel agents in one message; still one review, one commit.
- Each stage leaves the build green.

## 3. Brief (one Agent call per stage)

`Agent(model: "sonnet", subagent_type: "general-purpose")`. Brief is the worker's only context:

- Repo path, branch, what earlier stages already did, "read CLAUDE.md first" + its hard rules (warnings-as-errors, encoding/BOM/line endings, style).
- Goal in one line + "Do" list: exact paths, line numbers, literal before → after strings.
- "Do NOT touch" list: files/names reserved for later stages or out of scope.
- File moves via `git mv`; delete nothing except build outputs.
- Verify commands to run and fix until green (build, test, format check), with expected warning/test counts.
- Final grep for old names; list every remaining hit with a one-word reason.
- Never commit, push, or branch. Ambiguity → minimal option + list under "Uncertain".
- Report: short, no raw diffs. Grouped changes, counts, verify results, remaining-grep list, Uncertain.

## 4. Review (main) — never trust the report

Worker's own grep only checks old names → misses mangled new names (e.g. every `fetchUser` became `fetchUserUser`, worker reported clean).

- Worker not green or no report → don't review; send it back once, then stop and tell the user.
- Stage the stage's paths only (`git status --short` lists them; never `git add -A` — it sweeps in unrelated files), then `git diff --cached -M --stat | tail -1`.
- Residual filter — print only lines a plain rename doesn't explain. `OLD`/`NEW` = the stage's rename pair; renames removed lines only, so mangled and reversed names still show. `OLD` is a sed regex → escape `.`, `[`, `*` (`a\.b`):
  ```bash
  git diff --cached -M -U0 | grep "^[+-]" | grep -v "^+++\|^---" \
    | sed '/^-/s/OLD/NEW/g' \
    | awk '{s=substr($0,1,1); l=substr($0,2); if(s=="+")c[l]++; else c[l]--} END{for(k in c) if(c[k]!=0) print c[k], k}'
  ```
  Read every residual line.
- Content stages (strings, translations) → read changed value lines only, e.g. `git diff --cached -U0 -- 'locales/*.json' | grep '^[+-] *"'`.
- Other stages (build/fix loops, no rename pair) → read the whole staged diff (`git diff --cached`).
- Mangle check: grep new name glued to extra letters, e.g. `grep -rnE "[A-Za-z]NEW|NEW[A-Za-z]"`, and odd variants (doubled prefix, wrong case).
- Check the worker's Uncertain list item by item.
- Small fix → edit inline, re-stage, re-run the filter. Larger → `SendMessage` to same agent with the exact problem (keeps its context).
- Run build + test + format yourself, quiet output (grep summary lines). Green → commit (if approved) with Conventional Commit subject → next stage. Red → no commit, no next stage; fix or send back.

## 5. Report

- Table: commit SHA + one-line what.
- Subagent tokens per stage (from task notifications) + bugs caught in review.
- Manual test list (UI, external integrations) the agents couldn't run.
