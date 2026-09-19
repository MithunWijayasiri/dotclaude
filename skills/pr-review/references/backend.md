# Backend Review

Read when the diff touches services, handlers, jobs, CLIs, or any Node/server-side module.

Cross-cutting principles live in `performance.md` and `security.md`. This file holds service-side patterns.

## Stack-agnostic checks

- **Error handling that hides failure.** A `catch` that logs and continues, returns a default, or swallows the error leaves the caller believing it succeeded. Fail fast unless the recovery is deliberate and documented.
- **Partial writes with no rollback.** A multi-step mutation that can fail halfway leaves inconsistent state — wrap in a transaction or make it idempotent.
- **Retry without backoff or a cap**, and retries on non-retryable errors (4xx, validation).
- **No timeout on an outbound call.** A hung dependency becomes a hung request.
- **Unbounded concurrency** — `Promise.all` over an unbounded list fires every request at once.
- **Config read at call time instead of startup**, so a missing env var surfaces mid-request rather than at boot.
- **Secrets or PII in logs**, including whole request/response bodies logged at info level.
- **Non-idempotent handlers** on a path that can be retried or replayed.
- **Time and timezone** — naive local-time arithmetic, DST assumptions, comparing instants across zones.

## TypeScript / Node

```ts
// Bad: floating promise — rejection is unhandled, failure is invisible
processQueue();

// Handled: awaited, or rejection explicitly routed somewhere
await processQueue();
processQueue().catch(report);

// `void` only silences the linter. The rejection is still unhandled at
// runtime — flag it when the promise can fail in a way anyone cares about.
void processQueue();

// Bad: unbounded concurrency
await Promise.all(ids.map(id => fetchRecord(id)));

// Good: bounded, and failures are visible
for (const batch of chunk(ids, 10)) {
  await Promise.all(batch.map(id => fetchRecord(id)));
}
```

- **Floating promises** — an async call neither awaited nor explicitly handled.
- **`any` / `as` crossing a boundary.** An API response typed `any` makes every downstream access unchecked. Define the shape.
- **Non-null assertion (`!`)** on a value that can legitimately be null — it moves the crash further from the cause.
- **`Promise.all` where one rejection should not abort the rest** — use `allSettled` and report per-item outcomes.
- **`async` function whose body has no `await`** — usually a forgotten one.
- **Unhandled rejection in an event handler or callback** passed to a non-promise-aware API.
- **Mutating a shared module-level object** — in a long-lived process this is cross-request state.
- **Silent `catch { return null }`** — the caller cannot distinguish "not found" from "call failed".

## Needs a second look

Not defects — report on the `**Needs a second look:**` closing line (SKILL.md §7), not as a severity:

- Database schema modifications.
- API contract changes with no migration path.
- New framework or library adoption.
- Changes to performance-critical or security-sensitive paths.
