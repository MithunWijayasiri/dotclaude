# Conflict resolution examples

Load when a conflict needs more than "keep both".

## Overlapping logic → combine faithfully

Keep HEAD's `skipTerms` guard AND target's new conditional branch:

```ts
if (!skipOptionalFields) {
    await section.expand();
    if (await isReturningUser.isVisible()) {   // target
        await isReturningUser.click();
    } else if (!skipTerms) {                    // HEAD guard preserved
        await acceptTerms.click();
    }
}
```

## Both sides changed the SAME action

Prefer newer/more-robust pattern, for consistency with already-merged sibling blocks. E.g. target's `getByRole('button', { name: 'Save' })` over HEAD's `getByTestId('save-btn')` when an already-merged sibling block uses the former.

## Parameterized method vs plain version

HEAD's parameterized method whose defaults reproduce target's plain version → keep the parameterized superset.

## Param removed/renamed across the merge

`{ legacyFlag }` → `{ mode, retries }`: grep all CALLERS. No caller exercised the old param's truthy path → old default == new default → call with no arg. Don't invent a mapping.
