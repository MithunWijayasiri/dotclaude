---
name: git-merge
description: Merge one branch (usually master) into the current branch while preserving local unstaged changes, resolving conflicts by understanding both sides, and catching silent semantic conflicts with the repo's own checks. Trigger on explicit `/git-merge`, or when the user asks to merge a branch/master into their current branch — especially when they want to keep local-only unstaged changes.
---

# Git Merge — Safe Branch Integration

Workflow the main agent runs. Investigate before mutating; preserve local-only unstaged changes; resolve conflicts by diagnosis; verify with the repo's own checks before done.

Scripts in this skill's `scripts/` folder (bash, run with cwd = repo root, as `bash <skill-dir>/scripts/<name>.sh`) do the mechanical steps and print compact digests. Below, `scripts/` means that folder.

## Hard rules

- Read-only investigation first. `merge-recon.sh` (fetch + map state) before any `stash`/`merge`.
- Never auto-commit beyond the one merge the user authorized. `git commit`/`--amend` need explicit user approval — ask (amend / separate fixup / leave it).
- `git add`/`stash`/`merge` are mutating — explain, then run (user already asked to merge = authorization for the merge itself).
- Keep the user's local-only unstaged files OUT of any commit. Stage only merge-resolution files.
- Never push unless asked.
- Never install tooling mid-merge. Run only checks the repo already has.

## 1. Recon

```bash
bash scripts/merge-recon.sh <target>   # default target: master; current branch from HEAD
```

Runs `git fetch origin` (all of origin, not one branch: `fetch origin <target>` leaves `origin/<current-branch>` outdated, and recon compares both), then prints one digest: target commits + merge-base, ahead/behind OWN remote (+ partial remote merge), files both merges bring, local unstaged/untracked/ignored, COLLISIONS. Dies on merge/rebase in progress, unmerged paths, detached HEAD, missing `origin/<target>`.

Why:
- **Local branch may be behind its own remote**, remote may already hold a partial `Merged <target>` commit → "merge properly" = two steps: sync (`--ff-only`) to `origin/<current-branch>`, then merge `origin/<target>`. Decide before touching tree.
- **Ignored files matter.** Plain `git status` hides them; `merge` overwrites an ignored file **silently, exit 0** when incoming side tracks that path (local `.env`/config lost). Script uses `--ignored`.
- **Both merges checked.** `--ff-only` sync rewrites tree too → same collisions.
- COLLISIONS: modified → stash (step 3); untracked → merge aborts, move aside; ignored → silent overwrite, move aside. None → no stash needed.
- Lists are capped (`+N more`), counts exact. Merge attempt names every conflict; trust it over lists.

## 2. Confirm approach (when branch is behind its remote)

Hard-to-reverse + user's call. Ask: sync-then-merge (recommended, fully up to date, clean FF push) vs merge-into-outdated-HEAD (diverges from remote → messy push). Note it creates one merge commit.

Recon says DIVERGED (behind and ahead) → `--ff-only` sync fails. Ask instead: rebase local-only commits onto `origin/<current-branch>` (linear, rewrites unpushed commits only) vs merge `origin/<current-branch>` first (extra merge commit). Then merge target.

## 3. Preserve local unstaged changes

```bash
bash scripts/merge-stash.sh push                    # records new stash SHA only if this call created one
git merge --ff-only --no-overwrite-ignore origin/<current-branch>   # sync step, if branch was behind
git merge --no-ff --no-commit --no-overwrite-ignore origin/<target>   # always stops before commit, even when clean or FF-able
# ... resolve conflicts (step 4), verify (step 5) ...
git commit -m "Merge remote-tracking branch 'origin/<target>' into <current-branch>" > commit.log 2>&1  # hook output to file; then check exit code + grep -iE 'error|fail' commit.log
bash scripts/merge-stash.sh pop                     # pops recorded SHA; no-op if push created none
```

