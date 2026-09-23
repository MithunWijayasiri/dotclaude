# API Review

## Contract

- **Breaking change with no migration path** — removing or renaming a field, narrowing a type, making an optional parameter required, changing a default. Consumers break silently.
- **Response shape changed for one caller's benefit**, affecting every other consumer.
- **New required request field** with no default, added to an endpoint with existing clients.
- **Enum value added** where clients switch exhaustively.
- **Versioning skipped** on a genuinely breaking change.
- **Payload property casing changed.** A "tidy-up" rename to camelCase breaks a consumer that expects the original casing — verify against the consumer.

## Validation & boundaries

- **Request body parsed straight into a domain object** with no schema check.
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
const res: any = await http.post('/users/search', body);
return res.data.users;

// Good: shape declared
type UserSearchResponse = { users: User[] };
const res = await http.post<UserSearchResponse>('/users/search', body);
return res.data.users;
```

- **Generic typed as the envelope.** With axios, `post<T>` types the body, so `res.data` is `T` — putting the envelope in `T` yields `res.data.data`. Check whether the project's `http` wrapper already unwraps `.data`.
- **Non-2xx not distinguished from a network failure.**
