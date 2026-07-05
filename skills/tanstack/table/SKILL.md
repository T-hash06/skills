---
name: tanstack-table
description: "Build, debug, refactor, or document TanStack Table implementations across frameworks, especially React, using official TanStack Table documentation links as the source of truth. Use for table instances, column definitions, row models, cells, headers, table state, sorting, filtering, faceting, grouping, pagination, selection, pinning, sizing, visibility, virtualization, custom features, or TanStack Table APIs."
---

# TanStack Table

Use this skill to work with TanStack Table from the official documentation first, then adapt the guidance to the user's framework, codebase, and table UX requirements.

## Documentation Index

Start with [references/official-docs.md](references/official-docs.md). It maps every official TanStack Table documentation link to a short "contains" and "use when" note so agents can decide which upstream docs to load for the task at hand.

Use the notes as routing help only. Prefer the linked official docs over memory whenever behavior, option names, or API signatures matter.

Use this reading order for most tasks:

1. Read installation and framework adapter docs when setup, imports, package names, or React integration are involved.
2. Read core concept guides for data, columns, tables, row models, rows, cells, headers, and state.
3. Read the feature guide for the requested behavior.
4. Read the matching API reference before finalizing option names, method names, and return types.

## Working Principles

- Treat TanStack Table as a headless table engine. Build rendering, styling, accessibility markup, and interaction surfaces in the host app's UI conventions.
- Prefer the current official docs over remembered v7 or older patterns. Confirm v8 APIs such as `useReactTable`, `getCoreRowModel`, feature row models, and table state options before coding.
- Keep `data` and `columns` stable in React implementations. Use memoization or stable module-level definitions when the surrounding code requires it.
- Define column IDs deliberately when using `accessorFn`, computed columns, grouping, visibility, ordering, filtering, or persisted user preferences.
- Add only the row models required by enabled features. Start with `getCoreRowModel`, then add sorting, filtering, grouping, expanding, pagination, or faceting models as needed.
- Decide early whether each feature is client-side or server-side. Use manual modes for server-owned sorting, filtering, pagination, grouping, or faceting instead of mixing incompatible row-model behavior.
- Control state only when the app needs to observe, persist, synchronize, or server-drive it. Otherwise prefer TanStack Table's internal state to keep the implementation smaller.
- Keep column definitions focused on data access and table semantics. Put bulky UI components, menus, and formatting helpers in surrounding components when that matches the codebase.
- Validate large datasets with virtualization guidance and the host UI constraints before adding expensive row models or rendering every row.
- Test table behavior at the feature boundary: row counts, column visibility, selected row IDs, sorted order, filter output, pagination state, and pinned or grouped output.

## Implementation Checklist

1. Identify the framework adapter, package version if available, data shape, and table ownership model.
2. Choose column definitions and row IDs before enabling features that depend on identity or persistence.
3. Build the smallest table instance that satisfies the request.
4. Add feature options one at a time and cross-check each with the relevant guide plus API page in [references/official-docs.md](references/official-docs.md).
5. Match rendering code to the app's existing component and accessibility patterns.
6. Run or propose focused tests for user-visible behavior and state transitions.

## Maintenance

Run one or more static validators after editing [references/official-docs.md](references/official-docs.md):

```bash
bash skills/tanstack/table/scripts/validate-doc-links.sh
fish skills/tanstack/table/scripts/validate-doc-links.fish
pwsh -File skills/tanstack/table/scripts/validate-doc-links.ps1
```

Each validator compares every URL in the annotated documentation map against the embedded expected official-doc list, fails on missing links, extra links, duplicates, missing section headings, or missing annotations, and does not use the network.
