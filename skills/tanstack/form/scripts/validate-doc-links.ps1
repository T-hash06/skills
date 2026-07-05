$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Resolve-Path (Join-Path $ScriptDir "..")
$DocsFile = Join-Path $SkillDir "references/official-docs.md"

if (-not (Test-Path -LiteralPath $DocsFile)) {
    Write-Error "Missing documentation map at $DocsFile"
    exit 1
}

$Expected = @(
    "https://raw.githubusercontent.com/tanstack/form/main/docs/overview.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/installation.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/typescript.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/quick-start.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/basic-concepts.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/validation.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/dynamic-validation.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/async-initial-values.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/arrays.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/form-groups.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/linked-fields.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/reactivity.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/listeners.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/custom-errors.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/submission-handling.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/ui-libraries.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/focus-management.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/form-composition.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/react-native.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/ssr.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/debugging.md",
    "https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/devtools.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FieldApi.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FieldGroupApi.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FormApi.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FormGroupApi.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldApiOptions.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldGroupOptions.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldGroupState.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldListeners.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldOptions.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldValidators.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupApiOptions.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupListeners.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupMeta.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupOptions.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupState.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupStoreState.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupValidators.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormListeners.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormOptions.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormState.md",
    "https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormValidators.md"
)

$Content = Get-Content -LiteralPath $DocsFile -Raw
$Actual = [regex]::Matches($Content, 'https?://[^\s<>")]+') | ForEach-Object { $_.Value.TrimEnd([char[]]@(".", ")")) } | Sort-Object
$ActualUnique = $Actual | Sort-Object -Unique
$Duplicates = $Actual | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name }
$Unofficial = $Actual | Where-Object { $_ -notmatch '^(https://raw\.githubusercontent\.com/tanstack/form/main/docs/|https://raw\.githubusercontent\.com/TanStack/form/refs/heads/main/docs/)' }

if ($Duplicates.Count -gt 0) {
    Write-Error ("Documentation map contains duplicate links:`n" + ($Duplicates -join "`n"))
    exit 1
}

if ($Unofficial.Count -gt 0) {
    Write-Error ("Documentation map contains links outside the official raw TanStack Form docs paths:`n" + ($Unofficial -join "`n"))
    exit 1
}

$RequiredHeadings = @(
    "# Official TanStack Form Documentation Map",
    "## Overview and Setup",
    "## React Fundamentals",
    "## Validation and Field Behavior Guides",
    "## Composition and Platform Guides",
    "## Class API Reference",
    "## Field Interface Reference",
    "## Form Group Interface Reference",
    "## Form Interface Reference"
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

Write-Output "OK: documentation map contains exactly $($ActualUnique.Count) expected official TanStack Form links with annotations."
