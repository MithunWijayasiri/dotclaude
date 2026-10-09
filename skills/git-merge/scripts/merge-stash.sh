#!/usr/bin/env bash
# Usage: merge-stash.sh push|pop
# push: stash tracked local changes; records the new stash SHA only if this call created one.
# pop:  pop that recorded stash (by SHA); no-op if push created none.
set -u

die() { echo "merge-stash: $*" >&2; exit 1; }

GD=$(git rev-parse --git-dir 2>/dev/null) || die "not a git repo"
STATE="$GD/git-merge-stash"

case "${1:-}" in
  push)
    [ -e "$STATE" ] && die "recorded stash exists ($(cat "$STATE")); pop it first"
    before=$(git rev-parse -q --verify refs/stash || echo none)
    git stash push -m "local unstaged (merge)" > /dev/null || die "git stash push failed"
    after=$(git rev-parse -q --verify refs/stash || echo none)
    if [ "$before" = "$after" ]; then
      echo "nothing stashed (pre-existing stash: $before)"
    else
      echo "$after" > "$STATE"
      echo "stashed: $after"
    fi
    ;;
  pop)
    [ -e "$STATE" ] || { echo "no stash from this workflow; nothing to pop"; exit 0; }
    sha=$(cat "$STATE")
    ref=$(git stash list --format='%H %gd' | awk -v s="$sha" '$1==s{print $2}')
    [ -n "$ref" ] || die "recorded stash $sha not in stash list"
    rm -f "$STATE"
    git stash pop "$ref" || die "pop of $ref ($sha) failed or conflicted; git kept the stash; resolve, then 'git stash drop $ref'"
    ;;
  *) die "usage: merge-stash.sh push|pop" ;;
esac
