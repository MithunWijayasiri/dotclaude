---
name: pr-review
description: Review a PR, branch, commit, or uncommitted changes for correctness bugs, structural regressions, security and performance problems. Reports findings grouped by severity with file:line and a concrete fix. Use when asked to review a PR / branch / diff / "my changes" before merge.
disable-model-invocation: true
---

# PR Review

Review a change for defects. Bugs first, structure second, style last.

## 1. Resolve the target

| Input | Commands |
|---|---|
| Nothing | `git diff` + `git diff --cached` (uncommitted) |
| PR number / URL | `gh pr view <n>` then `gh pr diff <n>` |
| Base branch named, you are **on** the branch under review | `git diff <base>...HEAD` |
| Branch to review named, you are **elsewhere** | `git diff HEAD...<branch>` |
| Commit SHA | `git show <sha>` |
| `since X` / tag / `HEAD~5` | `git diff X...HEAD` + `git log X..HEAD --oneline` |
| File path | review that file's current state |

Three-dot is merge-base: `A...B` shows **B's** side. Point it the wrong way and you silently review the opposite branch. Run `git branch --show-current` before choosing the row.

Validate before reviewing:
- Ref (branch, commit, tag, range) → `git rev-parse <ref>`.
- PR → `gh pr view <n>`; a fork PR may have no local ref.
- File path → exists and readable; review it whether or not it changed.

Bad target or empty diff → stop and say so. Ambiguous input → ask; never review a guessed target.

Counts for the §7 header: `git diff --shortstat <range>`, or `gh pr view <n> --json title,body,additions,deletions,changedFiles` — also returns the PR intent.

## 2. Gather context

A diff alone misleads — code wrong in isolation is often right in context, and vice versa.

- Full file for up to ~5 key changed files (entry points, trust boundaries, shared modules); hunk plus enclosing function for the rest. Over ~15 files → state which you read in full.
- Repo standards if present: `CLAUDE.md`, `.claude/rules/*.md`, `CONTRIBUTING.md`, `CODING_STANDARDS.md`, `AGENTS.md`, `CONVENTIONS.md`. A documented standard overrides every default here and in `references/`.
- Spec: issue ref in commits (`gh issue view <n>`), ticket key in branch name, or a doc under `docs/`/`specs/`. None → skip the spec axis, say so in the report. Never invent requirements.
- Input, auth, storage, network, rendering, or secrets touched → trace the trust boundary, not just the changed lines.

## 3. Review axes

Ordered by leverage; spend effort top-down.

**Correctness**
- Logic errors, off-by-one, inverted or missing conditionals, unreachable branches.
- Edge cases: null/empty, boundaries, overflow, concurrent access.
- Error paths: swallowed failures, wrong error type, silent fallback hiding an unclear invariant.
- Tests: exist, test behavior not implementation, would catch this regression.

**Spec** — only if found.
- Requirements missing, partial, or implemented wrong — quote the spec line.
- Behavior nobody asked for (scope creep).

**Structure**
- Near-duplicate bolted on instead of the existing pattern or canonical helper.
- New conditional grafted onto an unrelated flow → missing abstraction, not a nit.
- Feature-specific logic leaking into a shared module.
- Refactor that relocates complexity instead of removing it — same number of concepts to hold means not cleaner.
- Gratuitous `any` or cast over a type boundary. `unknown` plus narrowing is the fix, not the smell.

**Security**
- Changed code is reachable by hostile input unless verifiably not.
- Validation and authorization at the real boundary, not the UI or the caller.

**Performance** — only when obvious: N+1, unbounded loops or fetches, O(n²) on growing data, blocking I/O on a hot path, missing pagination. Quantify ("~50ms per item") or state the growth ("one query per line item; an order carries up to 50") — never "this could be slow".

## 4. References

One file per concern the diff warrants; a second only when a finding spans areas. Never read all.

| Diff touches | Read |
|---|---|
| Auth, user input, SQL, file paths, secrets, external data, serialization, rendering | `references/security.md` |
| Refactor-heavy PR, duplication, or a structural concern you are about to flag | `references/smells.md` |
| Components, templates, state, styling, client routing (React/Angular) | `references/frontend.md` |
| Services, handlers, jobs, CLIs, Node/server-side modules, outbound HTTP clients, loops over remote calls | `references/backend.md` |
| ORM calls, raw SQL, queries in loops, migrations, schema, transactions | `references/database.md` |
| HTTP handlers, routes, request/response shapes, API clients | `references/api.md` |
| Test files, or a change shipping without tests | `references/testing.md` |
| `package.json`, lockfiles, Renovate/Dependabot bumps | `references/deps.md` |
| CI workflows, Dockerfiles, infra config | `references/security.md` (Secrets, Trust boundaries) |

## 5. Before flagging anything

- **Be certain.** Unsure → investigate. Still unsure → "I'm not sure about X", not a finding.
- **Only what changed.** Pre-existing code is out of scope unless the change makes it newly wrong. A user-named file is wholly in scope.
- **No hypotheticals.** Name the concrete input/state that triggers the failure, or drop it.
- **Security needs an exploit path** — attacker-controlled input, missing control, impact. Never "potential security concern".
- **Skip what tooling enforces** — formatting, lint, compiler errors.
- **Style only against a documented convention.** A `let` is fine when the alternative is convoluted.

## 6. Severity

| Level | Meaning |
|---|---|
| Blocker | Correctness bug, security hole, data loss, or a violation of a documented non-negotiable. Must fix before merge. |
| Should fix | Real defect or structural regression that isn't fatal. Fix or justify. |
| Nit | Naming, minor duplication, style. Author may ignore. |

Order by leverage, not file order. One structural problem plus ten nits → **the structural problem is the review**.

Verdict: `Approve` when the change improves code health, even if imperfect. `Request changes` on any Blocker, or Should-fixes that materially degrade the codebase. Never block over "I'd have written it differently".

## 7. Output format

Exactly this shape. Skip any severity section with no findings.

```markdown
## Review — <target> (<N> files, +<add>/−<del>)

**Verdict:** <Approve | Request changes> — <n> blocker, <n> should-fix, <n> nits

### Blockers
**1. <one-line claim>** · `path/file.ts:LINE`
<Why it breaks — the concrete input or state, and the consequence. 1-3 lines.>
→ <Concrete fix.>

### Should fix
**2. <one-line claim>** · `path/file.ts:LINE`
<Why. 1-2 lines.>
→ <Fix.>

### Nits
**3.** <claim> · `path/file.ts:LINE`
```

- Number findings continuously across sections so they're citable.
- Blocker / Should fix: location + why + fix. Nit: one line, location + claim only.
- Closing lines, each only if applicable:
  - `**Not flagged:** <thing> — <reason>.` — considered and deliberately skipped.
  - `**Needs a second look:** <thing> — <why>.` — non-defect needing human sign-off. No severity. Covers:
    - Schema change.
    - API contract change of unclear blast radius. A confirmed breaking change is a defect — give it a severity.
    - New dependency or framework.
    - Change to a performance- or security-sensitive path.
    - Dead code left by the change — name each symbol and why it's dead, e.g. `formatLegacyDate() in src/utils/date.ts (replaced by formatDate()) — safe to remove?`. Never delete silently.
  - No spec found.
- Nothing found → `**Verdict:** Approve — no findings.` plus one line on what you checked.

Tone: matter-of-fact. No praise, no thanks, no summary restating findings.
