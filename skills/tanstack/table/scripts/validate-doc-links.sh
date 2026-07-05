#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd -- "$script_dir/.." && pwd)"
docs_file="$skill_dir/references/official-docs.md"

if [[ ! -f "$docs_file" ]]; then
  echo "Missing documentation map at $docs_file" >&2
  exit 1
fi

for dependency in grep sort uniq diff mktemp wc; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    echo "Missing required command: $dependency" >&2
    exit 1
  fi
done

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

expected="$tmp_dir/expected.txt"
raw="$tmp_dir/raw.txt"
actual="$tmp_dir/actual.txt"
actual_unique="$tmp_dir/actual-unique.txt"
duplicates="$tmp_dir/duplicates.txt"
unofficial="$tmp_dir/unofficial.txt"
diff_file="$tmp_dir/diff.txt"

cat > "$expected" <<'URLS'
https://raw.githubusercontent.com/tanstack/table/main/docs/installation.md
https://raw.githubusercontent.com/tanstack/table/main/docs/framework/react/react-table.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/data.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-defs.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/tables.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-models.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/rows.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/cells.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/header-groups.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/headers.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/columns.md
https://raw.githubusercontent.com/tanstack/table/main/docs/framework/react/guide/table-state.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-ordering.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-pinning.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-sizing.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-visibility.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-filtering.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/global-filtering.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/fuzzy-filtering.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-faceting.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/global-faceting.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/grouping.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/expanding.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/pagination.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-pinning.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-selection.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/sorting.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/virtualization.md
https://raw.githubusercontent.com/tanstack/table/main/docs/guide/custom-features.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/column-def.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/table.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/column.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/header-group.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/header.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/row.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/cell.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-filtering.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-faceting.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-ordering.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-pinning.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-sizing.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-visibility.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/global-faceting.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/global-filtering.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/sorting.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/grouping.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/expanding.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/pagination.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/row-pinning.md
https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/row-selection.md
URLS

sort -o "$expected" "$expected"
grep -Eo 'https?://[^[:space:]<>")]+' "$docs_file" | sed 's/[.)]$//' > "$raw" || true
sort "$raw" > "$actual"
sort -u "$actual" > "$actual_unique"
uniq -d "$actual" > "$duplicates"
grep -Ev '^https://raw\.githubusercontent\.com/tanstack/table/main/docs/' "$raw" > "$unofficial" || true

if [[ -s "$duplicates" ]]; then
  echo "Documentation map contains duplicate links:" >&2
  cat "$duplicates" >&2
  exit 1
fi

if [[ -s "$unofficial" ]]; then
  echo "Documentation map contains links outside the official raw TanStack Table docs path:" >&2
  cat "$unofficial" >&2
  exit 1
fi

required_headings=(
  "# Official TanStack Table Documentation Map"
  "## Setup and Adapters"
  "## Core Concepts and Rendering"
  "## Column Feature Guides"
  "## Filtering and Faceting Guides"
  "## Row and Data Feature Guides"
  "## Core API Reference"
  "## Feature API Reference"
)

for heading in "${required_headings[@]}"; do
  if ! grep -Fqx "$heading" "$docs_file"; then
    echo "Documentation map is missing required heading: $heading" >&2
    exit 1
  fi
done

if ! diff -u "$expected" "$actual_unique" > "$diff_file"; then
  echo "Documentation map link set does not match the expected official TanStack Table documentation list:" >&2
  cat "$diff_file" >&2
  exit 1
fi

expected_count="$(wc -l < "$expected" | tr -d ' ')"
actual_count="$(wc -l < "$actual_unique" | tr -d ' ')"
contains_count="$(grep -c '^  - Contains:' "$docs_file" || true)"
use_when_count="$(grep -c '^  - Use when:' "$docs_file" || true)"

if [[ "$expected_count" != "$actual_count" ]]; then
  echo "Expected $expected_count unique links but found $actual_count unique links." >&2
  exit 1
fi

if [[ "$contains_count" != "$expected_count" || "$use_when_count" != "$expected_count" ]]; then
  echo "Expected $expected_count Contains and Use when annotations but found $contains_count and $use_when_count." >&2
  exit 1
fi

echo "OK: documentation map contains exactly $actual_count expected official TanStack Table links with annotations."
