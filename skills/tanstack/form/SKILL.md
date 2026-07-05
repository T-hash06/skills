---
name: tanstack-form
description: "Build, debug, refactor, or document TanStack Form implementations across frameworks, especially React, using official TanStack Form documentation links as the source of truth. Use for form setup, default values, fields, validation, dynamic validation, listeners, arrays, form groups, linked fields, submission handling, custom errors, focus management, SSR, React Native, Devtools, UI libraries, or TypeScript API references."
---

# TanStack Form

Use this skill to work with TanStack Form from the official documentation first, then adapt the guidance to the user's framework, codebase, validation strategy, and UI conventions.

## Documentation Index

Start with [references/official-docs.md](references/official-docs.md). It maps every official TanStack Form documentation link to a short "contains" and "use when" note so agents can decide which upstream docs to load for the task at hand.

Use the notes as routing help only. Prefer the linked official docs over memory whenever behavior, option names, generics, or API signatures matter.

The `docs/reference/...` links are advanced TypeScript API references. Read the relevant guide first for workflow and mental model, then use the reference pages to verify exact classes, interfaces, options, method names, state shapes, and generic constraints.

Use this reading order for most tasks:

1. Read overview, installation, and TypeScript docs when setup, packages, supported adapters, or type-safety expectations are involved.
2. Read React quick start and basic concepts before implementing or refactoring React forms.
3. Read the guide for the requested behavior, such as validation, arrays, form groups, linked fields, listeners, async initial values, submission handling, SSR, React Native, UI libraries, debugging, or Devtools.
4. Read the matching TypeScript API reference before finalizing option names, listener signatures, validator signatures, state access, or class/interface usage.

## Working Principles

- Treat TanStack Form as a headless form state and validation engine. Build inputs, labels, errors, layout, and accessibility markup in the host app's existing UI conventions.
- Prefer current official docs over remembered APIs. Confirm package imports, hook names, field APIs, validator options, and state shapes before changing code.
- Model the form data shape and default values before building field UI. Keep field names aligned with the submitted value shape, especially for arrays, nested fields, form groups, and linked fields.
- Choose validation timing deliberately. Use guide pages to decide between submit-time, change-time, blur-time, dynamic, async, and cross-field validation instead of mixing patterns accidentally.
- Keep expensive subscriptions narrow. Subscribe to only the form or field state needed by a component so large forms do not rerender unnecessarily.
- Separate submission behavior from rendering. Keep data transformation, API calls, optimistic state, and error mapping clear at the form boundary.
- Preserve existing schema validation libraries and UI component systems unless the request requires changing them. Use the official UI library and validation docs to integrate rather than replacing local conventions.
- For custom errors, focus management, SSR, React Native, and Devtools, read the dedicated guide before coding because these areas depend on runtime and platform details.
- Use the TypeScript reference pages for precise signatures only after the relevant guide is understood; those pages are detailed and assume comfort with generated TypeScript API documentation.

## Implementation Checklist

1. Identify the framework adapter, package version if available, form data shape, validation ownership, and submission path.
2. Read the relevant official docs from [references/official-docs.md](references/official-docs.md), including the advanced reference pages when exact signatures matter.
3. Define default values, field names, validation timing, and error display behavior before wiring UI components.
4. Build the smallest form flow that satisfies the request, then add arrays, groups, linked fields, listeners, or platform-specific behavior only as needed.
5. Match rendering, accessibility, loading states, disabled states, and error surfaces to the existing application.
6. Run or propose focused tests for validation timing, submission results, async behavior, dynamic fields, error rendering, and reset or reinitialization behavior.

## Maintenance

Run one or more static validators after editing [references/official-docs.md](references/official-docs.md):

```bash
bash skills/tanstack/form/scripts/validate-doc-links.sh
fish skills/tanstack/form/scripts/validate-doc-links.fish
pwsh -File skills/tanstack/form/scripts/validate-doc-links.ps1
```

Each validator compares every URL in the annotated documentation map against the embedded expected official-doc list, fails on missing links, extra links, duplicates, missing section headings, or missing annotations, and does not use the network.
