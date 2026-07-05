# TanStack Table Practices and Antipatterns

Use this reference after routing through `official-docs.md`. It distills the official TanStack Table docs into practical production guidance for agents implementing, reviewing, or refactoring real tables and data grids.

## Table of Contents

- [Mental Model](#mental-model)
- [Model Data and Column IDs First](#model-data-and-column-ids-first)
- [Keep Data and Columns Stable](#keep-data-and-columns-stable)
- [Render Through the Table APIs](#render-through-the-table-apis)
- [Choose Row Models Deliberately](#choose-row-models-deliberately)
- [Control State Only When Needed](#control-state-only-when-needed)
- [Keep Client-Side and Server-Side Features Consistent](#keep-client-side-and-server-side-features-consistent)
- [Sorting, Filtering, Fuzzy Search, and Faceting](#sorting-filtering-fuzzy-search-and-faceting)
- [Pagination, Virtualization, and Infinite Data](#pagination-virtualization-and-infinite-data)
- [Row IDs, Selection, and Bulk Actions](#row-ids-selection-and-bulk-actions)
- [Column Visibility, Ordering, Pinning, and Sizing](#column-visibility-ordering-pinning-and-sizing)
- [Grouping, Aggregation, and Expanding](#grouping-aggregation-and-expanding)
- [Editable Tables and Table Meta](#editable-tables-and-table-meta)
- [Performance Practices](#performance-practices)
- [Custom Features](#custom-features)
- [Accessibility and UX](#accessibility-and-ux)
- [Testing and Debugging](#testing-and-debugging)
- [Review Checklist](#review-checklist)

## Mental Model

TanStack Table is a headless data-table engine. It computes table state, rows, cells, headers, and feature state. It does not ship a visual table, virtualizer, toolbar, data-fetching layer, accessibility wrapper, or design system.

Good TanStack Table code makes these decisions visible:

- What is one row of data?
- Which values are accessor values used by sorting, filtering, grouping, and faceting?
- Which columns are display-only?
- Which row IDs and column IDs are stable across renders, server pages, and persisted preferences?
- Which features are client-side and which are server-side?
- Which state is internal, controlled, persisted, URL-synced, or query-driven?
- Which row models are actually needed?

Antipattern:

```tsx
const table = useReactTable({
  data: rows,
  columns,
})
```

Better:

```tsx
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
})
```

Add feature row models and controlled state only when the feature needs them.

## Model Data and Column IDs First

Start with the row type and column definitions. The row type becomes `TData` for columns, rows, cells, filters, sorting functions, and table APIs.

Good data model:

```tsx
type InvoiceRow = {
  id: string
  customer: {
    name: string
    tier: 'enterprise' | 'team' | 'starter'
  }
  amountCents: number
  status: 'draft' | 'sent' | 'paid' | 'void'
  issuedAt: string
}
```

Good column model:

```tsx
const columnHelper = createColumnHelper<InvoiceRow>()

const columns = [
  columnHelper.display({
    id: 'select',
    enableHiding: false,
    cell: ({ row }) => <RowCheckbox row={row} />,
  }),
  columnHelper.accessor('customer.name', {
    id: 'customerName',
    header: 'Customer',
    cell: (info) => info.getValue(),
    filterFn: 'includesString',
  }),
  columnHelper.accessor('amountCents', {
    id: 'amount',
    header: 'Amount',
    cell: (info) => formatCurrency(info.getValue()),
    sortingFn: 'basic',
  }),
  columnHelper.accessor((row) => new Date(row.issuedAt), {
    id: 'issuedAt',
    header: 'Issued',
    cell: (info) => formatDate(info.getValue()),
    sortingFn: 'datetime',
  }),
  columnHelper.display({
    id: 'actions',
    enableHiding: false,
    cell: ({ row }) => <InvoiceActions invoice={row.original} />,
  }),
]
```

Practices:

- Use accessor columns for values that need sorting, filtering, grouping, or faceting.
- Use display columns for checkboxes, action menus, expand buttons, status icons, and other UI-only content.
- Give `accessorFn` columns explicit IDs. If no `id` is provided, a primitive string header can become the ID, which is fragile for i18n and copy changes.
- Make persisted column IDs stable and independent of display text.
- Return primitive accessor values when using built-in sorting/filtering. Return objects or arrays only with custom functions that know how to compare/filter/group them.

Antipatterns:

```tsx
// The accessor returns an object. Built-in sorting/filtering cannot infer useful behavior.
{
  id: 'customer',
  accessorFn: (row) => row.customer,
}
```

```tsx
// Header text becomes part of identity if no ID is provided.
columnHelper.accessor((row) => row.customer.name, {
  header: 'Customer',
})
```

Better:

```tsx
columnHelper.accessor((row) => row.customer.name, {
  id: 'customerName',
  header: 'Customer',
})
```

## Keep Data and Columns Stable

In React, `data` and `columns` must have stable references. TanStack Table reprocesses data when the `data` option changes reference. Inline arrays and inline fallbacks can create infinite rerenders or unnecessary expensive row-model work.

Bad:

```tsx
function InvoiceTable({ rows }: { rows?: InvoiceRow[] }) {
  const table = useReactTable({
    data: rows ?? [],
    columns: [
      { accessorKey: 'status', header: 'Status' },
    ],
    getCoreRowModel: getCoreRowModel(),
  })
}
```

Good:

```tsx
const fallbackData: InvoiceRow[] = []

function InvoiceTable({ rows }: { rows?: InvoiceRow[] }) {
  const columns = useMemo<ColumnDef<InvoiceRow>[]>(() => [
    { accessorKey: 'status', header: 'Status' },
  ], [])

  const table = useReactTable({
    data: rows ?? fallbackData,
    columns,
    getCoreRowModel: getCoreRowModel(),
  })
}
```

Good sources of stable data:

- `useState(() => initialRows)`
- `useMemo(() => transform(raw), [raw])`
- TanStack Query result arrays, if the query layer preserves references between unchanged results
- Module-level fallback arrays
- External stores such as Zustand or Redux, when selectors are stable

Antipatterns:

- `data: apiRows.map(normalizeRow)` directly inside `useReactTable`.
- `data: rows ?? []` with an inline fallback.
- Rebuilding columns every render because a cell renderer closes over changing component state. Move changing values into table state, `meta`, or memo dependencies deliberately.

## Render Through the Table APIs

Use the table instance to render headers and rows. Use `flexRender` for header, cell, and footer templates because column definitions may contain strings, JSX, or functions.

Good rendering:

```tsx
<table>
  <thead>
    {table.getHeaderGroups().map((headerGroup) => (
      <tr key={headerGroup.id}>
        {headerGroup.headers.map((header) => (
          <th key={header.id} colSpan={header.colSpan}>
            {header.isPlaceholder
              ? null
              : flexRender(
                  header.column.columnDef.header,
                  header.getContext(),
                )}
          </th>
        ))}
      </tr>
    ))}
  </thead>
  <tbody>
    {table.getRowModel().rows.map((row) => (
      <tr key={row.id}>
        {row.getVisibleCells().map((cell) => (
          <td key={cell.id}>
            {flexRender(cell.column.columnDef.cell, cell.getContext())}
          </td>
        ))}
      </tr>
    ))}
  </tbody>
</table>
```

Practices:

- Use `table.getRowModel().rows` for the final visible row model.
- Use `row.getVisibleCells()` when column visibility can change.
- Use `cell.getValue()` or `cell.renderValue()` for accessor values.
- Use `cell.row.original` for original data that is not transformed by the accessor.
- Use `row.getValue(columnId)` instead of recomputing accessors manually.
- Render placeholder headers as `null`.

Antipatterns:

- Rendering `row.original` fields directly for every cell and bypassing accessor semantics.
- Rendering hidden columns with `row.getAllCells()` when column visibility exists.
- Calling column `header` or `cell` functions manually instead of `flexRender`.
- Using array indexes as React keys instead of `row.id`, `header.id`, and `cell.id`.

## Choose Row Models Deliberately

TanStack Table is modular. Row models transform rows in a pipeline:

`getCoreRowModel` -> `getFilteredRowModel` -> `getGroupedRowModel` -> `getSortedRowModel` -> `getExpandedRowModel` -> `getPaginationRowModel` -> `getRowModel`

Add row models based on client-side features:

```tsx
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
  getSortedRowModel: getSortedRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
})
```

Practices:

- Always include `getCoreRowModel`.
- Include `getFilteredRowModel` only for client-side column/global filtering.
- Include `getSortedRowModel` only for client-side sorting.
- Include `getPaginationRowModel` only for client-side pagination.
- Include `getGroupedRowModel` for client-side grouping and aggregation.
- Include `getExpandedRowModel` for client-side expanding or grouped rows that users expand/collapse.
- Include faceting row models only when filter UIs need unique values or min/max values from client-side data.
- In manual server-side modes, pass already processed data and set the matching `manual*` option.

Antipatterns:

- Adding every row model to every table "just in case".
- Enabling `manualPagination` while still expecting `getPaginationRowModel` to paginate rows.
- Building custom filtering in render code instead of using row models or server query parameters.

## Control State Only When Needed

TanStack Table can manage state internally. Control only the state the application needs outside the table.

Use `initialState` for default internal state:

```tsx
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  initialState: {
    sorting: [{ id: 'issuedAt', desc: true }],
    columnVisibility: {
      internalNotes: false,
    },
  },
})
```

Use controlled state when the app must observe, persist, URL-sync, or server-drive the state:

```tsx
const [sorting, setSorting] = useState<SortingState>([])
const [pagination, setPagination] = useState<PaginationState>({
  pageIndex: 0,
  pageSize: 25,
})

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  state: {
    sorting,
    pagination,
  },
  onSortingChange: setSorting,
  onPaginationChange: setPagination,
})
```

Rules:

- Do not pass the same feature key in both `initialState` and `state`; controlled `state` wins.
- If you provide `on[State]Change`, pass the corresponding state value in `state`, or that state can freeze at its initial value.
- Updaters can be raw values or callback functions. Handle both when adding custom logic.
- Avoid fully controlled state unless necessary. Hoisting everything can harm performance, especially high-frequency state such as `columnSizingInfo`.

Good custom updater:

```tsx
onPaginationChange: (updater) => {
  setPagination((old) => {
    const next = typeof updater === 'function' ? updater(old) : updater
    analytics.track('table_page_changed', next)
    return next
  })
}
```

Antipattern:

```tsx
const table = useReactTable({
  data,
  columns,
  state: { sorting },
  initialState: {
    sorting: [{ id: 'createdAt', desc: true }],
  },
  onSortingChange: setSorting,
})
```

## Keep Client-Side and Server-Side Features Consistent

Choose feature ownership for the whole dataset, not one feature at a time in isolation.

Client-side table:

```tsx
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
  getSortedRowModel: getSortedRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
})
```

Server-side table:

```tsx
const [sorting, setSorting] = useState<SortingState>([])
const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])
const [pagination, setPagination] = useState<PaginationState>({
  pageIndex: 0,
  pageSize: 25,
})

const query = useQuery({
  queryKey: ['invoices', sorting, columnFilters, pagination],
  queryFn: () =>
    fetchInvoices({
      sorting,
      filters: columnFilters,
      pageIndex: pagination.pageIndex,
      pageSize: pagination.pageSize,
    }),
})

const table = useReactTable({
  data: query.data?.rows ?? fallbackData,
  columns,
  getCoreRowModel: getCoreRowModel(),
  manualSorting: true,
  manualFiltering: true,
  manualPagination: true,
  rowCount: query.data?.rowCount ?? 0,
  state: {
    sorting,
    columnFilters,
    pagination,
  },
  onSortingChange: setSorting,
  onColumnFiltersChange: setColumnFilters,
  onPaginationChange: setPagination,
})
```

Practices:

- Use `manualSorting` for server sorting and do not rely on `getSortedRowModel`.
- Use `manualFiltering` for server filtering and do not rely on `getFilteredRowModel`.
- Use `manualPagination` for server pagination and provide `rowCount` or `pageCount`.
- Reset or clamp `pageIndex` when filters reduce available pages.
- Include controlled table state in the query key so data refetches when table state changes.
- Decide whether facets are server-provided or client-derived. Do not derive facets from one loaded server page and present them as global counts.

Antipatterns:

- Client-side sorting a server-paginated page and labeling it as sorting the full dataset.
- Client-side filtering already-paginated server data and showing misleading row counts.
- Forgetting `rowCount` or `pageCount` with manual pagination.
- Passing `pageCount: -1` and then expecting `getCanNextPage()` to know when data ends. With unknown page count it can keep returning true.

## Sorting, Filtering, Fuzzy Search, and Faceting

Sorting state is `Array<{ id: string; desc: boolean }>`. Filtering state is an array of `{ id, value }` for column filters plus a separate `globalFilter`.

Good sortable header:

```tsx
<th
  key={header.id}
  colSpan={header.colSpan}
  aria-sort={
    header.column.getIsSorted() === 'asc'
      ? 'ascending'
      : header.column.getIsSorted() === 'desc'
        ? 'descending'
        : 'none'
  }
>
  <button
    type="button"
    disabled={!header.column.getCanSort()}
    onClick={header.column.getToggleSortingHandler()}
  >
    {flexRender(header.column.columnDef.header, header.getContext())}
    <SortIcon direction={header.column.getIsSorted()} />
  </button>
</th>
```

Good column filter input:

```tsx
function TextColumnFilter({ column }: { column: Column<InvoiceRow, unknown> }) {
  const value = (column.getFilterValue() ?? '') as string

  return (
    <input
      value={value}
      onChange={(event) => column.setFilterValue(event.target.value)}
      disabled={!column.getCanFilter()}
      placeholder="Filter..."
    />
  )
}
```

Use custom sorting for nullable or domain-specific values:

```tsx
const prioritySort: SortingFn<TaskRow> = (rowA, rowB, columnId) => {
  const order = { urgent: 0, high: 1, normal: 2, low: 3 } as const
  return order[rowA.getValue(columnId) as keyof typeof order] -
    order[rowB.getValue(columnId) as keyof typeof order]
}
```

Use fuzzy filtering when approximate match and relevance rank matter:

```tsx
const fuzzyFilter: FilterFn<InvoiceRow> = (row, columnId, value, addMeta) => {
  const itemRank = rankItem(row.getValue(columnId), value)
  addMeta({ itemRank })
  return itemRank.passed
}

const fuzzySort: SortingFn<InvoiceRow> = (rowA, rowB, columnId) => {
  const metaA = rowA.columnFiltersMeta[columnId]?.itemRank
  const metaB = rowB.columnFiltersMeta[columnId]?.itemRank
  const ranked = metaA && metaB ? compareItems(metaA, metaB) : 0
  return ranked === 0
    ? sortingFns.alphanumeric(rowA, rowB, columnId)
    : ranked
}
```

Use faceting for filter UIs based on table data:

```tsx
const statusOptions = Array.from(
  table.getColumn('status')?.getFacetedUniqueValues().keys() ?? [],
).sort()
```

Faceting requires row models:

```tsx
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getFilteredRowModel: getFilteredRowModel(),
  getFacetedRowModel: getFacetedRowModel(),
  getFacetedUniqueValues: getFacetedUniqueValues(),
  getFacetedMinMaxValues: getFacetedMinMaxValues(),
})
```

Antipatterns:

- Using fuzzy filtering without installing and importing `@tanstack/match-sorter-utils`.
- Setting `sortFn` instead of `sortingFn`; the column option is `sortingFn`.
- Forgetting that custom filter functions only run during client-side filtering.
- Building a facet menu from only the current server page while implying global facet counts.
- Not setting `sortDescFirst` for nullable columns whose type inference may be ambiguous.

## Pagination, Virtualization, and Infinite Data

Use pagination when users think in pages, exports, and page counts. Use virtualization when the dataset is loaded but too large to render all rows. Use server pagination when the dataset cannot reasonably be loaded or queried client-side.

Client pagination:

```tsx
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getPaginationRowModel: getPaginationRowModel(),
  initialState: {
    pagination: {
      pageIndex: 0,
      pageSize: 25,
    },
  },
})
```

Manual pagination:

```tsx
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  manualPagination: true,
  rowCount,
  state: { pagination },
  onPaginationChange: setPagination,
})
```

Pagination UI:

```tsx
<button type="button" onClick={() => table.firstPage()} disabled={!table.getCanPreviousPage()}>
  First
</button>
<button type="button" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
  Previous
</button>
<button type="button" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
  Next
</button>
<button type="button" onClick={() => table.lastPage()} disabled={!table.getCanNextPage()}>
  Last
</button>
<select
  value={table.getState().pagination.pageSize}
  onChange={(event) => table.setPageSize(Number(event.target.value))}
>
  {[10, 25, 50, 100].map((pageSize) => (
    <option key={pageSize} value={pageSize}>
      {pageSize}
    </option>
  ))}
</select>
```

Practices:

- With `manualPagination`, `data` must already be paginated.
- Provide `rowCount` when available; TanStack Table can calculate `pageCount` from `rowCount` and `pageSize`.
- When `autoResetPageIndex` is disabled, add your own logic to avoid empty pages after filtering or data changes.
- Use TanStack Virtual or another virtualization library for virtual rows/columns; TanStack Table itself does not virtualize.
- For infinite scrolling, coordinate fetch size, virtualizer overscan, scroll restoration, and row IDs.

Antipatterns:

- Rendering 50,000 DOM rows because TanStack Table can process 50,000 rows.
- Using both pagination and virtualization without a clear UX reason.
- Disabling `autoResetPageIndex` globally and leaving users stranded on empty pages.

## Row IDs, Selection, and Bulk Actions

Use `getRowId` whenever row identity matters.

```tsx
const [rowSelection, setRowSelection] = useState<RowSelectionState>({})

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getRowId: (row) => row.id,
  state: {
    rowSelection,
  },
  onRowSelectionChange: setRowSelection,
  enableRowSelection: (row) => row.original.status !== 'void',
})
```

Selection column:

```tsx
columnHelper.display({
  id: 'select',
  enableHiding: false,
  header: ({ table }) => (
    <Checkbox
      checked={table.getIsAllPageRowsSelected()}
      indeterminate={table.getIsSomePageRowsSelected()}
      onChange={table.getToggleAllPageRowsSelectedHandler()}
    />
  ),
  cell: ({ row }) => (
    <Checkbox
      checked={row.getIsSelected()}
      disabled={!row.getCanSelect()}
      onChange={row.getToggleSelectedHandler()}
    />
  ),
})
```

Practices:

- Use `getToggleAllPageRowsSelectedHandler` for page-scoped bulk actions.
- Use `getToggleAllRowsSelectedHandler` only when "all rows" really means every row in the table's current data model.
- For manual pagination, keep selected IDs in `rowSelection`; `getSelectedRowModel()` can only return rows present in the current `data` array.
- Use `row.getCanSelect()` to disable selection UI for non-selectable rows.
- Use `enableMultiRowSelection: false` for radio-style single selection.
- Decide how selected IDs behave when filters change or rows disappear.

Antipatterns:

- Using default row index IDs when rows are server-paginated or reorderable.
- Sending `table.getSelectedRowModel().rows` to a bulk API in manual pagination and losing selections from other pages.
- Letting disabled checkboxes appear selected without a clear explanation.

## Column Visibility, Ordering, Pinning, and Sizing

Use persistent, explicit column IDs before adding column preferences.

Visibility:

```tsx
const [columnVisibility, setColumnVisibility] = useState<VisibilityState>({
  internalNotes: false,
})

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  state: { columnVisibility },
  onColumnVisibilityChange: setColumnVisibility,
})
```

Visibility UI:

```tsx
{table.getAllLeafColumns().map((column) => (
  <label key={column.id}>
    <input
      type="checkbox"
      checked={column.getIsVisible()}
      disabled={!column.getCanHide()}
      onChange={column.getToggleVisibilityHandler()}
    />
    {column.id}
  </label>
))}
```

Ordering and pinning:

- Pinning splits columns into left, center, and right.
- `columnOrder` affects only unpinned center columns when pinning is active.
- Grouping can reorder or remove grouped columns depending on `groupedColumnMode`.
- Use `@dnd-kit/core` for React drag and drop unless the codebase has a strong existing alternative. The official docs warn against `react-dnd` for React 18 or newer.

Sizing:

```tsx
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  defaultColumn: {
    size: 180,
    minSize: 80,
    maxSize: 480,
  },
  columnResizeMode: 'onEnd',
})
```

For large React tables with resizing:

- Prefer `columnResizeMode: 'onEnd'` unless immediate resizing is required.
- Calculate column widths once and memoize them.
- Use CSS variables to pass sizes to cells.
- Memoize the table body while resizing.
- Use `columnResizeDirection: 'rtl'` for right-to-left layouts.

Antipatterns:

- Persisting visibility/order by header labels instead of stable IDs.
- Rendering hidden columns because body rows use `row.getAllCells()`.
- Expecting `columnOrder` to reorder pinned columns.
- Calling `column.getSize()` in every cell of a large table during every resize frame.

## Grouping, Aggregation, and Expanding

Grouping uses column IDs. It creates grouped rows and can aggregate leaf row values. Expansion lets users open grouped rows, sub-rows, or custom detail panels.

Client grouping:

```tsx
const [grouping, setGrouping] = useState<GroupingState>(['status'])

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getGroupedRowModel: getGroupedRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
  state: { grouping },
  onGroupingChange: setGrouping,
  groupedColumnMode: 'reorder',
})
```

Aggregation:

```tsx
columnHelper.accessor('amountCents', {
  id: 'amount',
  header: 'Amount',
  aggregationFn: 'sum',
  aggregatedCell: ({ getValue }) => formatCurrency(getValue<number>()),
  cell: ({ getValue }) => formatCurrency(getValue<number>()),
})
```

Sub-rows:

```tsx
type AccountRow = {
  id: string
  name: string
  children?: AccountRow[]
}

const table = useReactTable({
  data,
  columns,
  getSubRows: (row) => row.children,
  getCoreRowModel: getCoreRowModel(),
  getExpandedRowModel: getExpandedRowModel(),
})
```

Detail panel:

```tsx
{table.getRowModel().rows.map((row) => (
  <Fragment key={row.id}>
    <tr>
      {row.getVisibleCells().map((cell) => (
        <td key={cell.id}>
          {flexRender(cell.column.columnDef.cell, cell.getContext())}
        </td>
      ))}
    </tr>
    {row.getIsExpanded() ? (
      <tr>
        <td colSpan={row.getVisibleCells().length}>
          <InvoiceDetails invoice={row.original} />
        </td>
      </tr>
    ) : null}
  </Fragment>
))}
```

Practices:

- Keep `getSubRows` synchronous and cheap; it runs for every row and sub-row.
- Use `getRowCanExpand` for detail panels that do not use sub-row data.
- Use `filterFromLeafRows` and `maxLeafRowFilterDepth` intentionally for tree filtering.
- Use `paginateExpandedRows: false` only when expanded child rows should stay on the parent page.
- Use `manualGrouping` or `manualExpanding` only when the server has already shaped the data.

Antipatterns:

- Running async work in `getSubRows`; async functions are not supported.
- Grouping by display columns.
- Forgetting `getExpandedRowModel` when grouped rows need to expand.
- Rendering detail panels with `colSpan={row.getAllCells().length}` while column visibility is enabled.

## Editable Tables and Table Meta

Use `table.options.meta` to pass table-level helpers to cells without prop drilling. This is especially useful for editable data, formatting services, permission checks, and localization.

```tsx
declare module '@tanstack/react-table' {
  interface TableMeta<TData extends RowData> {
    updateRow: (rowId: string, patch: Partial<TData>) => void
    locale: string
  }
}

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  getRowId: (row) => row.id,
  meta: {
    locale,
    updateRow: (rowId, patch) => {
      setRows((old) =>
        old.map((row) =>
          row.id === rowId ? { ...row, ...patch } : row,
        ),
      )
    },
  },
})
```

Cell usage:

```tsx
columnHelper.accessor('status', {
  cell: ({ row, table, getValue }) => (
    <StatusSelect
      value={getValue<InvoiceRow['status']>()}
      onValueChange={(status) =>
        table.options.meta?.updateRow(row.id, { status })
      }
    />
  ),
})
```

Practices:

- Keep edit state local while typing, commit to table data on blur/save, and coordinate validation with the app's form strategy.
- Use row IDs rather than row indexes for updates.
- Reset pagination intentionally after data edits if edits can move rows through sorting/filtering.

Antipatterns:

- Mutating `row.original` directly.
- Closing over stale `data` in every cell instead of using `meta` or a stable update function.
- Updating rows by current visible index after sorting or filtering.

## Performance Practices

TanStack Table can process large datasets, but rendering and feature choices still matter.

Practices:

- Keep `data` and `columns` stable.
- Add only required row models.
- For server-owned features, avoid expensive client row models and derive query parameters from controlled state.
- Memoize expensive cell renderers and table bodies when needed.
- Use virtualization for large loaded datasets.
- Use CSS variables and memoized width calculations for column sizing.
- Avoid rendering heavyweight menus, charts, or forms in every cell until opened.
- Profile with realistic row counts, column counts, and cell content.
- Use debug flags only in development: `debugTable`, `debugHeaders`, `debugColumns`, `debugRows`, or `debugAll`.

Antipatterns:

- Optimizing TanStack row processing while the actual bottleneck is DOM rendering.
- Virtualizing rows with dynamic heights and no measurement strategy.
- Using fully controlled state as a default architecture for every table.
- Using faceting on high-cardinality columns without limiting or server-side support.

## Custom Features

Reach for custom features when an app needs reusable table behavior beyond built-ins and normal wrapper components are not enough.

Use custom features for:

- Shared density state and APIs.
- Reusable keyboard navigation.
- Organization-specific row actions.
- Cross-table preference persistence.
- Reusable feature defaults and table instance APIs.

Official custom feature shape:

- Define feature state, options, and instance APIs.
- Use declaration merging if the feature applies globally to TanStack Table types.
- Implement a `TableFeature` with `getInitialState`, `getDefaultOptions`, and creation hooks such as `createTable`, `createColumn`, `createRow`, or `createCell`.
- Add the feature through the `_features` table option.

Antipatterns:

- Adding a custom feature when a wrapper hook or component would be simpler.
- Using declaration merging casually; it affects table types broadly across the codebase.
- Adding properties to table instances with untyped casts.
- Reimplementing built-in sorting, filtering, selection, or sizing as custom features.

## Accessibility and UX

TanStack Table is headless, so accessibility belongs to the rendering layer.

Practices:

- Use semantic `<table>`, `<thead>`, `<tbody>`, `<tr>`, `<th>`, and `<td>` when the UI is tabular.
- Use `scope="col"` or equivalent semantics for column headers when appropriate.
- Use buttons for sortable headers, not clickable text without keyboard support.
- Reflect sort state with `aria-sort`.
- Label selection checkboxes, including select-page/select-all behavior.
- Distinguish page-scoped "select all" from dataset-wide "select all".
- Provide empty, loading, error, and filtered-empty states.
- Keep toolbar filters and pagination controls keyboard accessible.
- Preserve focus when hiding/reordering columns or changing pages.
- For virtualized tables, ensure keyboard navigation and screen reader behavior are acceptable for the product.

Antipatterns:

- Building a div grid without roles or keyboard behavior when semantic table markup would work.
- Hiding columns that currently contain keyboard focus without moving focus deliberately.
- Showing sort icons without exposing sort state.
- Making row click selection conflict with links, buttons, checkboxes, or menus inside the row.

## Testing and Debugging

Test behavior at feature boundaries, not just snapshots.

High-value tests:

- Stable `data` and `columns` do not create render loops.
- Accessor columns produce expected display values and sort/filter values.
- Client-side filtering, sorting, grouping, and pagination produce expected row counts.
- Manual server-side state produces the expected query params.
- Pagination buttons respect boundaries and known/unknown page counts.
- Row selection uses stable IDs and survives sorting/filtering/page changes according to product rules.
- Column visibility hides cells and headers via visible APIs.
- Column order, pinning, and grouping precedence is correct.
- Column resizing applies widths and does not rerender heavy bodies unnecessarily.
- Expanded rows render with the correct `colSpan` after visibility changes.
- Fuzzy search ranks and sorts expected matches.
- Facet counts match the selected client/server ownership model.

Debugging practices:

- Inspect `table.getState()` for controlled/internal state mismatches.
- Inspect `table.getRowModel()`, `getPreFilteredRowModel()`, `getPrePaginationRowModel()`, and related pre-row models to locate the pipeline step changing rows.
- Check column IDs when persisted visibility, sorting, or filters do not apply.
- Check `manual*` options when row models appear to do nothing.
- Use `debugTable` and related debug flags only in development.

## Review Checklist

Use this checklist during code review:

- `data` and `columns` are stable.
- Row type, column definitions, accessor values, and IDs are explicit.
- `accessorFn` columns have stable IDs.
- Display columns are not treated as sortable/filterable data columns.
- `getCoreRowModel` is present.
- Only required row models are included.
- Client/server ownership is consistent across sorting, filtering, pagination, grouping, and faceting.
- Controlled state includes matching `on[State]Change` callbacks and matching `state` values.
- `initialState` and `state` do not define the same feature key.
- Row selection uses `getRowId` when IDs matter.
- Manual pagination bulk actions do not rely only on `getSelectedRowModel()`.
- Visibility-aware rendering uses `row.getVisibleCells()` and header groups.
- Sorting/filtering UI uses table/column APIs instead of independent UI state.
- Pagination has `rowCount` or `pageCount` when manual.
- Pinning/order/grouping interactions are accounted for.
- Column sizing performance is considered for large React tables.
- Grouping and expanding use the required row models.
- Virtualization is implemented by TanStack Virtual or another library, not assumed from Table.
- Accessibility semantics are handled in the rendering layer.
- Tests cover the user-visible feature behavior changed by the work.
