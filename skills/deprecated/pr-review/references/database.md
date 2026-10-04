# Database Review

## Queries

N+1 in ORM form:

```ts
// Bad: one query per record
for (const order of orders) {
  const items = await db.orderItem.findMany({ where: { orderId: order.id } });
}

// Good: one query; bucket by orderId in memory if per-order lists are needed
const items = await db.orderItem.findMany({
  where: { orderId: { in: orders.map(o => o.id) } },
});
```

- **Eager-loading the world** — the opposite of N+1: `include` pulling relations nobody reads, on a hot path.
- **No `LIMIT`** on a query whose result set grows with data.
- **Filter or sort on an unindexed column** introduced by this change.
- **`SELECT *`** where the caller needs two columns and the row is wide.
- **Count-then-fetch races** — the count is stale by the time the fetch runs.
- **ORM chain that generates a surprising query.** Read the generated SQL, not the fluent chain — a filter applied after an aggregate or across a join often produces something other than what it reads like.

## Transactions

- **Missing transaction** around a multi-statement mutation that must be all-or-nothing.
- **Transaction held across a network call** — an external HTTP request inside a transaction holds locks for its full latency.
- **Wrong isolation assumption** — read-modify-write without a lock or an atomic update is a lost-update bug under concurrency.
- **Nested transaction** assumed to roll back independently.

## Migrations

- **Not backwards compatible with the running code.** Dropping or renaming a column in the same deploy that stops using it breaks during rollout — expand, migrate, contract.
- **No down migration**, or a down that loses data silently.
- **Blocking DDL on a large table.** On Postgres, an index built without `CONCURRENTLY` locks writes for the build, and a column added with a *volatile* default (`clock_timestamp()`, `random()`) rewrites every row while a constant default is metadata-only from v11. Other engines and older versions differ — confirm before calling any DDL safe.
- **Data backfill inside the schema migration** rather than a separate, resumable job.
- **New column nullable when the domain says it is required**, with no plan to tighten it.

## Schema

- Foreign keys and uniqueness constraints expressed in the database, not only in application code.
- Money stored as a decimal type, never a float.
- Timestamps stored with timezone, in UTC.
- Enum-like columns constrained, not free text.
