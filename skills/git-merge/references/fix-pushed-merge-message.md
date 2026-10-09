# Fix an already-pushed merge message

Only when the bad message was already pushed (not the normal flow). Rewrites published history → confirm with user first.

```bash
git rev-parse HEAD origin/<current-branch>   # equal → remote hasn't moved, safe
git commit --amend -m "Merge remote-tracking branch 'origin/<target>' into <current-branch>"
git push --force-with-lease origin <current-branch>   # NOT --force; lease aborts if a teammate pushed
```

Amending a merge commit preserves both parents. Teammate who already pulled must reset their local copy.
