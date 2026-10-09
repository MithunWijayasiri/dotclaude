#!/usr/bin/env bash
# Usage: merge-recon.sh <target>
# Fetches origin (only mutation), prints one compact digest for the merge plan.
set -u

die() { echo "merge-recon: $*" >&2; exit 1; }
# cap N: print first N stdin lines indented, then "+K more"
cap() { awk -v n="$1" 'NR<=n{print "  " $0} END{if(NR>n) printf "  +%d more\n", NR-n}'; }
count() { wc -l < "$1" | tr -d ' '; }

TARGET=${1:-master}
git rev-parse --git-dir >/dev/null 2>&1 || die "not a git repo"
GD=$(git rev-parse --git-dir)
CUR=$(git symbolic-ref -q --short HEAD) || die "detached HEAD; check out a branch first"
[ -e "$GD/MERGE_HEAD" ] && die "merge already in progress"
if [ -d "$GD/rebase-merge" ] || [ -d "$GD/rebase-apply" ]; then die "rebase in progress"; fi
[ -z "$(git ls-files -u | head -1)" ] || die "unmerged paths present"

git fetch origin -q || die "git fetch origin failed"
git rev-parse -q --verify "refs/remotes/origin/$TARGET" >/dev/null || die "origin/$TARGET not found"

T=$(mktemp -d) || die "mktemp failed"
trap 'rm -rf "$T"' EXIT

STASH=$(git rev-parse -q --verify refs/stash || echo none)
BASE=$(git merge-base HEAD "origin/$TARGET") || die "no merge-base with origin/$TARGET"

echo "branch: $CUR | target: origin/$TARGET | stash: $STASH"
echo "merge-base: $(git rev-parse --short "$BASE")"

# --- target commits
git log --oneline "HEAD..origin/$TARGET" > "$T/tcommits"
TOT=$(count "$T/tcommits")
echo
echo "TARGET COMMITS: $TOT"
cap 30 < "$T/tcommits"

# --- own remote
BEHIND=0; AHEAD=0
: > "$T/sync"
if git rev-parse -q --verify "refs/remotes/origin/$CUR" >/dev/null; then
  read -r BEHIND AHEAD < <(git rev-list --left-right --count "origin/$CUR...HEAD")
  DIV=""
  if [ "$BEHIND" -gt 0 ] && [ "$AHEAD" -gt 0 ]; then DIV=" (DIVERGED)"; fi
  echo
  echo "OWN REMOTE origin/$CUR: behind $BEHIND, ahead $AHEAD$DIV"
  if [ "$BEHIND" -gt 0 ]; then
    echo " behind commits:"
    git log --oneline "HEAD..origin/$CUR" | cap 15
    MERGES=$(git log --merges --oneline "HEAD..origin/$CUR")
    if [ -n "$MERGES" ]; then
      MISSING=$(git rev-list --count "origin/$TARGET" "^HEAD" "^origin/$CUR")
      echo " remote merge commits (partial merge?):"
      echo "$MERGES" | cap 5
      echo " target commits already in origin/$CUR: $((TOT - MISSING)) of $TOT; still missing after sync: $MISSING"
    fi
    git diff --name-only "HEAD...origin/$CUR" > "$T/sync"
  fi
  if [ "$AHEAD" -gt 0 ]; then
    echo " ahead commits:"
    git log --oneline "origin/$CUR..HEAD" | cap 10
  fi
else
  echo
  echo "OWN REMOTE: origin/$CUR does not exist"
fi

# --- incoming files
git diff --name-only "$BASE" "origin/$TARGET" > "$T/tfiles"
echo
echo "TARGET MERGE FILES: $(count "$T/tfiles")"
cap 25 < "$T/tfiles"
if [ "$BEHIND" -gt 0 ]; then
  echo
  echo "SYNC MERGE FILES: $(count "$T/sync")"
  cap 25 < "$T/sync"
fi

# --- local state (tracked changes, untracked, ignored)
: > "$T/entries"
while IFS= read -r -d '' rec; do
  xy=${rec:0:2}; path=${rec:3}
  case "$xy" in
    '??') k='?' ;;
    '!!') k='!' ;;
    *) if [ "${xy:1:1}" != ' ' ]; then k=M; else k=S; fi ;;
  esac
  case "${xy:0:1}" in R|C) IFS= read -r -d '' _orig ;; esac
  printf '%s\t%s\n' "$k" "$path" >> "$T/entries"
done < <(git status --porcelain=v1 -z --ignored)

NOISY='(^|/)(node_modules|dist|build|\.next|coverage|\.cache)/$'
echo
echo "LOCAL STATE"
for spec in 'M:unstaged-modified' 'S:staged' '?:untracked' '!:ignored'; do
  k=${spec%%:*}; label=${spec#*:}
  awk -F'\t' -v k="$k" '$1==k{print $2}' "$T/entries" > "$T/k"
  n=$(count "$T/k")
  [ "$n" -gt 0 ] || continue
  grep -Ev "$NOISY" "$T/k" > "$T/k2" || true
  hidden=$((n - $(count "$T/k2")))
  note=""
  if [ "$hidden" -gt 0 ]; then note=" ($hidden noisy dirs hidden)"; fi
  echo " $label: $n$note"
  cap 12 < "$T/k2"
done

# --- collisions
cat "$T/tfiles" "$T/sync" | sort -u > "$T/incoming"
awk -F'\t' 'NR==FNR{inc[++n]=$0; next}
  { e=$2; isdir=(substr(e,length(e),1)=="/")
    for(i=1;i<=n;i++){ p=inc[i]; if (isdir ? index(p,e)==1 : p==e) print $1 "\t" p } }' \
  "$T/incoming" "$T/entries" | sort -u > "$T/coll"

echo
echo "COLLISIONS (incoming files vs local state)"
any=0
for spec in 'M,S:need stash before merge' '?:untracked; merge ABORTS, move aside' '!:ignored; SILENT overwrite unless --no-overwrite-ignore, move aside'; do
  ks=${spec%%:*}; label=${spec#*:}
  awk -F'\t' -v ks="$ks" 'BEGIN{n=split(ks,a,",")} {for(i=1;i<=n;i++) if($1==a[i]) print $2}' "$T/coll" > "$T/c"
  n=$(count "$T/c")
  [ "$n" -gt 0 ] || continue
  any=1
  echo " $label: $n"
  cap 15 < "$T/c"
done
[ "$any" -eq 1 ] || echo " none"
