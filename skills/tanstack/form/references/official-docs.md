# Official TanStack Form Documentation Map

Use this map to choose which official upstream documentation to load. Each entry has a brief routing note only; open the linked official document for current API details, examples, and exact option names.

The `docs/reference/...` pages are TypeScript-advanced API references generated from classes and interfaces. Treat them as exact-signature sources after reading the relevant guide; do not use them as the first onboarding path unless the user specifically asks for type-level details.

## Table of Contents

- [Overview and Setup](#overview-and-setup)
- [React Fundamentals](#react-fundamentals)
- [Validation and Field Behavior Guides](#validation-and-field-behavior-guides)
- [Composition and Platform Guides](#composition-and-platform-guides)
- [Class API Reference](#class-api-reference)
- [Field Interface Reference](#field-interface-reference)
- [Form Group Interface Reference](#form-group-interface-reference)
- [Form Interface Reference](#form-interface-reference)

## Overview and Setup

### Overview

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/overview.md
  - Contains: Product overview, core positioning, supported use cases, and the high-level mental model for TanStack Form.
  - Use when: Starting a new form task, explaining what TanStack Form provides, or confirming whether it fits a requested workflow.

### Installation

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/installation.md
  - Contains: Package installation guidance and adapter setup entry points.
  - Use when: Adding TanStack Form to a project, checking package names, or confirming setup steps before writing code.

### TypeScript

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/typescript.md
  - Contains: TypeScript guidance for typed form values, field names, validation, and inference patterns.
  - Use when: Designing strongly typed forms, fixing generic or inference issues, or making form code type-safe.

## React Fundamentals

### React Quick Start

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/quick-start.md
  - Contains: The shortest React setup path, including basic form creation, fields, validation, and submission flow.
  - Use when: Creating a new React form, verifying imports, or needing a minimal working example.

### React Basic Concepts

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/basic-concepts.md
  - Contains: React form and field concepts, state access, render patterns, validators, and form submission basics.
  - Use when: Explaining or refactoring core React usage before adding advanced behavior.

## Validation and Field Behavior Guides

### Validation

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/validation.md
  - Contains: Validation strategies, validator placement, validation timing, error handling, and schema/library integration patterns.
  - Use when: Adding or debugging validation, choosing a validation trigger, or integrating existing validation libraries.

### Dynamic Validation

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/dynamic-validation.md
  - Contains: Runtime-dependent validation behavior and patterns for validators that change with form or field state.
  - Use when: Validation rules depend on other values, user choices, or application state.

### Linked Fields

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/linked-fields.md
  - Contains: Patterns for coordinating fields whose values, state, or validation behavior depend on each other.
  - Use when: Updating one field from another, building dependent inputs, or implementing cross-field behavior.

### Reactivity

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/reactivity.md
  - Contains: Reactive state access, subscriptions, selectors, and rerender control for form and field state.
  - Use when: Optimizing rerenders, subscribing to form state, or deriving UI from specific state slices.

### Listeners

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/listeners.md
  - Contains: Listener concepts for reacting to form or field changes outside direct rendering.
  - Use when: Running side effects from form changes, syncing state, or coordinating behavior after updates.

### Custom Errors

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/custom-errors.md
  - Contains: Custom error handling, manually supplied errors, and patterns for mapping domain or server errors to form state.
  - Use when: Displaying API errors, domain-specific validation messages, or errors that do not come directly from built-in validators.

### Focus Management

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/focus-management.md
  - Contains: Guidance for focusing fields, handling invalid submissions, and improving form accessibility around focus.
  - Use when: Moving focus to errors, improving keyboard workflows, or implementing accessible validation feedback.

## Composition and Platform Guides

### Async Initial Values

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/async-initial-values.md
  - Contains: Patterns for loading initial values asynchronously and coordinating form initialization with fetched data.
  - Use when: Editing server-loaded records, delaying defaults until data arrives, or handling loading and reinitialization behavior.

### Arrays

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/arrays.md
  - Contains: Field array patterns, dynamic item operations, indexed paths, and array-shaped form state.
  - Use when: Adding repeatable fields, dynamic lists, nested collections, or add/remove/reorder behavior.

### Form Groups

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/form-groups.md
  - Contains: Grouping patterns for composing related fields and sharing behavior across a subset of form state.
  - Use when: Building reusable form sections, nested groups, or scoped validation and state behavior.

### Submission Handling

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/submission-handling.md
  - Contains: Submit workflow, submission state, success/error handling, and patterns for async submission.
  - Use when: Wiring form submits to application actions, APIs, mutations, optimistic flows, or error mapping.

### UI Libraries

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/ui-libraries.md
  - Contains: Integration guidance for using TanStack Form with third-party or design-system input components.
  - Use when: Connecting field state and handlers to component libraries without replacing the app's UI conventions.

### Form Composition

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/form-composition.md
  - Contains: Composition techniques for splitting forms into reusable components while preserving form and field context.
  - Use when: Refactoring large forms, extracting sections, or sharing form components across screens.

### React Native

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/react-native.md
  - Contains: React Native-specific usage patterns and platform differences for form fields and submission.
  - Use when: Implementing TanStack Form in React Native rather than web React.

### SSR

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/ssr.md
  - Contains: Server-side rendering guidance and constraints for React applications using TanStack Form.
  - Use when: Working in SSR frameworks, debugging hydration behavior, or deciding what form state belongs on the client.

### Debugging

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/debugging.md
  - Contains: Debugging techniques for inspecting form state, field state, validation, and update behavior.
  - Use when: Diagnosing unexpected values, stale state, validation timing, or rendering issues.

### Devtools

- Link: https://raw.githubusercontent.com/tanstack/form/main/docs/framework/react/guides/devtools.md
  - Contains: Devtools setup and usage for inspecting TanStack Form behavior during development.
  - Use when: Adding development-time inspection or debugging complex form flows interactively.

## Class API Reference

### FieldApi

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FieldApi.md
  - Contains: Advanced TypeScript reference for the `FieldApi` class, including field state access, methods, validators, listeners, and lifecycle behavior.
  - Use when: Verifying exact field API methods, method signatures, state access, or generic constraints.

### FieldGroupApi

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FieldGroupApi.md
  - Contains: Advanced TypeScript reference for the `FieldGroupApi` class and group-level field operations.
  - Use when: Implementing or typing field groups and checking exact group API methods.

### FormApi

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FormApi.md
  - Contains: Advanced TypeScript reference for the `FormApi` class, form state, methods, validation, submission, listeners, and options.
  - Use when: Confirming form-level methods, state mutation APIs, submission behavior, or type parameters.

### FormGroupApi

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/classes/FormGroupApi.md
  - Contains: Advanced TypeScript reference for the `FormGroupApi` class and grouped form state behavior.
  - Use when: Verifying form group APIs, state access, validators, or generics for grouped form sections.

## Field Interface Reference

### FieldApiOptions

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldApiOptions.md
  - Contains: Advanced TypeScript reference for options used to construct or configure field APIs.
  - Use when: Checking low-level field API option names, types, or generic relationships.

### FieldGroupOptions

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldGroupOptions.md
  - Contains: Advanced TypeScript reference for field group option shapes.
  - Use when: Typing field group configuration or confirming valid group options.

### FieldGroupState

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldGroupState.md
  - Contains: Advanced TypeScript reference for field group state shape and state fields.
  - Use when: Reading or typing field group state in selectors, listeners, or tests.

### FieldListeners

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldListeners.md
  - Contains: Advanced TypeScript reference for field listener callback options and signatures.
  - Use when: Adding field-level side effects or verifying listener callback types.

### FieldOptions

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldOptions.md
  - Contains: Advanced TypeScript reference for field configuration options, value typing, validators, and listeners.
  - Use when: Checking exact field option names or typing a reusable field abstraction.

### FieldValidators

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FieldValidators.md
  - Contains: Advanced TypeScript reference for field validator option names, callback signatures, and return types.
  - Use when: Implementing custom field validators or resolving validator typing errors.

## Form Group Interface Reference

### FormGroupApiOptions

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupApiOptions.md
  - Contains: Advanced TypeScript reference for low-level form group API configuration.
  - Use when: Creating or typing form group APIs and checking option compatibility.

### FormGroupListeners

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupListeners.md
  - Contains: Advanced TypeScript reference for form group listener options and callback signatures.
  - Use when: Adding side effects around grouped form state changes.

### FormGroupMeta

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupMeta.md
  - Contains: Advanced TypeScript reference for metadata attached to form groups.
  - Use when: Reading, typing, or extending form group metadata.

### FormGroupOptions

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupOptions.md
  - Contains: Advanced TypeScript reference for form group setup options.
  - Use when: Configuring form groups or extracting reusable group components.

### FormGroupState

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupState.md
  - Contains: Advanced TypeScript reference for form group state shape.
  - Use when: Typing group-level state selectors, assertions, or state-driven rendering.

### FormGroupStoreState

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupStoreState.md
  - Contains: Advanced TypeScript reference for the internal store state used by form groups.
  - Use when: Debugging or typing advanced store interactions for grouped form state.

### FormGroupValidators

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormGroupValidators.md
  - Contains: Advanced TypeScript reference for form group validator options and signatures.
  - Use when: Implementing grouped validation rules or resolving form group validator typing issues.

## Form Interface Reference

### FormListeners

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormListeners.md
  - Contains: Advanced TypeScript reference for form-level listener callback options and signatures.
  - Use when: Adding form-level side effects or syncing external state from form changes.

### FormOptions

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormOptions.md
  - Contains: Advanced TypeScript reference for form configuration options, validators, listeners, defaults, and submission settings.
  - Use when: Checking exact form option names or typing reusable form setup helpers.

### FormState

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormState.md
  - Contains: Advanced TypeScript reference for form state shape, values, metadata, errors, and submission status.
  - Use when: Reading form state, writing selectors, testing state transitions, or debugging state-driven UI.

### FormValidators

- Link: https://raw.githubusercontent.com/TanStack/form/refs/heads/main/docs/reference/interfaces/FormValidators.md
  - Contains: Advanced TypeScript reference for form-level validator option names, callback signatures, and return types.
  - Use when: Implementing cross-field or form-level validation and verifying validator typing.
