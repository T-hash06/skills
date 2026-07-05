#!/usr/bin/env fish

set script_dir (dirname (status --current-filename))
set skill_dir (realpath "$script_dir/..")
set docs_file "$skill_dir/references/official-docs.md"

if not test -f "$docs_file"
    echo "Missing documentation map at $docs_file" >&2
    exit 1
end

for dependency in grep sort uniq diff mktemp wc realpath sed
    if not command -q $dependency
        echo "Missing required command: $dependency" >&2
        exit 1
    end
end

set tmp_dir (mktemp -d)

function cleanup --on-event fish_exit
    if test -n "$tmp_dir" -a -d "$tmp_dir"
        rm -rf "$tmp_dir"
    end
end

set expected "$tmp_dir/expected.txt"
set raw "$tmp_dir/raw.txt"
set actual "$tmp_dir/actual.txt"
set actual_unique "$tmp_dir/actual-unique.txt"
set duplicates "$tmp_dir/duplicates.txt"
set unofficial "$tmp_dir/unofficial.txt"
set diff_file "$tmp_dir/diff.txt"

begin
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/installation.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/framework/react/react-table.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/data.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-defs.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/tables.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-models.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/rows.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/cells.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/header-groups.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/headers.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/columns.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/framework/react/guide/table-state.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-ordering.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-pinning.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-sizing.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-visibility.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-filtering.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/global-filtering.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/fuzzy-filtering.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-faceting.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/global-faceting.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/grouping.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/expanding.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/pagination.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-pinning.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-selection.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/sorting.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/virtualization.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/guide/custom-features.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/column-def.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/table.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/column.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/header-group.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/header.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/row.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/cell.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-filtering.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-faceting.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-ordering.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-pinning.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-sizing.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-visibility.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/global-faceting.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/global-filtering.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/sorting.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/grouping.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/expanding.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/pagination.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/row-pinning.md
    echo https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/row-selection.md
end | sort > "$expected"

grep -Eo 'https?://[^[:space:]<>")]+' "$docs_file" | sed 's/[.)]$//' > "$raw"; or true
sort "$raw" > "$actual"
sort -u "$actual" > "$actual_unique"
uniq -d "$actual" > "$duplicates"
grep -Ev '^https://raw\.githubusercontent\.com/tanstack/table/main/docs/' "$raw" > "$unofficial"; or true

if test -s "$duplicates"
    echo "Documentation map contains duplicate links:" >&2
    cat "$duplicates" >&2
    exit 1
end

if test -s "$unofficial"
    echo "Documentation map contains links outside the official raw TanStack Table docs path:" >&2
    cat "$unofficial" >&2
    exit 1
end

set required_headings \
    "# Official TanStack Table Documentation Map" \
    "## Setup and Adapters" \
    "## Core Concepts and Rendering" \
    "## Column Feature Guides" \
    "## Filtering and Faceting Guides" \
    "## Row and Data Feature Guides" \
    "## Core API Reference" \
    "## Feature API Reference"

for heading in $required_headings
    if not grep -Fqx "$heading" "$docs_file"
        echo "Documentation map is missing required heading: $heading" >&2
        exit 1
    end
end

if not diff -u "$expected" "$actual_unique" > "$diff_file"
    echo "Documentation map link set does not match the expected official TanStack Table documentation list:" >&2
    cat "$diff_file" >&2
    exit 1
end

set expected_count (wc -l < "$expected" | string trim)
set actual_count (wc -l < "$actual_unique" | string trim)
set contains_count (grep -c '^  - Contains:' "$docs_file")
set use_when_count (grep -c '^  - Use when:' "$docs_file")

if test "$expected_count" != "$actual_count"
    echo "Expected $expected_count unique links but found $actual_count unique links." >&2
    exit 1
end

if test "$contains_count" != "$expected_count" -o "$use_when_count" != "$expected_count"
    echo "Expected $expected_count Contains and Use when annotations but found $contains_count and $use_when_count." >&2
    exit 1
end

echo "OK: documentation map contains exactly $actual_count expected official TanStack Table links with annotations."
