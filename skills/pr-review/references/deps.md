# Dependency Review

## New dependency

- From a trusted source, actively maintained, no known vulnerabilities (`npm audit`).
- License compatible with the project.

## Upgrades

Riskiest upgrades are the ones merged in bulk as "bump deps". Review with the same discipline:

- Read the **changelog**, not the version number. Semver is a promise the maintainer may not have kept; a patch can carry behavioral change. Major bump → read migration notes, find what breaks.
- **One dependency per change.** A bulk bump that breaks the build hides which package did it.
- **Tests decide.** Green before and after. Thin coverage around the dependency's behavior *is* the finding — add a test first.
- **Mind the transitive graph.** Review the lockfile diff, not just `package.json`.
- **Keep the lockfile honest.** Commit it, review its diff, never hand-edit it.
