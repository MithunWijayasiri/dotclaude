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

Verify the ref resolves (`git rev-parse <ref>`) and the diff is non-empty **before** reviewing. Bad ref or empty diff → stop and say so.

Collect the counts the §7 header needs while you are here: `git diff --shortstat <range>`, or for a PR `gh pr view <n> --json title,body,additions,deletions,changedFiles` — which also returns the intent §2 looks for.

Ambiguous input → ask. Do not review a guessed target.

## 2. Gather context

**A diff alone is not enough.** Code that looks wrong in isolation is often correct given surrounding logic, and vice versa.

- Read the **full file** for up to ~5 key changed files — entry points, trust boundaries, shared modules — for existing patterns, control flow, and error handling. Hunks plus the surrounding function for the rest. Over ~15 changed files → state which files you read in full.
- Read repo standards if present: `CLAUDE.md`, `.claude/rules/*.md`, `CONTRIBUTING.md`, `CODING_STANDARDS.md`, `AGENTS.md`, `CONVENTIONS.md`. A documented repo standard overrides every default in this skill.
- Find the spec: issue ref in commit messages (`gh issue view <n>`), ticket key in the branch name, or a doc under `docs/`/`specs/`. No spec found → skip the spec axis, note it in the report. Do not invent requirements.
- Changes touching input, auth, storage, network, rendering, or secrets → trace the trust boundary, not just the changed lines.

## 3. Review axes

Ordered by leverage. Spend effort top-down.

**Correctness** — the primary job.
- Logic errors, off-by-one, inverted or missing conditionals, unreachable branches.
- Edge cases: null/empty/undefined, boundaries, overflow, concurrent access.
- Error paths, not just the happy path. Swallowed failures, wrong error type, silent fallback hiding an unclear invariant.
- Tests: do they exist, do they test behavior rather than implementation, would they catch this regression?

**Spec** — only if a spec was found.
- Requirements missing or partially implemented.
- Behavior in the diff nobody asked for (scope creep).
- Requirements that look implemented but are wrong. Quote the spec line.

**Structure** — does the change fit the codebase?
- Uses existing patterns and canonical helpers, or bolts on a near-duplicate.
- New conditional grafted onto an unrelated flow → missing abstraction, not a nit.
- Feature-specific logic leaking into a shared module.
- Refactor that relocates complexity instead of removing it — count the concepts a reader must hold; unchanged count means it isn't cleaner.
- Gratuitous `any` or cast papering over a type boundary. `unknown` plus narrowing is the fix, not the smell.

**Security** — first-class, not an afterthought.
- Assume changed code is reachable by hostile input unless verifiable otherwise.
- Validation and authorization at the real boundary, not the UI or the caller.

**Performance** — flag only when obviously problematic.
- N+1, unbounded loops or fetches, blocking I/O on a hot path, missing pagination.

## 4. References

Load only what the diff warrants. Never read all of them.

| Diff touches | Read |
|---|---|
| Auth, user input, SQL, file paths, secrets, external data, serialization, rendering | `references/security.md` |
| Queries, loops over remote calls, list endpoints, hot paths | `references/performance.md` |
| Refactor-heavy PR, duplication, or a structural concern you are about to flag | `references/smells.md` |
| Components, templates, state, styling, client routing (React/Angular) | `references/frontend.md` |
| Services, handlers, jobs, CLIs, Node/server-side modules, outbound HTTP clients | `references/backend.md` |
| ORM calls, raw SQL, migrations, schema, transactions | `references/database.md` |
| HTTP handlers, routes, request/response shapes, API clients | `references/api.md` |
| Test files, or a change shipping without tests | `references/testing.md` |
| `package.json`, lockfiles, Renovate/Dependabot bumps | `references/security.md` (Dependency upgrades) |
| CI workflows, Dockerfiles, infra config | `references/security.md` (Secrets, Trust boundaries) |

Each rule has exactly one home. Load one file per concern; reach for a second only when a finding genuinely spans areas.

## 5. Before flagging anything

- **Be certain.** Unsure it's a bug → investigate before writing it up. Still unsure → say "I'm not sure about X", don't file it as a finding.
- **Only review what changed.** Pre-existing code outside the diff is out of scope unless the change makes it newly wrong — unless the user named a file, which makes that whole file the target.
- **No hypotheticals.** State the concrete input/state that triggers the failure. If you can't, it isn't a finding.
- **Security findings need an exploit path** — attacker-controlled input, the missing control, the impact. Not "potential security concern".
- **Skip what tooling enforces.** Formatting, lint rules, and compiler errors are not review findings.
- **Don't be a style zealot.** Verify the code actually violates a documented convention. A `let` is fine when the alternative is convoluted.

## 6. Severity

| Level | Meaning |
|---|---|
| Blocker | Correctness bug, security hole, data loss, or a violation of a documented non-negotiable. Must fix before merge. |
| Should fix | Real defect or structural regression that isn't fatal. Fix or justify. |
| Nit | Naming, minor duplication, style. Author may ignore. |

Order findings by leverage, not by file order. One structural problem plus ten nits → **the structural problem is the review**.

Verdict: `Approve` when the change definitely improves code health even if imperfect. `Request changes` when a Blocker exists, or Should-fixes that materially degrade the codebase. Don't block because you'd have written it differently.

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

Rules for the block:
- Every Blocker and Should-fix carries **location + why + fix**. A Nit carries location + claim only.
- Number findings continuously across sections (1, 2, 3…) so they're citable.
- Nits are one line each — no `→` fix line, no explanation.
- Considered something and deliberately did not flag it → one closing line: `**Not flagged:** <thing> — <reason>.`
- Non-defects a human should sign off on (schema change, contract change, new dependency, dead code left behind) → one closing line: `**Needs a second look:** <thing> — <why>.` Do not invent a severity for them.
- No spec found → one closing line saying so.
- Nothing found → `**Verdict:** Approve — no findings.` plus one line on what you checked. Never pad with praise.

Tone: matter-of-fact. No flattery, no "Great job", no "Thanks for". No summary section restating the findings.
