# Test Review

Read when the diff adds or changes tests, or when a change ships without them.

## Is the test worth having?

- **Tests behavior, not implementation.** A test asserting internal calls breaks on every refactor and catches no regression.
- **Would it fail if the code were wrong?** A test that passes against a broken implementation is worse than none — it buys false confidence. Mentally break the code and check.
- **Asserts an outcome.** No assertion, or asserting only that nothing threw, is a smoke test being sold as coverage.
- **Descriptive name** stating the scenario and expected result.
- **Edge cases covered**, not just the happy path.
- **Bug fix without a regression test** — the fix is unverified and the bug can return.

## Smells

- **Logic in the test** — branching or loops mean the test itself needs testing. Prefer parameterized cases.
- **Over-mocking** — everything mocked means the test verifies the mocks, not the system.
- **Shared mutable state between tests**, creating order dependence.
- **Assertion on a value the test itself computed** the same way as the code.
- **Snapshot blobs** accepted without review, or regenerated to make a failure go away.
- **Skipped/`only` left in** — `it.skip`, `describe.only`, `test.only`, commented-out cases.
- **Hidden coupling to test-run order or wall-clock time.**

## Playwright / E2E

- **`waitForTimeout` / arbitrary sleeps** — replace with a web-first assertion or a state-based wait. A sleep is a flake waiting to happen.
- **`nth()` / `.first()` / hardcoded indices** — positional locators re-target silently when a list reorders or an item is inserted, so the action lands on a different row than the one the test names. Playwright documents `.first()` as the legitimate escape hatch for a strict-mode violation, so flag it only where the repo's own rules ban it — not as a universal smell.
- **Locator declared inline** instead of on the Page Object, when the repo uses POM.
- **Assertion that cannot fail** — `expect(locator)` with no matcher, or `toBeVisible()` on something always present.
- **Cleanup not registered at creation.** An entity created mid-test must be queued for teardown immediately, not at the end — the test may never reach the end.
- **Test depends on another test's leftover data**, or on a fixed record that another run mutates.
- **Hardcoded environment values** — URLs, credentials, tenant ids that only resolve in one env.
- **A silent no-op interaction.** Not the hidden-element case — `.click()`/`.fill()` wait for visible/enabled/editable and then throw. The silent failure is a stale locator resolving to the **wrong visible element** (a `text=`/placeholder selector that now matches something else, a drifted index): the action lands harmlessly, the field stays empty, and it looks identical to the app failing to populate it. Assert post-interaction state (`toHaveValue`, the resulting control appearing), not that the selector resolved.

Repo conventions override everything here. Check `CLAUDE.md` and `.claude/rules/` for the project's own locator, waiting, and cleanup rules first.
