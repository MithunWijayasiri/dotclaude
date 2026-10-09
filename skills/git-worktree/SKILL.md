---
name: git-worktree
description: Use when the user asks to create, enter/switch to, or remove a git worktree on Windows — makes it under `.claude/worktrees/` and provisions a shared node_modules (junction) and local `.env` so it runs without a reinstall. Windows + PowerShell only. Trigger on `/git-worktree`.
---

# Git Worktree

Windows + PowerShell only. Worktrees live at `<repo>/.claude/worktrees/<name>`. Add `.claude/worktrees/` to the repo's `.gitignore` — Claude Code doesn't.

Scripts: `scripts/wt-create.ps1`, `scripts/wt-remove.ps1` (PowerShell 5.1+). Run as `powershell -NoProfile -File <skill dir>\scripts\<script>.ps1 ...`. Below, `$SKILL` = this skill's directory (e.g. `$HOME\.claude\skills\git-worktree`).

Commands: **create** (`/git-worktree feature-login`), **switch** (`/git-worktree switch`), **remove** (`/git-worktree remove`). Bare `/git-worktree` → switch.

## Hard rules

- Never `npm install` / `npm ci` in a worktree whose `node_modules` is a junction — mutates main repo's deps. Only the drift path (Create step 3, `npm ci` option) makes a real `node_modules` where installing is safe.
- Never delete a worktree directory while a `node_modules` junction is live. Unlink first (Remove step 3) — a recursive delete that follows the junction can eat main's `node_modules`.
- Removal always user-confirmed. Never automatic, never inferred from "PR raised" or "work done".
- Copy `.env`, never link it. A link → worktree edit silently rewrites the real secrets file.

## Create

**1. Guard.** Record `MAIN = git rev-parse --show-toplevel` first — after entering, cwd is the worktree and this resolves differently.

```powershell
powershell -NoProfile -File "$SKILL\scripts\wt-create.ps1" -Main "$MAIN"
```

Exit 1 → already inside `.claude/worktrees/`; worktrees don't nest. Tell user to `/git-worktree remove` or exit first.

**2. Enter.** `EnterWorktree(name: "<name>")` → creates `.claude/worktrees/<name>` on a new branch, switches session cwd. Set `WT` = returned path. Report the branch name from the result.

Base ref = `worktree.baseRef` setting: `fresh` (default) branches from `origin/<default-branch>`, `head` from current local HEAD. Don't change it. User wants to stack on unpushed local work → `worktree.baseRef` must be `head` in settings first; don't flip it silently.

**3. node_modules + `.env`** (one script):

```powershell
powershell -NoProfile -File "$SKILL\scripts\wt-create.ps1" -Main "$MAIN" -Wt "$WT"
```

Script:
- node_modules skipped if `$WT\package.json` absent, `$WT\node_modules` exists, or main has none.
- Compares on-disk `package-lock.json` (main's installed tree matches main's working-copy lockfile, not any committed ref). Identical → junction. Junctions need no admin or Developer Mode, unlike symlinks.
- Copies root-level `.env*` from main that Wt lacks. Gitignored, so checkout has none; tracked ones already present, so the existence check is the whole filter.
- Prints `node_modules: <mode>` and `env copied: <files>`.

Exit codes: 0 ok, 1 error/guard refusal, 2 lockfile **DRIFT**.

Exit 2 (also when lockfile missing on either side) → not linked; branch's deps don't match what's installed. `.env` still copied. **Stop, report, ask user:**
- junction anyway (read-only work, raising a PR without running anything) → re-run with `-ForceJunction`, or
- `npm ci` in `$WT` — gives a real `node_modules`; slow, use a long timeout (10 min). Needs `$WT\package-lock.json` or `npm-shrinkwrap.json`; neither → offer the project's own install command instead.

Exit 1 → report the printed error.

**4. Report** path, branch, base, node_modules mode (junction / real / skipped), files copied, and what Not provisioned leaves out.

## Switch

List candidates with branch and dirty state; user picks:

```bash
git worktree list --porcelain
```

`git -C <path> status --short` per entry for dirty state.

Set `MAIN` = first `worktree` entry of that list (the main worktree) before entering; Create step 3 needs it.

`EnterWorktree(path: "<chosen>")`, then re-run Create step 3 — worktrees from a bare `git worktree add`, or made before this skill, usually lack `node_modules` and `.env`.

From inside a worktree, `EnterWorktree(path)` only reaches worktrees under the same repo's `.claude/worktrees/`. Worktrees elsewhere (sibling dirs) → exit to main repo first.

## Remove

**1. Identify** target: current worktree, or the one user named.

**2. Report and confirm.**

```powershell
powershell -NoProfile -File "$SKILL\scripts\wt-remove.ps1" -Wt "$WT" -Report
```

Lists uncommitted files, ignored files (copied `.env`, build output; `node_modules` excluded, step 3 handles it), and unpushed commits on the worktree's HEAD (capped at 30 each). Wait for explicit confirmation. Any list non-empty → say so plainly; that work dies with the worktree.

**3. Unlink node_modules** — after confirmation, before any removal command touches the directory:

```powershell
powershell -NoProfile -File "$SKILL\scripts\wt-remove.ps1" -Wt "$WT" -Unlink
```

Removes the junction only (`cmd /c rmdir`; target keeps contents). Real directory or none → untouched. Exit codes: 0 ok, 1 error, 3 `node_modules` is a non-junction link (e.g. symlink) → stop, tell user. Script never removes the worktree itself.

**4. Remove.** Session created the worktree via EnterWorktree → `ExitWorktree(action: "remove")` (`discard_changes: true` only after user confirmed step 2).

Otherwise `ExitWorktree(action: "keep")` to return to main repo, then:

```bash
git worktree remove <path>
git branch -d <branch>
git worktree prune
```

`remove` refusing a dirty tree needs `--force`; `branch -d` refusing an unmerged branch needs `-D`. Both only after step-2 confirmation, never pre-emptively. `remove` failing as locked → `git worktree unlock <path>`, retry.

## Not provisioned

Only `.env*` copied. Other gitignored local state — saved auth/session state, tokens, caches, build output — absent; project's own setup step regenerates it on first run. Say so in the create report so a slow first run isn't mistaken for failure.

## Per-repo one-time check

Root-level tooling that globs the whole tree compiles/lints every nested worktree copy. First use in a repo → check all three, offer fixes:

- **.gitignore** — needs `.claude/worktrees/`.
- **tsconfig** — affected only when `include` is unanchored from repo root (`["./**/*.ts"]`). Includes anchored to a source dir (`["src/**/*.ts"]`) never reach `.claude/`; adding `exclude` there is dead config. When it applies, adding `exclude` discards TypeScript's implicit default → list `node_modules` alongside `.claude`.
- **eslint** — nearly always affected, regardless of tsconfig. Flat config (`eslint.config.mjs`) auto-ignores only `**/node_modules/` and `.git/` → `.claude` needs an explicit `globalIgnores` entry; eslintrc needs `ignorePatterns`. Worse with `parserOptions.project` + `createDefaultProgram: true` — worktree files fall outside the project's program, each gets a slow fallback program.
