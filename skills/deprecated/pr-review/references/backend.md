# Backend Review

## Stack-agnostic checks

- **Error handling that hides failure.** A `catch` that logs and continues, returns a default, or swallows the error leaves the caller believing it succeeded. Fail fast unless the recovery is deliberate and documented.
- **Partial writes with no rollback.** A multi-step mutation that can fail halfway leaves inconsistent state — wrap in a transaction or make it idempotent.
- **Retry without backoff or a cap**, and retries on non-retryable errors (4xx, validation).
- **No timeout on an outbound call.** A hung dependency becomes a hung request.
- **Config read at call time instead of startup**, so a missing env var surfaces mid-request rather than at boot.
- **Non-idempotent job or message consumer** on a path that can be retried or replayed.
- **Time and timezone** — naive local-time arithmetic, DST assumptions, comparing instants across zones.

## TypeScript / Node

```ts
// Bad: unbounded concurrency — every request fires at once
await Promise.all(ids.map(id => fetchRecord(id)));

// Good: bounded
for (const batch of chunk(ids, 10)) {
  await Promise.all(batch.map(id => fetchRecord(id)));
}
```

- **Floating promises** — an async call neither awaited nor `.catch`-routed. Lint (`no-floating-promises`) usually catches the bare call; it does not catch `void processQueue()`, which silences the linter while the rejection stays unhandled. Flag `void` when the promise can fail in a way anyone cares about.
- **Non-null assertion (`!`)** on a value that can legitimately be null — it moves the crash further from the cause.
- **`Promise.all` where one rejection should not abort the rest** — use `allSettled` and report per-item outcomes.
- **`async` function whose body has no `await`** — usually a forgotten one.
- **Unhandled rejection in an event handler or callback** passed to a non-promise-aware API.
- **Mutating a shared module-level object** — in a long-lived process this is cross-request state.
- **Silent `catch { return null }`** — the caller cannot distinguish "not found" from "call failed".
