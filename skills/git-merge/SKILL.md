---
name: git-merge
description: Merge one branch (usually master) into the current branch while preserving local unstaged changes, resolving conflicts by understanding both sides, and catching silent semantic conflicts via typecheck. Trigger on explicit `/git-merge`, or when the user asks to merge a branch/master into their current branch — especially when they want to keep local-only unstaged changes.
---

# Git Merge — Safe Branch Integration

Procedural workflow the main agent runs. Investigate before mutating; preserve the user's local-only unstaged changes; resolve conflicts by diagnosis not guessing; verify the merge compiles before declaring done.

## Hard rules

- Read-only investigation first. No `fetch` → no `stash`/`merge` until state is mapped.
- Never auto-commit beyond the one merge the user authorized. `git commit`/`--amend` need explicit user approval — ask (amend / separate fixup / leave it).
- `git add`/`stash`/`merge` are mutating — explain, then run (user already asked to merge = authorization for the merge itself).
- Keep the user's local-only unstaged files OUT of any commit. Stage only merge-resolution files.
- Never push unless asked.
- Delegate read-only recon (steps 1–2) to a Haiku subagent; run conflict-reading, resolution, and every mutating step (`merge`/`add`/`commit`/`stash`) on the main model only.

## 1. Map state (read-only)

**Delegate the noise.** Steps 1–2 are high-noise, low-judgment. Spawn a Haiku subagent (the `git-digest` agent, or `general-purpose` pinned to Haiku) to run the `fetch`/`status`/`log`/`diff --name-only` recon and return ONLY the structured facts: commits + files the target brings, overlap with unstaged/untracked, and ahead/behind own remote. The main model then reads only the conflict hunks (step 5). Never let the subagent run a mutating command.

```bash
git fetch origin <target>          # e.g. master
git status                          # branch, unstaged, untracked, ahead/behind OWN remote
git log --oneline HEAD..origin/<target>      # commits target brings
git merge-base HEAD origin/<target>
git log --oneline HEAD..origin/<current-branch>   # is local behind its OWN remote?
```

Key discovery: **local branch may be behind its own remote**, and the remote may already contain a partial `Merged <target>` commit. If so, "merge properly" = two steps: sync local to `origin/<current-branch>` (fast-forward) first, then merge `origin/<target>`. Decide before touching the tree.

## 2. Check unstaged-file collision

User wants local unstaged changes kept → find whether the merge touches them.

```bash
git diff --name-only <merge-base> origin/<target>   # files merge brings
git status --short                                   # unstaged + untracked
```

- Overlap → those files block the merge / will conflict. Plan a stash.
- No overlap → merge proceeds without disturbing local edits; no stash needed.

⚠️ **Bash piped output can be truncated.** Do NOT trust a `--name-only` list as complete. Confirm against the actual merge attempt (it names every conflict), or re-run critical reads raw / via Read. A merge surfaced ~10 auto-merged files when `--name-only` showed only 3.

## 3. Confirm approach (when branch is stale vs its remote)

Hard-to-reverse + user's call. Ask: sync-then-merge (recommended, fully up to date, clean FF push) vs merge-into-stale-HEAD (diverges from remote → messy push). Note it creates one merge commit.

## 4. Preserve local unstaged changes

```bash
git merge --ff-only origin/<current-branch>   # sync step, if branch was behind
git stash push -m "local unstaged (merge)"    # tracked modified files only; untracked stay
git merge origin/<target> --no-edit
# ... resolve conflicts (step 5) ...
git commit -m "Merge remote-tracking branch 'origin/<target>' into <current-branch>" > commit.log 2>&1  # hook output to file; then check exit code + grep -iE 'error|fail' commit.log
git stash pop                                  # restore local edits on top
```

- **Short commit message — one line only.** `git commit --no-edit` after a conflicted merge auto-appends a `Conflicts:` file list → bloated message. Always commit with explicit `-m "Merge remote-tracking branch 'origin/<target>' into <current-branch>"`. Same applies to `--amend` (step 7): `git commit --amend -m "<same one-liner>"`, never `--amend --no-edit` (it keeps the bloated message).
- **Redirect the commit's pre-commit hook output.** A lint/typecheck pre-commit hook can dump tens of KB into context on `git commit`. Send it to a file (`> commit.log 2>&1`) — never `--no-verify`, the hook must still run — then surface only the exit code + `grep -iE 'error|fail' commit.log`. Apply the same redirect to `git stash pop` when hooks are heavy.
- Stash pop usually auto-merges shared files cleanly (3-way: stash base / merged file / local edits). If it re-conflicts, combine merged-target version + local tweaks.
- Untracked files (`.npmrc`, `CLAUDE.md`, `docs/`, the Windows `nul` artifact) don't block merge — leave them.

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

## 6. Catch SILENT semantic conflicts — typecheck

Git merges files independently. A signature change in file A + a call in file B do NOT textually conflict but will NOT compile. **Always typecheck after resolving.**

```bash
npx tsc --noEmit -p tsconfig.json --ignoreDeprecations 5.0
```

- `--ignoreDeprecations 5.0` overrides an invalid `"ignoreDeprecations": "6.0"` in tsconfig (TS 5.8 rejects it → TS5103). CLI flag wins over tsconfig.
- No ESLint/Biome in the project → tsc is the only static check.
- When a param was removed/renamed across the merge (`{ legacyFlag }` → `{ channel, addAddress }`): grep all CALLERS. If no caller exercised the old param's truthy path, the old default == new default → call with no arg. Don't invent a mapping.

## 7. Commit discipline

- The authorized merge commit must compile. If typecheck reveals a fix only AFTER committing, ask the user: amend merge commit / separate fixup commit / leave unstaged for them.
- Amend = stage ONLY the fix file (local-only unstaged files stay out); use the explicit one-line `-m` from step 4, never `--amend --no-edit`.

## 8. Pre-push verification

```bash
git merge-base --is-ancestor origin/<current-branch> HEAD && echo "FF-safe"   # clean push, no force
git log --oneline origin/<current-branch>..HEAD                                # what will push
git diff --cached --name-only                                                  # should be empty
```

Confirm: fast-forward push, no conflict markers, nothing wrongly staged, tsc clean. Local-only unstaged changes are not committed → won't push. Don't run `git push` — tell the user the command.

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
