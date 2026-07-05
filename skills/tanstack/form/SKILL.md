---
name: tanstack-form
description: "Build, debug, refactor, review, or document TanStack Form implementations across frameworks, especially React, using official TanStack Form documentation as the source of truth. Use for form architecture, default values, typed fields, validation strategy, dynamic validation, listeners, arrays, form groups, linked fields, submission handling, custom errors, focus management, SSR, React Native, Devtools, UI library integration, performance, best practices, antipatterns, or TypeScript API references."
---

# TanStack Form

Use this skill to produce production-grade TanStack Form work from the official documentation first, then adapt the result to the user's framework, codebase, validation strategy, API contracts, and UI conventions.

## Core Workflow

1. Identify the framework adapter, installed package version if available, form data shape, validation ownership, submission path, server/API contracts, and UI component system.
2. Open [references/official-docs.md](references/official-docs.md) and route to the relevant official TanStack Form guide or API reference before relying on memory.
3. Open [references/practices.md](references/practices.md) when designing, reviewing, refactoring, or debugging non-trivial forms. Use it for good practices, antipatterns, production examples, and advanced patterns.
4. Define the form value contract first: default values, field paths, schema/input types, field arrays, form groups, submit metadata, and server error shape.
5. Choose validation timing deliberately: field-level vs form-level, sync vs async, schema vs function, submit-first vs change/blur revalidation, and whether dynamic validation needs `revalidateLogic()`.
6. Wire UI components as controlled TanStack Form fields while preserving existing accessibility, labels, error surfaces, loading states, and design-system conventions.
7. Keep reactivity narrow with `form.Subscribe` or `useStore`/selector patterns, and use listeners for side effects instead of render-time derived UI.
8. Run focused tests or provide exact test guidance for validation timing, async validation, submission success/failure, server error mapping, arrays, dependent fields, reset/reinitialization, and accessibility.

## Documentation Routing

Use [references/official-docs.md](references/official-docs.md) as the official upstream map. It lists every TanStack Form documentation link with a short "contains" and "use when" note.

Use the notes as routing help only. Prefer the linked official docs over memory whenever behavior, option names, generics, or API signatures matter.

The `docs/reference/...` links are advanced TypeScript API references. Read the relevant guide first for workflow and mental model, then use the reference pages to verify exact classes, interfaces, option names, method names, state shapes, and generic constraints.

Use this reading order for most tasks:

1. Read overview, installation, and TypeScript docs when setup, packages, supported adapters, or type-safety expectations are involved.
2. Read React quick start and basic concepts before implementing or refactoring React forms.
3. Read [references/practices.md](references/practices.md) for production patterns, antipatterns, and advanced examples when the task is larger than a tiny one-off form.
4. Read the guide for the requested behavior, such as validation, arrays, form groups, linked fields, listeners, async initial values, submission handling, SSR, React Native, UI libraries, debugging, or Devtools.
5. Read the matching TypeScript API reference before finalizing option names, listener signatures, validator signatures, state access, or class/interface usage.

## Practice Priorities

- Treat TanStack Form as a headless, typed form state and validation engine. Let the host app own markup, styling, labels, layout, accessibility, and UI library details.
- Prefer `createFormHook`, pre-bound field components, `withForm`, and field groups for production forms that repeat patterns. Prefer `useForm` and `form.Field` for small or exploratory forms where directness is clearer.
- Keep `defaultValues` complete and aligned with the submitted value shape. Make field names match the actual nested contract, including arrays and form groups.
- Use Standard Schema libraries for shared structural validation, but parse again in `onSubmit` when transformed output values are required.
- Use field validators for single-field rules, form validators for cross-field or whole-form rules, listeners for side effects, and linked-field `*ListenTo` options when another field should trigger revalidation.
- Debounce async validators and listener-driven network calls. Never send a request for every keystroke unless the product explicitly requires it and the backend is designed for it.
- Subscribe to specific state slices. Avoid reading the whole form store in broad components, and avoid using non-reactive `form.state` reads to drive live UI.
- Preserve existing app conventions unless the user asks to change them. Do not replace a design system, schema library, query layer, or mutation layer just to fit a generic example.

## Antipattern Alerts

- Do not use `onDynamic` or `onDynamicAsync` without configuring `validationLogic: revalidateLogic()`.
- Do not assume Standard Schema transforms change the value passed to `onSubmit`; submit receives input values.
- Do not omit `field.handleBlur` when using `onBlur` or `onBlurAsync` validators.
- Do not put side effects in validators. Validators should return errors; listeners should reset fields, autosave, log analytics, or synchronize external state.
- Do not use a form-level field error and a field-level validator for the same field without understanding that field-specific validation can overwrite form-level field errors.
- Do not use a native reset button with `form.reset()` unless the native reset is prevented, especially around selects and UI library components.
- Do not use typed context fallbacks where `withForm` can pass the form instance; context fallback loses type guarantees.
- Do not subscribe to the entire store with `useStore(form.store)` in large forms. Use selectors or `form.Subscribe`.

## Advanced Topics

Read the dedicated official guide and [references/practices.md](references/practices.md) before implementing these:

- App-level `createFormHook` setup with pre-bound field/form components.
- Large form decomposition with `withForm`, `withFieldGroup`, and form groups.
- Dynamic validation with submit-first behavior and post-submit revalidation.
- Cross-field validation and dependent field revalidation.
- Server-side validation and custom error mapping.
- Async initial values with TanStack Query or an equivalent cache layer.
- React Native focus handling, SSR constraints, Devtools, and performance debugging.

## Maintenance

Run one or more static validators after editing [references/official-docs.md](references/official-docs.md):

```bash
bash <path_to_skill>/scripts/validate-doc-links.sh
fish <path_to_skill>/scripts/validate-doc-links.fish
pwsh -File <path_to_skill>/scripts/validate-doc-links.ps1
```

Each validator compares every URL in the annotated documentation map against the embedded expected official-doc list, fails on missing links, extra links, duplicates, missing section headings, or missing annotations, and does not use the network.

After changing the skill, run the repository or skill validation available in the current workspace. If no project-level validation exists, run the documentation-link validator and the system `quick_validate.py` script for this skill folder.
