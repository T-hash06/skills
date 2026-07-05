# Official TanStack Table Documentation Map

Use this map to choose which official upstream documentation to load. Each entry has a brief routing note only; open the linked official document for current API details, examples, and exact option names.

## Table of Contents

- [Setup and Adapters](#setup-and-adapters)
- [Core Concepts and Rendering](#core-concepts-and-rendering)
- [Column Feature Guides](#column-feature-guides)
- [Filtering and Faceting Guides](#filtering-and-faceting-guides)
- [Row and Data Feature Guides](#row-and-data-feature-guides)
- [Core API Reference](#core-api-reference)
- [Feature API Reference](#feature-api-reference)

## Setup and Adapters

### Installation

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/installation.md
  - Contains: Package installation commands for React, Vue, Solid, Svelte, Qwik, Angular, Lit, and table-core adapters.
  - Use when: Choosing the correct package, checking supported framework versions, or setting up TanStack Table in a new project.

### React Table

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/framework/react/react-table.md
  - Contains: The React adapter entry point, especially `useReactTable` and its relationship to core table options.
  - Use when: Wiring TanStack Table into React, confirming imports, or checking React-specific table creation.

## Core Concepts and Rendering

### Data Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/data.md
  - Contains: Data shape expectations, stable references, TypeScript generics, nested/sub-row data, and how `data` flows into the table.
  - Use when: Modeling row data, debugging rerenders, typing table data, or implementing hierarchical rows.

### Column Definitions Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-defs.md
  - Contains: Column definition types, column helpers, accessor keys, accessor functions, IDs, headers, cells, footers, and nested columns.
  - Use when: Designing columns, computed values, grouped columns, custom cells, or stable column IDs.

### Table Instance Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/tables.md
  - Contains: Table instance creation, table options, data and columns input, table APIs, and framework-specific creation functions.
  - Use when: Creating or refactoring the main table instance and deciding which options belong in the table config.

### Row Models Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-models.md
  - Contains: The row-model pipeline, `getCoreRowModel`, feature row models, pre-models, and final row access patterns.
  - Use when: Adding sorting, filtering, grouping, expansion, pagination, or understanding why displayed rows differ from raw data.

### Rows Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/rows.md
  - Contains: Row objects, row IDs, original data, row values, unique values, sub-rows, and row access patterns.
  - Use when: Rendering rows, customizing `getRowId`, reading row values, or debugging nested row behavior.

### Cells Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/cells.md
  - Contains: Cell objects, cell IDs, cell contexts, value access, render fallback values, and `flexRender`.
  - Use when: Rendering body cells, passing context to cell renderers, or distinguishing accessor values from rendered output.

### Header Groups Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/header-groups.md
  - Contains: Header group structure, header group IDs, header depths, and header arrays from the table instance.
  - Use when: Rendering multi-level headers or debugging grouped header rows.

### Headers Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/headers.md
  - Contains: Header objects, placeholder headers, `colSpan`, header context, footer context, and `flexRender` for headers.
  - Use when: Rendering header cells, grouped columns, placeholders, or footers.

### Columns Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/columns.md
  - Contains: Column object structure, parent-child relationships, flat and leaf columns, and column access methods.
  - Use when: Traversing columns, building column menus, working with nested columns, or reading column metadata.

### Table State React Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/framework/react/guide/table-state.md
  - Contains: React-specific table state, `initialState`, controlled state, individual state callbacks, and `onStateChange`.
  - Use when: Controlling sorting, filtering, pagination, selection, or other table state from React components or server queries.

## Column Feature Guides

### Column Ordering Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-ordering.md
  - Contains: Column order state, initial column order, controlled ordering, and drag-and-drop integration guidance.
  - Use when: Reordering columns, persisting user column order, or integrating DnD libraries.

### Column Pinning Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-pinning.md
  - Contains: Left, right, and center column pinning concepts, column pinning state, and interactions with column order.
  - Use when: Implementing frozen columns, split table layouts, or sticky left/right columns.

### Column Sizing Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-sizing.md
  - Contains: Column size state, resize modes, resize direction, performant resizing patterns, and size APIs.
  - Use when: Adding resizable columns, fixed widths, RTL resizing, or high-performance resize rendering.

### Column Visibility Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-visibility.md
  - Contains: Visibility state, hiding controls, default visibility, and visible column APIs.
  - Use when: Building show/hide column menus, persisted visibility preferences, or columns that cannot be hidden.

## Filtering and Faceting Guides

### Column Filtering Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-filtering.md
  - Contains: Per-column filters, client-side versus manual server-side filtering, filter state, filter functions, and custom filters.
  - Use when: Adding column filter inputs, server-side filtering, custom filter logic, or filter state synchronization.

### Global Filtering Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/global-filtering.md
  - Contains: Table-wide global filtering, client-side and manual filtering, global filter state, and filter functions.
  - Use when: Building search boxes that filter across columns or moving global search to the server.

### Fuzzy Filtering Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/fuzzy-filtering.md
  - Contains: Fuzzy filtering concepts, ranking metadata, match-sorter integration, and fuzzy sorting follow-up.
  - Use when: Implementing search by relevance, ranked filter results, or fuzzy sort behavior.

### Column Faceting Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-faceting.md
  - Contains: Column faceted row models, unique values, min/max values, and using faceted data to build filter UIs.
  - Use when: Building value pickers, range filters, autocomplete filters, or filter suggestions for a specific column.

### Global Faceting Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/global-faceting.md
  - Contains: Global faceted row models and global unique/min-max faceting helpers.
  - Use when: Building global faceted search experiences or server-backed global facet data.

## Row and Data Feature Guides

### Grouping Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/grouping.md
  - Contains: Grouping state, grouped columns, aggregation behavior, grouped rows, and expansion with grouped data.
  - Use when: Grouping rows by one or more columns, adding aggregations, or rendering grouped table sections.

### Expanding Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/expanding.md
  - Contains: Expanded state, sub-rows, custom expandable rows, filtering expanded data, and pagination interactions.
  - Use when: Building tree tables, detail panels, nested rows, or expandable grouped rows.

### Pagination Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/pagination.md
  - Contains: Client-side pagination, manual server-side pagination, pagination state, page count, row count, and pagination APIs.
  - Use when: Adding page controls, server pagination, row count handling, or deciding between pagination and virtualization.

### Row Pinning Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-pinning.md
  - Contains: A short guide entry that routes to row pinning examples and the row pinning API.
  - Use when: Pinning rows to the top or bottom and deciding whether the API reference is needed.

### Row Selection Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-selection.md
  - Contains: Row selection state, useful row IDs, checkbox handlers, conditional selection, multi-selection, and sub-row selection.
  - Use when: Adding selectable rows, bulk actions, controlled selection, or checkbox selection UIs.

### Sorting Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/sorting.md
  - Contains: Sorting state, client-side and manual sorting, sorting functions, multi-sort behavior, removal behavior, and sorting UI hooks.
  - Use when: Adding sortable columns, server-side sorting, custom sorting functions, or multi-sort keyboard behavior.

### Virtualization Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/virtualization.md
  - Contains: A short routing guide for using TanStack Virtual or another virtualization library with TanStack Table.
  - Use when: Large datasets need virtualized rows or columns instead of rendering every row.

### Custom Features Guide

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/guide/custom-features.md
  - Contains: Custom feature extension patterns, declaration merging, feature state, defaults, APIs, and hooks into table creation.
  - Use when: Extending TanStack Table beyond built-in features or adding reusable table behavior across an app.

## Core API Reference

### ColumnDef APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/column-def.md
  - Contains: Exact `ColumnDef` options such as `id`, `accessorKey`, `accessorFn`, `columns`, `header`, `footer`, `cell`, and `meta`.
  - Use when: Verifying column definition option names, types, or renderer signatures.

### Table APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/table.md
  - Contains: Core table options and table instance APIs, including data, columns, state, initialState, debug flags, reset behavior, and row models.
  - Use when: Confirming table option names, table methods, state update APIs, or framework adapter creation signatures.

### Column APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/column.md
  - Contains: Column object properties and methods such as IDs, depth, parent columns, column defs, flat columns, and leaf columns.
  - Use when: Reading or manipulating column objects from the table instance.

### HeaderGroup APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/header-group.md
  - Contains: Header group properties such as `id`, `depth`, and `headers`.
  - Use when: Rendering or typing header group rows.

### Header APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/header.md
  - Contains: Header properties, placeholder fields, `colSpan`, header contexts, and table header/footer group APIs.
  - Use when: Verifying header rendering properties or header/footer group table methods.

### Row APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/row.md
  - Contains: Row properties and methods such as `id`, `index`, `original`, `depth`, `getValue`, `renderValue`, parent rows, leaf rows, and cells.
  - Use when: Confirming row method names or row object fields in renderers and feature logic.

### Cell APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/cell.md
  - Contains: Cell properties and methods such as `id`, `row`, `column`, `getValue`, `renderValue`, and `getContext`.
  - Use when: Typing or rendering cells and validating cell context shape.

## Feature API Reference

### Column Filtering APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-filtering.md
  - Contains: Column filter state, built-in filter functions, filter function signatures, column options, row metadata, table options, and table APIs.
  - Use when: Verifying exact filter function names, filter state shape, or column/table filter APIs.

### Column Faceting APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-faceting.md
  - Contains: Column faceting APIs for faceted row models, unique values, min/max values, and table faceting options.
  - Use when: Implementing faceted column filters or checking faceting method names.

### Column Ordering APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-ordering.md
  - Contains: Column order state, `onColumnOrderChange`, `setColumnOrder`, reset APIs, and index helpers.
  - Use when: Controlling column order or checking ordering table and column APIs.

### Column Pinning APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-pinning.md
  - Contains: Column pinning state, enable flags, pinning table APIs, column pin APIs, split header APIs, and row pinned-cell APIs.
  - Use when: Implementing pinned columns or verifying left, right, and center column APIs.

### Column Sizing APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-sizing.md
  - Contains: Column sizing state, resize options, column resize APIs, header resize handlers, and total size helpers.
  - Use when: Building resizable columns or confirming sizing state and handler names.

### Column Visibility APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-visibility.md
  - Contains: Visibility state, enable-hiding options, column visibility APIs, table visibility APIs, and visible cell/column row APIs.
  - Use when: Building column toggles or checking visibility methods and state shape.

### Global Faceting APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/global-faceting.md
  - Contains: Global faceted row model, global unique values, and global min/max table APIs.
  - Use when: Implementing global faceted search or verifying global faceting method names.

### Global Filtering APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/global-filtering.md
  - Contains: Global filter state, built-in and custom filter functions, global filter column options, row metadata, and table APIs.
  - Use when: Implementing global search or checking global filter state and callback names.

### Sorting APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/sorting.md
  - Contains: Sorting state, built-in sorting functions, column sorting options, column APIs, table sorting options, and table APIs.
  - Use when: Verifying sorting function names, multi-sort options, toggle APIs, or sorting state shape.

### Grouping APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/grouping.md
  - Contains: Grouping state, aggregation functions, grouped column options, grouped row APIs, grouping table options, table APIs, and grouped cell APIs.
  - Use when: Implementing row grouping, aggregations, grouped renderers, or checking grouping method names.

### Expanding APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/expanding.md
  - Contains: Expanded state, row expand APIs, expansion options, expanded row models, reset APIs, and toggle handlers.
  - Use when: Implementing expandable rows, detail panels, tree tables, or verifying expansion state APIs.

### Pagination APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/pagination.md
  - Contains: Pagination state, manual pagination options, page count, row count, page navigation APIs, and reset APIs.
  - Use when: Building pagination controls or confirming server pagination state and table methods.

### Row Pinning APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/row-pinning.md
  - Contains: Row pinning state, enable flags, top/bottom row APIs, row pinning table APIs, and row pin methods.
  - Use when: Pinning rows to the top or bottom or checking row pin state and methods.

### Row Selection APIs

- Link: https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/row-selection.md
  - Contains: Row selection state, selection enable options, table selection APIs, selected row models, and row selection methods.
  - Use when: Implementing selectable rows, checkbox handlers, selected row models, or controlled selection state.
