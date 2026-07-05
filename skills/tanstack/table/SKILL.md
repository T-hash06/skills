---
name: tanstack-table
description: "Build, debug, refactor, review, or document TanStack Table implementations across frameworks, especially React, using official TanStack Table documentation as the source of truth. Use for table architecture, data and column modeling, row models, rendering, table state, sorting, filtering, faceting, grouping, expanding, pagination, row selection, pinning, sizing, visibility, ordering, virtualization, custom features, performance, best practices, antipatterns, or TanStack Table APIs."
---

# TanStack Table

Use this skill to produce production-grade TanStack Table work from the official documentation first, then adapt the result to the user's framework, data model, UI conventions, performance constraints, and table UX requirements.

## Core Workflow

1. Identify the framework adapter, installed package version if available, row data shape, server/client ownership model, table features, persistence needs, and UI component system.
2. Open [references/official-docs.md](references/official-docs.md) and route to the relevant official TanStack Table guide or API reference before relying on memory.
3. Open [references/practices.md](references/practices.md) when designing, reviewing, refactoring, or debugging non-trivial tables. Use it for good practices, antipatterns, production examples, and advanced feature interactions.
4. Define the row data type, stable `data` source, stable `columns`, column IDs, row IDs, and table state ownership before wiring feature UI.
5. Decide whether each feature is client-side or server-side. Keep sorting, filtering, grouping, faceting, and pagination consistent across the same dataset.
6. Add only the row models required by enabled client-side features. Start with `getCoreRowModel`, then add filtered, grouped, sorted, expanded, pagination, and faceting row models as needed.
7. Control only the state that the app needs to persist, synchronize, query, or inspect. Leave the rest internal.
8. Render with adapter utilities such as `flexRender`, visibility-aware cell APIs, accessible markup, and the host app's components.
9. Run focused tests or provide exact test guidance for row counts, sorting/filtering output, server query params, pagination boundaries, selected IDs, visibility/pinning/sizing state, grouping/expansion output, and virtualization behavior.

## Documentation Routing

Use [references/official-docs.md](references/official-docs.md) as the official upstream map. It lists every TanStack Table documentation link with a short "contains" and "use when" note.

Use the notes as routing help only. Prefer the linked official docs over memory whenever behavior, option names, method names, or API signatures matter.

Use this reading order for most tasks:

1. Read installation and framework adapter docs when setup, imports, package names, or React integration are involved.
2. Read core concept guides for data, column definitions, tables, row models, rows, cells, headers, and state.
3. Read [references/practices.md](references/practices.md) for production patterns, antipatterns, and advanced examples when the table is larger than a tiny static display.
4. Read the feature guide for the requested behavior: sorting, filtering, faceting, grouping, expanding, pagination, selection, ordering, visibility, pinning, sizing, virtualization, or custom features.
5. Read the matching API reference before finalizing option names, method names, state shapes, handler signatures, and return types.

## Practice Priorities

- Treat TanStack Table as a headless table engine. Let the host app own semantic markup, layout, styling, accessibility, menus, inputs, buttons, and empty/loading/error states.
- Keep `data` and `columns` stable in React. Avoid inline arrays, inline fallbacks, and column definitions recreated on every render.
- Make column IDs explicit when using `accessorFn`, computed columns, display columns, persisted state, column visibility, ordering, grouping, pinning, sizing, or server query contracts.
- Use accessors for values that participate in sorting, filtering, grouping, and faceting. Use `cell` renderers for presentation.
- Use stable domain IDs with `getRowId` when rows can be selected, expanded, updated, reordered, paginated manually, or synced to APIs.
- Keep client-side and server-side feature ownership consistent. Do not client-sort a single loaded page while server-paginating the full dataset unless that partial-sort UX is intentional and clearly named.
- Use visibility-aware APIs such as `row.getVisibleCells()` when column visibility is enabled.
- Prefer pagination for page-oriented workflows, virtualization for continuous scrolling over large loaded datasets, and server pagination for datasets that cannot reasonably be loaded.

## Antipattern Alerts

- Do not define `data`, `columns`, or `data ?? []` inline in React table components.
- Do not pass both `initialState.someFeature` and `state.someFeature`; controlled `state` overrides `initialState`.
- Do not provide `onSortingChange`, `onPaginationChange`, or another `on[State]Change` without also passing the matching `state` value.
- Do not fully control all table state by default. High-frequency state such as `columnSizingInfo` can create avoidable performance problems.
- Do not use row indexes as row IDs for row selection or server-side pagination.
- Do not render hidden columns with `row.getAllCells()` when column visibility is active.
- Do not expect `getSelectedRowModel()` to include selected rows outside the current `data` array during `manualPagination`.
- Do not return objects or arrays from accessor functions unless custom sorting/filtering/grouping functions handle those values.
- Do not add expensive row models or faceting helpers when the app is using manual server-side behavior.
- Do not assume TanStack Table includes virtualization. Use TanStack Virtual or another virtualization library.

## Advanced Topics

Read the dedicated official guide and [references/practices.md](references/practices.md) before implementing these:

- Server-driven tables with TanStack Query and controlled sorting/filtering/pagination.
- Fuzzy filtering and rank-aware fuzzy sorting.
- Faceted filters with client-side row models or server-provided facet values.
- Selection across manual pagination and bulk actions by stable row ID.
- Column visibility, ordering, pinning, and sizing with persisted user preferences.
- Grouping with aggregation and expansion.
- Virtualized rows/columns or infinite scrolling.
- Editable tables using `table.options.meta`.
- Reusable custom features with `_features` and declaration merging.

## Maintenance

Run one or more static validators after editing [references/official-docs.md](references/official-docs.md):

```bash
bash <path_to_skill>/scripts/validate-doc-links.sh
fish <path_to_skill>/scripts/validate-doc-links.fish
pwsh -File <path_to_skill>/scripts/validate-doc-links.ps1
```

Each validator compares every URL in the annotated documentation map against the embedded expected official-doc list, fails on missing links, extra links, duplicates, missing section headings, or missing annotations, and does not use the network.

After changing the skill, run the repository or skill validation available in the current workspace. If no project-level validation exists, run the documentation-link validator and the system `quick_validate.py` script for this skill folder.
