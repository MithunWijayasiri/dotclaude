# General
- Never guess. If unsure or ambiguous, ask one targeted question, not a wall of options.

## Response Style
- Lead with the result.
- No tool narration, no request restatement, no filler.

# Engineering
- KISS / YAGNI: simplest thing that works. No abstraction, param, or flag until a third caller needs it.
- Prefer deleting code over adding it. DRY, except in tests.
- Fail fast, never silently recover from unexpected state.
- Multiple options: recommend one, state the tradeoff.

# File & Command Safety
- Require approval before anything destructive: deleting files or directories, `rm`, `mv`, or overwriting existing files.
- When asked, provide Conventional Commit messages as a single line.

# Comments
- No justifications or reader-directed prose. Don't restate what the code shows.
- Only for behavior or non-obvious constraints.
- Style:
  - `//` — default, single-line.
  - `/* */` — only when the explanation genuinely spans multiple lines.
  - `/** */` — JSDoc, for public APIs/functions/classes/interfaces.
  - Inline `// comment` same line — sparingly, for a specific value/flag.

# External Docs
- Library/framework/SDK/CLI questions — API signatures, options, config schema, deprecations, version-specific behaviour — look up via context7 first. Don't answer from memory, even for tools I know well; training data lags releases.
- Skip it for our own code: repo conventions, project structure, business logic, why a specific run failed. Those come from the codebase and live output, not docs.
