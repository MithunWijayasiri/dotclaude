---
name: git-merge
description: Merge one branch (usually master) into the current branch while preserving local unstaged changes, resolving conflicts by understanding both sides, and catching silent semantic conflicts with the repo's own checks. Trigger on explicit `/git-merge`, or when the user asks to merge a branch/master into their current branch — especially when they want to keep local-only unstaged changes.
---

# Git Merge — Safe Branch Integration

Procedural workflow the main agent runs. Investigate before mutating; preserve the user's local-only unstaged changes; resolve conflicts by diagnosis not guessing; verify the merge passes the repo's existing checks before declaring done.

## Hard rules

- Read-only investigation first. `fetch`, then map state, before any `stash`/`merge`.
- Never auto-commit beyond the one merge the user authorized. `git commit`/`--amend` need explicit user approval — ask (amend / separate fixup / leave it).
- `git add`/`stash`/`merge` are mutating — explain, then run (user already asked to merge = authorization for the merge itself).
- Keep the user's local-only unstaged files OUT of any commit. Stage only merge-resolution files.
- Never push unless asked.
- Delegate read-only recon (steps 1–2) to a Haiku subagent; run `fetch`, conflict-reading, resolution, and every mutating step (`merge`/`add`/`commit`/`stash`) on the main model only.

## 1. Map state

**Fetch on the main model.** `git fetch` writes remote-tracking refs → mutating, so it never goes to the subagent. Fetch all of `origin`, not one branch: `git fetch origin <target>` refreshes `origin/<target>` only, leaving `origin/<current-branch>` stale — and step 1 compares against both.

```bash
git fetch origin          # both origin/<target> and origin/<current-branch>
```

**Then delegate the noise.** The rest of steps 1–2 is high-noise, low-judgment. Spawn a Haiku subagent (the `git-digest` agent, or `general-purpose` pinned to Haiku) to run the `status`/`log`/`diff --name-only` reads and return ONLY the structured facts: commits + files the target brings, overlap with unstaged/untracked, and ahead/behind own remote. The main model then reads only the conflict hunks (step 5). Never let the subagent run a mutating command.

```bash
git status                          # branch, unstaged, untracked, ahead/behind OWN remote
git log --oneline HEAD..origin/<target>      # commits target brings
git merge-base HEAD origin/<target>
git log --oneline HEAD..origin/<current-branch>   # is local behind its OWN remote?
```

Key discovery: **local branch may be behind its own remote**, and the remote may already contain a partial `Merged <target>` commit. If so, "merge properly" = two steps: sync local to `origin/<current-branch>` (fast-forward) first, then merge `origin/<target>`. Decide before touching the tree.

## 2. Check unstaged-file collision

User wants local unstaged changes kept → find whether the merge touches them.

Check **both** merges, not just the target one — when the branch is behind its own remote, step 4's `--ff-only` sync also rewrites the tree and can hit the same collisions.

```bash
git diff --name-only <merge-base> origin/<target>          # files the target merge brings
git diff --name-only HEAD origin/<current-branch>          # files the sync merge brings, if behind
git status --short --ignored                                # unstaged + untracked + IGNORED
```

⚠️ **`--ignored` is not optional.** Plain `git status --short` hides ignored files, and `merge` overwrites an ignored file **silently, exit 0, no warning** when the incoming side tracks that path. A local `.env` or config the user has ignored for months is destroyed with no message. Ignored paths belong in the collision list like any other.

- Overlap → those files block the merge / will conflict. Plan a stash.
- No overlap → merge proceeds without disturbing local edits; no stash needed.

⚠️ **Bash piped output can be truncated.** Do NOT trust a `--name-only` list as complete. Confirm against the actual merge attempt (it names every conflict), or re-run critical reads raw / via Read. A merge surfaced ~10 auto-merged files when `--name-only` showed only 3.

## 3. Confirm approach (when branch is stale vs its remote)

Hard-to-reverse + user's call. Ask: sync-then-merge (recommended, fully up to date, clean FF push) vs merge-into-stale-HEAD (diverges from remote → messy push). Note it creates one merge commit.

## 4. Preserve local unstaged changes

```bash
git rev-parse -q --verify refs/stash           # record: pre-existing stash, or empty
git stash push -m "local unstaged (merge)"     # tracked modified files only; untracked stay
git rev-parse -q --verify refs/stash           # changed → this workflow made a stash
git merge --ff-only --no-overwrite-ignore origin/<current-branch>   # sync step, if branch was behind
git merge --no-overwrite-ignore origin/<target> --no-edit
# ... resolve conflicts (step 5) ...
git commit -m "Merge remote-tracking branch 'origin/<target>' into <current-branch>" > commit.log 2>&1  # hook output to file; then check exit code + grep -iE 'error|fail' commit.log
git stash pop <recorded-stash-sha>             # ONLY if the push above created one
```

