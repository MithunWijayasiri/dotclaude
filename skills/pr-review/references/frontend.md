# Frontend Review

## Stack-agnostic checks

- **State that should be derived is stored.** A value computable from existing state, kept in its own variable, will drift out of sync. In React: `useState` + `useEffect` → compute during render.
- **Work in render.** Sorting, filtering, or mapping a large list on every render instead of memoizing.
- **Unkeyed or index-keyed lists.** React matches children by key, so on insert, delete, or reorder an index key hands one item's state to a *different* item. A freshly generated key (`Math.random()`) is the opposite failure — state discarded on every render.
- **Loading and error states missing.** A fetch with only a success path renders blank or throws on failure.
- **Side effects without teardown.** Listeners, timers, observables, and sockets leak across navigation. React: `useEffect` with no returned cleanup. Angular: see below.
- **Accessibility regressions.** Click handler on a `div` with no keyboard path or role, form control with no label, focus lost after a modal closes.
- **Layout shift.** Images and async content inserted with no reserved space.
- **Bundle growth.** A heavy library imported wholesale for one function; a route not lazy-loaded.

## React

- **Stale closure** — a callback, interval, or subscription capturing state from the render it was created in. Missing effect dependencies are lint's job (`react-hooks/exhaustive-deps`); flag only when that rule is off, suppressed, or not configured for the custom hook (`additionalHooks`).
- **`useEffect` doing event-handler work.** Reacting to a user action belongs in the handler, not in an effect watching the resulting state.
- **Unstable props** — object/array/function literals passed to a memoized child defeat the memo.
- **Race in async effects** — no abort/ignore flag, so a slow earlier request overwrites a fast later one.

## Angular

- **Manual `.subscribe()` with no teardown.** Fix depends on version: `async` pipe anywhere, `takeUntil(destroy$)` universally, `takeUntilDestroyed` only on v16+ (`@angular/core/rxjs-interop`). Match what the repo already uses.
- **Function calls in templates** — `{{ compute() }}` re-runs on every change-detection cycle.
- **`OnPush` violated** — mutating an input object in place instead of replacing the reference; the view will not update.
- **Manual `detectChanges()`** — usually masks a missing `OnPush` reference change or work outside the zone.
- **Form control created but never wired** to the template, or a validator added without a matching error message.
- **`ngOnChanges` assumed to fire** for in-place mutations — it only fires on reference change.
