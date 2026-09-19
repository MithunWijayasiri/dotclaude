# Performance Review

Read when the diff touches database queries, loops over remote calls, list endpoints, or hot paths.

## Checks

- **N+1** — one query or request per item in a loop. Batch, join, or eager-load. ORM example in `database.md`.
- **Unbounded operations** — loops or fetches with no limit on an input that can grow.
- **Algorithmic complexity** — O(n^2) on unbounded data in a hot path.
- **Blocking I/O** where the surrounding code is async, or sync work on a request path.
- **Resource leaks** — unclosed handles and connections. UI teardown lives in `frontend.md`.
- **Large objects allocated in hot paths**; unnecessary copies of big structures.

## Reporting rule

Quantify where possible. "This N+1 will add ~50ms per item in the list" beats "this could be slow."

No number available → state the growth relationship instead: "one query per line item; an order carries up to 50."
