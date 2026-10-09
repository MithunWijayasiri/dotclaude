#!/usr/bin/env bash
# Usage: merge-verify.sh [-- <check command> [args...]]
# Checks conflict markers, unmerged files, an optional repo check command, pre-push state.
# The check command runs from the repo root. Ends with one PASS/FAIL line.
set -u

die() { echo "merge-verify: $*" >&2; exit 1; }
cap() { awk -v n="$1" 'NR<=n{print "  " $0} END{if(NR>n) printf "  +%d more\n", NR-n}'; }
count() { wc -l < "$1" | tr -d ' '; }

if [ "$#" -gt 0 ]; then
  [ "$1" = "--" ] || die "usage: merge-verify.sh [-- <check command> [args...]]"
  shift
fi

TOP=$(git rev-parse --show-toplevel 2>/dev/null) || die "not a git repo"
cd "$TOP" || die "cannot cd to $TOP"
GD=$(git rev-parse --git-dir)
BR=$(git symbolic-ref -q --short HEAD) || die "detached HEAD"
T=$(mktemp -d) || die "mktemp failed"
trap 'rm -rf "$T"' EXIT
FAIL=()

echo "branch: $BR"

# --- conflict markers (tracked, non-binary)
git grep -nIE '^(<<<<<<<( |$)|>>>>>>>( |$)|=======[[:space:]]*$)' > "$T/markers" 2>/dev/null
N=$(count "$T/markers")
echo "conflict markers: $N"
if [ "$N" -gt 0 ]; then cap 15 < "$T/markers"; FAIL+=("conflict markers in $N lines"); fi

# --- unmerged
git diff --name-only --diff-filter=U > "$T/unmerged"
N=$(count "$T/unmerged")
echo "unmerged files: $N"
if [ "$N" -gt 0 ]; then cap 15 < "$T/unmerged"; FAIL+=("$N unmerged files"); fi

# --- repo check
if [ "$#" -eq 0 ]; then
  echo "check: skipped (no command given)"
else
  "$@" > "$T/check.log" 2>&1
  RC=$?
  echo "check ($*): exit $RC"
  if [ "$RC" -ne 0 ]; then
    grep -iE 'error' "$T/check.log" > "$T/check.err" || cp "$T/check.log" "$T/check.err"
    echo "  error lines: $(count "$T/check.err")"
    head -20 "$T/check.err" | sed 's/^/  /'
    FAIL+=("check exit $RC")
  fi
fi

# --- pre-push
if [ -e "$GD/MERGE_HEAD" ]; then
  echo "push checks: skipped (merge in progress; commit, then rerun)"
else
  if git rev-parse -q --verify "refs/remotes/origin/$BR" >/dev/null; then
    if git merge-base --is-ancestor "origin/$BR" HEAD; then
      echo "push: FF-safe"
    else
      echo "push: NOT fast-forward (origin/$BR is not an ancestor of HEAD)"
      FAIL+=("not FF-safe")
    fi
    echo "will push:"
    git log --oneline "origin/$BR..HEAD" | cap 15
  else
    echo "push: origin/$BR does not exist (new branch)"
  fi
  git diff --cached --name-only > "$T/staged"
  N=$(count "$T/staged")
  echo "staged: $N"
  if [ "$N" -gt 0 ]; then cap 15 < "$T/staged"; FAIL+=("$N files staged"); fi
fi

echo
if [ "${#FAIL[@]}" -eq 0 ]; then
  echo "PASS"
else
  printf 'FAIL: %s' "${FAIL[0]}"
  for r in "${FAIL[@]:1}"; do printf '; %s' "$r"; done
  echo
  exit 1
fi
