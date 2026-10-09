#!/usr/bin/env bash
# Empty commit + push to re-trigger CI on the current branch.
set -u

fail() { echo "FAIL: $*" >&2; exit 1; }

git rev-parse --git-dir >/dev/null 2>&1 || fail "not a git repository"

# Guard 1: nothing staged (--allow-empty would sweep staged files in)
if ! git diff --cached --quiet; then
  echo "FAIL: staged changes present; commit would not be empty:" >&2
  git diff --cached --name-only >&2
  echo "Unstage or commit them deliberately, then re-run." >&2
  exit 1
fi

# Guard 2: not on default branch
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || fail "cannot resolve current branch"
[ "$branch" = "HEAD" ] && fail "detached HEAD"
case "$branch" in
  master|main) fail "on '$branch'; empty commit on the shared branch is noise" ;;
esac

# Guard 3: upstream exists
if ! git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  echo "FAIL: '$branch' has no upstream (never pushed)." >&2
  echo "Push it normally instead; that alone triggers CI: git push -u origin $branch" >&2
  exit 2
fi

out=$(mktemp) || fail "mktemp failed"
trap 'rm -f "$out"' EXIT

# No trailer of any kind: subject only
printf 'chore: trigger pipeline re-run\n' | git commit --allow-empty -F - >"$out" 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
  echo "FAIL: git commit exit $rc" >&2
  grep -iE 'error|fail' "$out" >&2
  exit 1
fi

git push >"$out" 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
  echo "FAIL: git push exit $rc (commit created locally, not pushed)" >&2
  grep -iE 'error|fail|rejected|denied' "$out" >&2 || tail -n 5 "$out" >&2
  exit 1
fi

sha=$(git rev-parse --short HEAD)
pr=$(grep -oE 'https?://[^[:space:]]*(pull|merge_requests|pull-requests)[^[:space:]]*' "$out" | head -n 1)
echo "pushed $sha on $branch${pr:+ | PR: $pr}"
