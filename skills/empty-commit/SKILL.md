---
name: empty-commit
description: Use when a CI pipeline failed on something unrelated to the code and the PR is blocked — pushes an empty commit to re-trigger CI on the current branch.
disable-model-invocation: true
---

# Empty Commit

Empty commit + push → CI re-runs on the current branch. Zero file changes, so nothing can regress.

Run from the repo, then report its output verbatim:

```bash
bash ~/.claude/skills/empty-commit/scripts/empty-commit.sh
```

Script checks guards (nothing staged, not `master`/`main`, upstream exists), commits `chore: trigger pipeline re-run` (subject only, no trailer), pushes, prints one line: SHA, branch, PR link if any.

Non-zero exit → report what failed; do not work around. Exit 2 = no upstream; script prints the `git push -u origin <branch>` guidance.

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