- **Stash first, then sync.** `merge --ff-only` also refuses to run when local edits overlap files the remote changed. Stash before either merge, not between them.
- **`git stash push` exits 0 even with nothing to stash** — it just prints `No local changes to save`. So a bare `git stash pop` later pops whatever is on top, which may be a stash the user made days ago. Record `refs/stash` before and after the push; pop by that SHA, and only when the push actually created it.
- **Short commit message — one line only.** `git commit --no-edit` after a conflicted merge auto-appends a `Conflicts:` file list → bloated message. Always commit with explicit `-m "Merge remote-tracking branch 'origin/<target>' into <current-branch>"`. Same applies to `--amend` (step 7): `git commit --amend -m "<same one-liner>"`, never `--amend --no-edit` (it keeps the bloated message).
- **Redirect the commit's pre-commit hook output.** A lint/typecheck pre-commit hook can dump tens of KB into context on `git commit`. Send it to a file (`> commit.log 2>&1`) — never `--no-verify`, the hook must still run — then surface only the exit code + `grep -iE 'error|fail' commit.log`. `git commit` only — `git stash pop` runs no hooks.
- Stash pop usually auto-merges shared files cleanly (3-way: stash base / merged file / local edits). If it re-conflicts, combine merged-target version + local tweaks. Its output is a restore/conflict listing — redirect it only if that listing is long.
- **`--no-overwrite-ignore` on both merges.** Untracked files abort a merge by default, but *ignored* files are overwritten silently — that flag makes git abort on those too. Verified: it works on `--ff-only` as well.
- Untracked files (a scratch dir, the Windows `nul` artifact) don't block merge — leave them. `git stash push` leaves them in place too.
- **Exception: colliding path.** If either merge adds a tracked file at a path where an untracked or ignored file already sits, it aborts (`untracked working tree files would be overwritten`) — the `--ff-only` sync included. Check both step-2 file lists against the `--ignored` status output; move the colliding ones aside (or `git stash push -u -- <path>`) before merging, restore after. Same handling either way. Leave every non-colliding file alone.

## 5. Resolve conflicts — diagnose, don't guess

Understand both sides before editing.

- **Most conflicts are additive** — both sides added different methods/fields/params adjacent to each other → **keep both**.
- Read the full file region (Read tool), not just the combined `diff --cc`. The combined diff hides shared context.
- Overlapping logic → combine faithfully. Example: keep HEAD's guard AND master's new conditional branch:
  ```ts
  if (!skipOptionalDetails) {
      await accordion.click();
      if (await returningUserNo.isVisible()) {   // master
          await returningUserNo.click();
      } else if (!skipTermsConsent) {            // HEAD guard preserved
          await consentYes.click();
      }
  }
  ```
- Both sides changed the SAME action → prefer the newer/more-robust pattern, for consistency with already-merged sibling blocks (e.g. master's `getByRole('radio')` over HEAD's `getByTestId('Yes')` when an already-merged sibling block uses the former).
- A parameterized method (HEAD) whose defaults reproduce master's plain version → keep the parameterized superset.

After each file: confirm no markers, verify referenced locators exist:
```bash
grep -rn "^<<<<<<<\|^=======\|^>>>>>>>" src
git diff --name-only --diff-filter=U          # unmerged still in index
```
Then `git add` resolved files to mark resolved.

## 6. Catch SILENT semantic conflicts — validate

Git merges files independently. A signature change in file A + a call in file B do NOT textually conflict but will NOT compile. **Always run the repo's OWN checks after resolving — and only those.** A merge must not introduce a toolchain the branch didn't have.

Find what already exists before running anything:

```bash
git show HEAD:package.json     # declared scripts: typecheck / lint / build / test
git ls-files | grep -iE 'tsconfig|eslint|biome|go\.mod|Cargo\.toml|pyproject'
```

- Declared script → run it (`npm run typecheck`, `npm run lint`). Repo's choice wins.
- No script but a tracked `tsconfig.json` → `npx --no-install tsc --noEmit -p tsconfig.json`. `--no-install` keeps it on the repo's own TypeScript; if that errors, TS isn't a dependency here → don't install one, skip.
- Not a TS repo → same rule with its own tooling (`go build ./...`, `cargo check`, `mypy`). Configured-only.
- Nothing configured → no static check available. Say that plainly and rely on step 5's marker/locator greps. Don't add tooling mid-merge.

Gotchas:

- An invalid `"ignoreDeprecations": "6.0"` in tsconfig makes TS 5.8 fail with TS5103. CLI `--ignoreDeprecations 5.0` overrides it — the flag wins over tsconfig.
- When a param was removed/renamed across the merge (`{ legacyFlag }` → `{ channel, addAddress }`): grep all CALLERS. If no caller exercised the old param's truthy path, the old default == new default → call with no arg. Don't invent a mapping.

## 7. Commit discipline

- The authorized merge commit must pass whatever step 6 found. If a check reveals a fix only AFTER committing, ask the user: amend merge commit / separate fixup commit / leave unstaged for them.
- Amend = stage ONLY the fix file (local-only unstaged files stay out); use the explicit one-line `-m` from step 4, never `--amend --no-edit`.

## 8. Pre-push verification

```bash
git merge-base --is-ancestor origin/<current-branch> HEAD && echo "FF-safe"   # clean push, no force
git log --oneline origin/<current-branch>..HEAD                                # what will push
git diff --cached --name-only                                                  # should be empty
```

Confirm: fast-forward push, no conflict markers, nothing wrongly staged, step-6 checks clean. Local-only unstaged changes are not committed → won't push. Don't run `git push` — tell the user the command.

## 9. Cleanup

Remove any scratch files created during investigation (e.g. a temp `git show > file` used to read a pre-merge version — Read can't open `/tmp` on Windows).

## Extra: fix an already-pushed merge message

Only when the bad message was already pushed (not the normal flow). Rewrites published history → confirm with user first.

```bash
git rev-parse HEAD origin/<current-branch>   # equal → remote hasn't moved, safe
git commit --amend -m "Merge remote-tracking branch 'origin/<target>' into <current-branch>"
git push --force-with-lease origin <current-branch>   # NOT --force; lease aborts if a teammate pushed
```

Amending a merge commit preserves both parents. A teammate who already pulled must reset their local copy.
