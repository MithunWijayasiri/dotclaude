# Frontend Review

Read when the diff touches components, templates, state, styling, or client-side routing.

Cross-cutting principles live in `performance.md` and `security.md`. This file holds UI-specific patterns.

## Stack-agnostic checks

- **State that should be derived is stored.** A value computable from existing state, kept in its own variable, will drift out of sync.
- **Work in render.** Sorting, filtering, or mapping a large list on every render instead of memoizing.
- **Unkeyed or index-keyed lists.** React matches children by key, so on insert, delete, or reorder an index key hands one item's state to a *different* item. A freshly generated key (`Math.random()`) is the opposite failure — state discarded on every render.
- **Loading and error states missing.** A fetch with only a success path renders blank or throws on failure.
- **Unsubscribed side effects.** Listeners, timers, observables, and sockets set up without teardown leak across navigation.
- **Accessibility regressions.** Click handler on a `div` with no keyboard path or role, form control with no label, focus lost after a modal closes.
- **Layout shift.** Images and async content inserted with no reserved space.
- **Bundle growth.** A heavy library imported wholesale for one function; a route not lazy-loaded.

## React

```tsx
// Bad: missing dependency — fetchData never re-runs when userId changes
useEffect(() => {
  fetchData(userId);
}, []);

// Good
useEffect(() => {
  fetchData(userId);
}, [userId]);
```

- **Stale closure** — a callback, interval, or subscription capturing state from the render it was created in.
- **Missing cleanup** — `useEffect` that subscribes, adds a listener, or starts a timer with no returned teardown.
- **`useEffect` doing event-handler work.** Reacting to a user action belongs in the handler, not in an effect watching the resulting state.
- **Unstable props** — object/array/function literals passed to a memoized child defeat the memo.
- **Derived state in `useState` + `useEffect`** — compute during render instead.
- **Race in async effects** — no abort/ignore flag, so a slow earlier request overwrites a fast later one.

## Angular

- **Unsubscribed observables** — a manual `.subscribe()` with no teardown. Idiomatic fixes depend on the project's Angular version: `async` pipe anywhere, `takeUntil(destroy$)` universally, `takeUntilDestroyed` only on v16+ (`@angular/core/rxjs-interop`). Match what the repo already uses.
- **Function calls in templates** — `{{ compute() }}` re-runs on every change-detection cycle.
- **`OnPush` violated** — mutating an input object in place instead of replacing the reference; the view will not update.
- **Manual `detectChanges()`** — usually masks a missing `OnPush` reference change or work outside the zone.
- **Form control created but never wired** to the template, or a validator added without a matching error message.
- **`ngOnChanges` assumed to fire** for in-place mutations — it only fires on reference change.