- **Nothing to merge** → recon `TARGET COMMITS: 0` (or `still missing after sync: 0`, after sync) means `origin/<target>` already in HEAD; `git merge` prints `Already up to date.`, leaves nothing to commit. Skip merge + commit, go straight to stash pop.
- **Stash first, then sync.** `merge --ff-only` also refuses to run when local edits overlap files the remote changed. Stash before either merge, not between them.
- **`git stash push` exits 0 with nothing to stash**, so bare `git stash pop` pops whatever is on top (maybe a days-old user stash). `merge-stash.sh` compares `refs/stash` before/after, pops by SHA only if it created the stash. Pop conflict → git keeps the stash; script prints ref; resolve, then `git stash drop <ref>`.
- **Short commit message — one line only.** `git commit --no-edit` after a conflicted merge auto-appends a `Conflicts:` file list → bloated message. Always commit with explicit `-m "Merge remote-tracking branch 'origin/<target>' into <current-branch>"`. Same for `--amend` (step 6): `git commit --amend -m "<same one-liner>"`, never `--amend --no-edit` (keeps bloated message).
- **Redirect pre-commit hook output.** Lint/typecheck hook can dump tens of KB on `git commit`. Send to file (`> commit.log 2>&1`); never `--no-verify`, hook must run; surface only exit code + `grep -iE 'error|fail' commit.log`. `git commit` only; `git stash pop` runs no hooks.
- Stash pop usually auto-merges shared files cleanly (3-way: stash base / merged file / local edits). Re-conflict → combine merged-target version + local tweaks.
- **`--no-overwrite-ignore` on both merges.** Untracked files abort a merge by default; *ignored* files are overwritten silently. Flag makes git abort on those too — verified on `--ff-only`; NOT on a true merge with git 2.54 (default `ort` strategy overwrote silently). Treat it as a backstop only: move every recon-reported ignored collision aside before merging.
- Non-colliding untracked files (scratch dir, local notes, Windows `nul` artifact) don't block merge; leave them. `git stash push` leaves them too.
- **Colliding path** (recon COLLISIONS, untracked/ignored): either merge adding a tracked file where an untracked/ignored file sits aborts (`untracked working tree files would be overwritten`), `--ff-only` sync included. Move colliding ones aside (or `git stash push -u -- <path>`) before merging. Never restore over the path after: it now holds the tracked version. Diff moved copy vs tracked, ask user how to reconcile (local secrets must not land in the tracked file). Leave every non-colliding file alone.

## 4. Resolve conflicts — diagnose, don't guess

Understand both sides before editing.

- **Most conflicts additive** — both sides added different methods/fields/params adjacent → **keep both**.
- Read full file region (Read tool), not just combined `diff --cc`; it hides shared context.
- Overlapping logic → combine faithfully (keep both guards/branches).
- Both sides changed SAME action → prefer newer/more-robust pattern, consistent with already-merged sibling blocks.
- Parameterized method (HEAD) whose defaults reproduce target's plain version → keep parameterized superset.
- Examples + removed/renamed-param caller handling: `references/conflict-resolution.md` (load on demand).

After each file, `git add` it to mark resolved. Final marker/unmerged check is in step 5.

## 5. Catch SILENT semantic conflicts — verify

Git merges files independently. Signature change in file A + call in file B do NOT textually conflict but will NOT compile. **Always run the repo's OWN checks after resolving — and only those.** A merge must not introduce a toolchain the branch didn't have.

Find what already exists before running anything:

```bash
git show HEAD:package.json     # declared scripts: typecheck / lint / build / test
git ls-files | grep -iE 'tsconfig|eslint|biome|go\.mod|Cargo\.toml|pyproject'
```

- Declared script → use it (`npm run typecheck`, `npm run lint`). Repo's choice wins.
- No script but a tracked `tsconfig.json` → `npx --no-install tsc --noEmit -p tsconfig.json`. `--no-install` keeps it on the repo's own TypeScript; if that errors, TS isn't a dependency here → don't install one, skip.
- Not a TS repo → same rule with its own tooling (`go build ./...`, `cargo check`, `mypy`). Configured-only.
- Nothing configured → no static check available. Say that plainly and rely on the marker/unmerged checks. Don't add tooling mid-merge.

Pass the chosen command to the verify script:

```bash
bash scripts/merge-verify.sh -- npm run typecheck   # or no `--` part when nothing is configured
```

Prints: conflict markers (tracked, non-binary), unmerged files, check exit code + first 20 error lines (command runs from repo root, output redirected to a temp file), pre-push checks, final `PASS`/`FAIL: reasons`. Mid-merge (before commit) push checks are skipped; staged resolution files expected.

- Param removed/renamed across merge: grep all CALLERS; don't invent a mapping (see `references/conflict-resolution.md`).

## 6. Commit discipline

- Authorized merge commit must pass whatever step 5 found. Check reveals a fix only AFTER committing → ask user: amend merge commit / separate fixup commit / leave unstaged.
- Amend = stage ONLY the fix file (local-only unstaged files stay out); explicit one-line `-m` from step 3, never `--amend --no-edit`.

## 7. Pre-push verification

After the commit, run `bash scripts/merge-verify.sh [-- <check command>]` again. `PASS` = no conflict markers, check clean, FF-safe (`origin/<current-branch>` ancestor of HEAD; clean push, no force), nothing staged. Local-only unstaged changes are not committed → won't push. Don't run `git push`; tell user the command.

## 8. Cleanup

Remove scratch files from investigation (e.g. `commit.log`, temp `git show > file`; Read can't open `/tmp` on Windows).

## Extra

Fix an already-pushed merge message (rewrites published history, confirm first): `references/fix-pushed-merge-message.md`.
