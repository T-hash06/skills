$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Resolve-Path (Join-Path $ScriptDir "..")
$DocsFile = Join-Path $SkillDir "references/official-docs.md"

if (-not (Test-Path -LiteralPath $DocsFile)) {
    Write-Error "Missing documentation map at $DocsFile"
    exit 1
}

$Expected = @(
    "https://raw.githubusercontent.com/tanstack/table/main/docs/installation.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/framework/react/react-table.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/data.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-defs.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/tables.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-models.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/rows.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/cells.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/header-groups.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/headers.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/columns.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/framework/react/guide/table-state.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-ordering.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-pinning.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-sizing.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-visibility.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-filtering.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/global-filtering.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/fuzzy-filtering.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/column-faceting.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/global-faceting.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/grouping.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/expanding.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/pagination.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-pinning.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/row-selection.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/sorting.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/virtualization.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/guide/custom-features.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/column-def.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/table.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/column.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/header-group.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/header.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/row.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/core/cell.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-filtering.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-faceting.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-ordering.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-pinning.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-sizing.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/column-visibility.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/global-faceting.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/global-filtering.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/sorting.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/grouping.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/expanding.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/pagination.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/row-pinning.md",
    "https://raw.githubusercontent.com/tanstack/table/main/docs/api/features/row-selection.md"
)

$Content = Get-Content -LiteralPath $DocsFile -Raw
$Actual = [regex]::Matches($Content, 'https?://[^\s<>")]+') | ForEach-Object { $_.Value.TrimEnd([char[]]@(".", ")")) } | Sort-Object
$ActualUnique = $Actual | Sort-Object -Unique
$Duplicates = $Actual | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name }
$Unofficial = $Actual | Where-Object { $_ -notmatch '^https://raw\.githubusercontent\.com/tanstack/table/main/docs/' }

if ($Duplicates.Count -gt 0) {
    Write-Error ("Documentation map contains duplicate links:`n" + ($Duplicates -join "`n"))
    exit 1
}

if ($Unofficial.Count -gt 0) {
    Write-Error ("Documentation map contains links outside the official raw TanStack Table docs path:`n" + ($Unofficial -join "`n"))
    exit 1
}

$RequiredHeadings = @(
    "# Official TanStack Table Documentation Map",
    "## Setup and Adapters",
    "## Core Concepts and Rendering",
    "## Column Feature Guides",
    "## Filtering and Faceting Guides",
    "## Row and Data Feature Guides",
    "## Core API Reference",
    "## Feature API Reference"
)

foreach ($Heading in $RequiredHeadings) {
    if ($Content -notmatch "(?m)^$([regex]::Escape($Heading))$") {
        Write-Error "Documentation map is missing required heading: $Heading"
        exit 1
    }
}

$Missing = $Expected | Where-Object { $ActualUnique -notcontains $_ }
$Extra = $ActualUnique | Where-Object { $Expected -notcontains $_ }

if ($Missing.Count -gt 0 -or $Extra.Count -gt 0) {
    if ($Missing.Count -gt 0) {
        Write-Error ("Missing expected links:`n" + ($Missing -join "`n"))
    }
    if ($Extra.Count -gt 0) {
        Write-Error ("Unexpected links:`n" + ($Extra -join "`n"))
    }
    exit 1
}

$ContainsCount = ([regex]::Matches($Content, '(?m)^  - Contains:')).Count
$UseWhenCount = ([regex]::Matches($Content, '(?m)^  - Use when:')).Count

if ($ActualUnique.Count -ne $Expected.Count) {
    Write-Error "Expected $($Expected.Count) unique links but found $($ActualUnique.Count) unique links."
    exit 1
}

if ($ContainsCount -ne $Expected.Count -or $UseWhenCount -ne $Expected.Count) {
    Write-Error "Expected $($Expected.Count) Contains and Use when annotations but found $ContainsCount and $UseWhenCount."
    exit 1
}

Write-Output "OK: documentation map contains exactly $($ActualUnique.Count) expected official TanStack Table links with annotations."
