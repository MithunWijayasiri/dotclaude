---
name: empty-commit
description: Use when a CI pipeline failed on something unrelated to the code and the PR is blocked — pushes an empty commit to re-trigger CI on the current branch.
disable-model-invocation: true
---

# Empty Commit

Empty commit + push → CI re-runs on the current branch. Zero file changes, so nothing can regress.

Any step fails → stop, report what failed; do not work around.

1. Nothing staged: `git diff --cached --quiet`. Non-zero → `--allow-empty` would commit the staged files; list them (`git diff --cached --name-only`), stop.
2. Branch: `git rev-parse --abbrev-ref HEAD`. `HEAD` (detached), `main`, or `master` → stop; empty commit on a shared branch is noise.
3. Upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`. Fails → no upstream set; stop, ask user which case: never pushed → `git push -u origin <branch>` alone triggers CI; already pushed without `-u` → `git branch -u <remote>/<branch>`, re-run (re-pushing the same commit triggers nothing).
4. Commit, subject only, no trailer of any kind:

   ```bash
   git commit --allow-empty -m "chore: trigger pipeline re-run"
   ```

5. `git push`. Fails → commit exists locally, not pushed; say so.
6. Report one line: short SHA, branch, PR link if push output printed one.

Unstaged and untracked files are ignored, they stay untouched.

## Caveat — which pipelines this actually re-runs

Only pipelines triggered by a push to the branch or its PR. Config varies by provider:

| Provider | Re-runs | Does not re-run |
| --- | --- | --- |
| GitHub Actions | `on: push`, `on: pull_request` | `on: workflow_dispatch` only |
| GitLab CI | jobs matching `rules:` / `workflow:rules` for the branch or MR | `when: manual` jobs |
| Bitbucket Pipelines | `pull-requests`, `branches` | `custom` |

Manually-triggered pipelines never fire from a commit. If the red check is one of those, an empty commit does nothing — say so and point the user at re-running it by hand, with any variables it prompts for.

Unsure which kind → check the CI config in the repo (`.github/workflows/`, `.gitlab-ci.yml`, `bitbucket-pipelines.yml`).
