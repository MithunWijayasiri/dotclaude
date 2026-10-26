---
name: github-issue-creator
description: Create or edit GitHub issues from raw notes, error logs, voice dictation or screenshots, following the repo's issue templates and labels. Use when the user wants an issue drafted, created or updated.
---

# GitHub Issue Creator

Turn messy input into a clean issue, draft in chat, create with `gh` on approval.

## Repo

Resolve from `git remote get-url origin` (repo name can differ from folder name). Never guess `owner/repo`.
Before any `gh` write: `gh auth status`; active account must match the one project instructions require.

## Create flow

1. Find templates: `.github/ISSUE_TEMPLATE/*` (`.yml` forms or `.md`). Read `config.yml` too (`blank_issues_enabled: false` → must use a template).
2. Pick the template that fits. Several fit → ask.
3. Missing required template fields (version, device, steps…) → ask all in one batch. Never guess. Unknown → write `Not provided`.
4. Build body:
   - `.yml` form → one `### <field label>` section per field, same order as the form. `gh issue create --template` cannot fill forms, so mirror them. Include every `required` field.
   - `.md` template → `gh issue create --template` or copy its structure.
   - No template → fallback below.
5. Labels: `gh label list --repo <repo>`. Apply template `labels:` plus existing labels that clearly fit (e.g. `accessibility`). Never create labels. State which were applied.
6. Title: match style of `gh issue list --repo <repo> --limit 10`.
7. Show draft (title, labels, body) in chat. Create only after user OK: `gh issue create --repo <repo> --title ... --label ... --body-file -` (heredoc).
8. Reply with issue URL.

## Fallback template (no repo template)

Drop sections with nothing to say.

```markdown
## Summary
## Reproduction Steps
## Expected Behavior
## Actual Behavior
## Error Details
## Additional Context
```

## Edit flow

Issue body may hold images or text the user added after creation. Rewriting from memory destroys them.

1. `gh issue view <n> --repo <repo> --json title,body,labels` first, every time.
2. Edit only the parts requested. Keep everything else verbatim: `<img>`, `![](...)`, `user-attachments` URLs, user's manual edits.
3. Labels untouched unless asked.
4. Placeholder `<!-- drag the screenshot here -->` → remove once body has media; else leave.
5. Show what changed (before/after of edited parts) before `gh issue edit <n> --body-file -`.

## Images

Image or video exists as a local file → `--attach` on `gh issue create` / `edit` / `comment` uploads it and appends it to the body. Repeat the flag per file (max 50). Alt text after `#`: `--attach './login.png#Login error state'`; video takes none. Needs write access to the repo.

File not available to the shell, or `--attach` unsupported or failing → add `<!-- drag the screenshot here -->` where the image goes; user attaches it on GitHub.

Never reference local paths in the body.

## Code analysis

Only when user asks. Read local checkout; add `Cause` and `Suggested fix` per problem, citing file and symbol. Otherwise report observed behavior only.

## Content rules

- Crisp; every word adds value. Facts pulled out of casual language.
- Placeholder sensitive data (`[USER_ID]`).
- Multiple unrelated problems → one issue only if user asked for one; each problem gets its own section.
