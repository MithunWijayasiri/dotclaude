---
name: zoom-out
description: Build a higher-level map of an unfamiliar code area. Use when you need to understand how modules, callers, data flow, boundaries, and project concepts fit together before changing code.
disable-model-invocation: true
---

# Zoom Out

Create an architectural map before explaining or changing an unfamiliar code area.

## Workflow

1. Identify requested area and nearest entry points.
2. Read relevant project instructions, glossary, architecture notes, and package
   configuration.
3. Trace imports, callers, message or data flow, and important side effects.
4. Inspect related tests and build/runtime boundaries.
5. Separate verified facts from assumptions and unknowns.
6. Do not edit files, run mutating commands, or propose implementation details
   until the map is complete.

## Response

Use concise labeled sections:

- **Purpose:** What the area does and why it exists.
- **Map:** Relevant modules and responsibilities.
- **Flow:** Control or data movement through the area.
- **Callers:** Important entry points and consumers.
- **Boundaries:** Browser, process, API, storage, build, or module boundaries.
- **Dependencies:** External services, shared utilities, configuration, and
  contracts.
- **Tests:** Relevant coverage and what it verifies.
- **Risks:** Coupling, side effects, fragile assumptions, or likely change points.
- **Unknowns:** Questions the codebase does not answer.
- **Summary:** One short mental model of the area.

Use project glossary and established names. Cite file paths and symbols for
non-obvious claims. Keep unrelated modules out of the map.
