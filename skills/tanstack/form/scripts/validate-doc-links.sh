#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd -- "$script_dir/.." && pwd)"
docs_file="$skill_dir/references/official-docs.md"

if [[ ! -f "$docs_file" ]]; then
  echo "Missing documentation map at $docs_file" >&2
  exit 1
fi

for dependency in grep sort uniq diff mktemp wc sed; do
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
https://raw.githubusercontent.com/tanstack/form/main/docs/overview.md
https://raw.githubusercontent.com/tanstack/form/main/docs/installation.md
https://raw.githubusercontent.com/tanstack/form/main/docs/typescript.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/quick-start.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/basic-concepts.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/validation.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/dynamic-validation.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/async-initial-values.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/arrays.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/form-groups.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/linked-fields.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/reactivity.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/listeners.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/custom-errors.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/submission-handling.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/ui-libraries.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/focus-management.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/form-composition.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/react-native.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/ssr.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/debugging.md
https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/devtools.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FieldApi.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FieldGroupApi.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FormApi.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FormGroupApi.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldApiOptions.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldGroupOptions.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldGroupState.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldListeners.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldOptions.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldValidators.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupApiOptions.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupListeners.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupMeta.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupOptions.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupState.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupStoreState.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupValidators.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormListeners.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormOptions.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormState.md
https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormValidators.md
URLS

sort -o "$expected" "$expected"
grep -Eo 'https?://[^[:space:]<>")]+' "$docs_file" | sed 's/[.)]$//' > "$raw" || true
sort "$raw" > "$actual"
sort -u "$actual" > "$actual_unique"
uniq -d "$actual" > "$duplicates"
grep -Ev '^(https://raw\.githubusercontent\.com/tanstack/form/main/docs/|https://raw\.githubusercontent\.com/TanStack/form/refs/heads/main/docs/)' "$raw" > "$unofficial" || true

if [[ -s "$duplicates" ]]; then
  echo "Documentation map contains duplicate links:" >&2
  cat "$duplicates" >&2
  exit 1
fi

if [[ -s "$unofficial" ]]; then
  echo "Documentation map contains links outside the official raw TanStack Form docs paths:" >&2
  cat "$unofficial" >&2
  exit 1
fi

required_headings=(
  "# Official TanStack Form Documentation Map"
  "## Overview and Setup"
  "## React Fundamentals"
  "## Validation and Field Behavior Guides"
  "## Composition and Platform Guides"
  "## Class API Reference"
  "## Field Interface Reference"
  "## Form Group Interface Reference"
  "## Form Interface Reference"
)

for heading in "${required_headings[@]}"; do
  if ! grep -Fqx "$heading" "$docs_file"; then
    echo "Documentation map is missing required heading: $heading" >&2
    exit 1
  fi
done

if ! diff -u "$expected" "$actual_unique" > "$diff_file"; then
  echo "Documentation map link set does not match the expected official TanStack Form documentation list:" >&2
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

echo "OK: documentation map contains exactly $actual_count expected official TanStack Form links with annotations."
