# Structural Smells

Fowler baseline (_Refactoring_, ch.3). Each entry is a labelled heuristic ("possible Feature Envy"), never a hard violation. Report as Should fix or Nit, never Blocker.

## Catalogue

| Smell | What it is | Fix |
|---|---|---|
| Mysterious Name | Function, variable, or type whose name does not reveal what it does or holds | Rename. No honest name comes → the design is murky |
| Duplicated Code | Same logic shape in more than one hunk or file in the change | Extract the shared shape, call from both |
| Feature Envy | Method reaching into another object's data more than its own | Move the method onto the data it envies |
| Data Clumps | Same few fields/params keep travelling together | Bundle into one type, pass that |
| Primitive Obsession | Primitive or string standing in for a domain concept | Give the concept its own small type |
| Repeated Switches | Same `switch`/`if`-cascade on the same type recurs across the change | Polymorphism, or one map both sites share |
| Shotgun Surgery | One logical change forces scattered edits across many files | Gather what changes together into one module |
| Divergent Change | One file edited for several unrelated reasons | Split so each module changes for one reason |
| Speculative Generality | Abstraction, params, or hooks for needs the spec does not have | Delete. Inline back until a real need shows |
| Message Chains | Long `a.b().c().d()` navigation the caller should not depend on | Hide the walk behind one method on the first object |
| Middle Man | Class or function that mostly just delegates onward | Cut it, call the real target direct |
| Refused Bequest | Subclass ignoring or overriding most of what it inherits | Drop inheritance, use composition |

## Structural remedies

Flagging a structural problem without naming the move leaves the author guessing. Propose one:

- Chain of conditionals → typed model or explicit dispatcher.
- Duplicate branches → one clearer flow.
- Orchestration tangled with business logic → separate so each reads on its own.
- Feature logic in a shared module → move to the package owning the concept.
- Bespoke near-duplicate → reuse the canonical helper.
- Implicit type boundary → make it explicit; downstream branching disappears.
- Pass-through wrapper adding indirection → delete it.
- Large file → extract helpers, split into focused modules.

Prefer the remedy that removes moving pieces over one that spreads the same complexity around.

## Size signals

| Changed lines | Read |
|---|---|
| ~100 | Reviewable in one sitting |
| ~300 | Acceptable if one logical change |
| ~1000 | Too large → ask the author to split |

Exception: complete file deletions and mechanical refactors, where the reviewer verifies intent, not every line.

**Watch total file size, not just diff size.** A file already past several hundred lines is an inspection signal, not a hard cap. A change that materially grows one → ask whether to extract first, then add.

**Refactoring + new behavior in one change = two changes.** Small cleanups (renames) can ride along at reviewer discretion.
