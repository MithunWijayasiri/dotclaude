# API Review

Read when the diff touches HTTP handlers, route definitions, request/response shapes, clients, or API contracts.

Auth and injection checks live in `security.md`. This file holds contract- and boundary-level patterns.

## Contract

- **Breaking change with no migration path** — removing or renaming a field, narrowing a type, making an optional parameter required, changing a default. Consumers break silently.
- **Response shape changed for one caller's benefit**, affecting every other consumer.
- **New required request field** with no default, added to an endpoint with existing clients.
- **Enum value added** where clients switch exhaustively.
- **Versioning skipped** on a genuinely breaking change.

## Validation & boundaries

- **Request body parsed straight into a domain object** with no schema check — an untyped `any` crossing into business logic.
- **Over-permissive input** — mass assignment, or accepting fields the caller should not control (`role`, `ownerId`, `isAdmin`).
- **Response leaking internals** — full entity returned where a DTO was intended, exposing internal ids, flags, or other users' data.
- **Error responses leaking stack traces or SQL** to the client.

## Semantics

- **Status codes** — 200 with an error body; 500 for what is a client validation failure; 404 vs 403 leaking existence.
- **Non-idempotent `PUT`/`DELETE`**, or a `GET` with side effects.
- **No pagination** on a list endpoint, or pagination added without a stable sort — unstable ordering makes pages overlap and skip.
- **Partial success reported as success** — a batch endpoint returning 200 when some items failed, with no per-item outcome.

## Client-side

```ts
// Bad: response is `any`, every access below is unchecked
const res: any = await http.post('/customer/search', body);
return res.data.customers;

// Good: shape declared, failure visible
type CustomerSearchResponse = { customers: Customer[] };
const res = await http.post<CustomerSearchResponse>('/customer/search', body);
return res.data.customers;
```

The generic is the **body**, not the envelope — `axios.post<T>` returns `AxiosResponse<T>`, so `res.data` *is* `T`. Typing the envelope shape into the generic pushes the real path to `res.data.data`. Check whether the project's `http` is axios or a wrapper that already unwraps `.data`.

- Non-2xx not distinguished from a network failure.
- **Payload property casing changed.** Some external contracts use `PascalCase`; a "tidy-up" rename silently breaks the call — verify against the consumer rather than assuming camelCase.
