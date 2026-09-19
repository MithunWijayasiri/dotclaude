# Security Review

Read when the diff touches auth, user input, SQL, file paths, secrets, external data, serialization, or rendering.

## Checks

**Input & injection**
- SQL built by string concatenation or an untagged template literal → parameterize. A tagged template (postgres.js, Slonik, Prisma `$queryRaw`) parameterizes — check the API before flagging.
- Command/shell construction from user data.
- Output encoded before rendering (XSS); template auto-escaping not bypassed.
- Path traversal on any user-controlled file path.
- Insecure deserialization — a parser that can instantiate objects or run code from the payload (`yaml.load` without a safe schema, `node-serialize`), or prototype pollution via `__proto__` in a merged object.
- `eval` / `new Function` on external data — code execution, a separate finding. Plain `JSON.parse` is not one.

**Auth & access**
- Sensitive operations fail closed.
- No privilege escalation; no widening of actor/resource scope beyond intent.
- Tenant/data isolation preserved — no cross-tenant read or write.
- CSRF on state-changing endpoints; SSRF on any server-side fetch of a user-supplied URL; open redirects.

**Secrets**
- No credentials, tokens, or keys in code, logs, error messages, or version control.
- Sensitive values never placed in URL params or query strings.

**Trust boundaries**
- Data from APIs, logs, user content, and config files treated as untrusted.
- External data validated at the boundary before use in logic or rendering.
- Insecure defaults (permissive CORS, debug on, verbose errors to the client).

**Dependencies**
- From trusted sources, actively maintained, no known vulnerabilities (`npm audit`).
- License compatible with the project.

## Dependency upgrades

Riskiest upgrades are the ones merged in bulk as "bump deps". Review with the same discipline:

- Read the **changelog**, not the version number. Semver is a promise the maintainer may not have kept; a patch can carry behavioral change. Major bump → read migration notes, find what breaks.
- **One dependency per change.** A bulk bump that breaks the build hides which package did it.
- **Tests decide.** Green before and after. Thin coverage around the dependency's behavior *is* the finding — add a test first.
- **Mind the transitive graph.** Review the lockfile diff, not just `package.json`.
- **Keep the lockfile honest.** Commit it, review its diff, never hand-edit it.
