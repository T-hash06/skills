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
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/overview.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/installation.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/typescript.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/quick-start.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/basic-concepts.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/validation.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/dynamic-validation.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/async-initial-values.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/arrays.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/form-groups.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/linked-fields.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/reactivity.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/listeners.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/custom-errors.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/submission-handling.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/ui-libraries.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/focus-management.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/form-composition.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/react-native.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/ssr.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/debugging.md
    echo https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/devtools.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FieldApi.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FieldGroupApi.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FormApi.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FormGroupApi.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldApiOptions.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldGroupOptions.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldGroupState.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldListeners.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldOptions.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldValidators.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupApiOptions.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupListeners.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupMeta.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupOptions.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupState.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupStoreState.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupValidators.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormListeners.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormOptions.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormState.md
    echo https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormValidators.md
end | sort > "$expected"

grep -Eo 'https?://[^[:space:]<>")]+' "$docs_file" | sed 's/[.)]$//' > "$raw"; or true
sort "$raw" > "$actual"
sort -u "$actual" > "$actual_unique"
uniq -d "$actual" > "$duplicates"
grep -Ev '^(https://raw\.githubusercontent\.com/tanstack/form/main/docs/|https://raw\.githubusercontent\.com/TanStack/form/refs/heads/main/docs/)' "$raw" > "$unofficial"; or true

if test -s "$duplicates"
    echo "Documentation map contains duplicate links:" >&2
    cat "$duplicates" >&2
    exit 1
end

if test -s "$unofficial"
    echo "Documentation map contains links outside the official raw TanStack Form docs paths:" >&2
    cat "$unofficial" >&2
    exit 1
end

set required_headings \
    "# Official TanStack Form Documentation Map" \
    "## Overview and Setup" \
    "## React Fundamentals" \
    "## Validation and Field Behavior Guides" \
    "## Composition and Platform Guides" \
    "## Class API Reference" \
    "## Field Interface Reference" \
    "## Form Group Interface Reference" \
    "## Form Interface Reference"

for heading in $required_headings
    if not grep -Fqx "$heading" "$docs_file"
        echo "Documentation map is missing required heading: $heading" >&2
        exit 1
    end
end

if not diff -u "$expected" "$actual_unique" > "$diff_file"
    echo "Documentation map link set does not match the expected official TanStack Form documentation list:" >&2
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

echo "OK: documentation map contains exactly $actual_count expected official TanStack Form links with annotations."
