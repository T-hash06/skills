# TanStack Form Practices and Antipatterns

Use this reference after routing through `official-docs.md`. It distills the official TanStack Form docs into practical production guidance for agents implementing, reviewing, or refactoring real applications.

## Table of Contents

- [Mental Model](#mental-model)
- [Design the Value Contract First](#design-the-value-contract-first)
- [Choose the Right Composition Level](#choose-the-right-composition-level)
- [Wire Fields Explicitly](#wire-fields-explicitly)
- [Validation Strategy](#validation-strategy)
- [Error Modeling and Display](#error-modeling-and-display)
- [Reactivity and Performance](#reactivity-and-performance)
- [Linked Fields and Side Effects](#linked-fields-and-side-effects)
- [Arrays and Nested Data](#arrays-and-nested-data)
- [Form Groups and Wizards](#form-groups-and-wizards)
- [Async Initial Values](#async-initial-values)
- [Submission Handling](#submission-handling)
- [UI Libraries and Accessibility](#ui-libraries-and-accessibility)
- [Testing and Debugging](#testing-and-debugging)
- [Review Checklist](#review-checklist)

## Mental Model

TanStack Form is a headless, strongly typed form engine. It does not own layout, labels, input markup, focus behavior, or visual error treatments. The form instance owns values, field metadata, validation, subscriptions, listeners, submission lifecycle, and imperative helpers.

Good TanStack Form code makes the state contract obvious:

- Values are represented by complete `defaultValues`.
- Field names map to the exact submitted object shape.
- Validators return typed errors and do not perform side effects.
- Subscriptions are narrow and intentional.
- UI components translate TanStack field APIs into the local design-system props.
- Submission code handles transformation, API calls, server errors, and navigation at the form boundary.

Antipattern:

```tsx
// The form shape, validation timing, and submission behavior are all implicit.
const form = useForm({})
```

Better:

```tsx
type InviteMemberInput = {
  email: string
  role: 'admin' | 'member' | 'viewer'
  sendWelcomeEmail: boolean
}

const inviteDefaults: InviteMemberInput = {
  email: '',
  role: 'member',
  sendWelcomeEmail: true,
}

const form = useForm({
  defaultValues: inviteDefaults,
  onSubmit: async ({ value }) => {
    await inviteMember(value)
  },
})
```

## Design the Value Contract First

Start every implementation by writing the value shape. This is more important than rendering fields because TanStack Form's type safety comes from the default value contract and field names.

Good practice:

```tsx
type CheckoutValues = {
  contact: {
    email: string
    phone: string
  }
  shipping: {
    country: string
    province: string
    postalCode: string
  }
  lineItems: Array<{
    id: string
    sku: string
    quantity: number
  }>
}

const defaultValues: CheckoutValues = {
  contact: { email: '', phone: '' },
  shipping: { country: 'US', province: '', postalCode: '' },
  lineItems: [],
}
```

Antipatterns:

- Rendering fields before deciding the submitted object.
- Leaving nested objects undefined and then guarding every field with fallback values.
- Using field names that do not match the API contract and transforming the entire object later to hide that mismatch.
- Using `any` for form values when the backend contract is known.

When a schema library is already used in the app, infer the input type from the schema and make the defaults satisfy that input type:

```tsx
const profileSchema = z.object({
  displayName: z.string().min(2),
  age: z.number().int().min(13),
})

type ProfileInput = z.input<typeof profileSchema>

const form = useForm({
  defaultValues: {
    displayName: '',
    age: 13,
  } satisfies ProfileInput,
  validators: {
    onChange: profileSchema,
  },
})
```

Important: Standard Schema validation does not pass transformed output values to `onSubmit`. If a schema transforms strings to numbers, parse in `onSubmit`.

```tsx
const schema = z.object({
  age: z.string().transform((value) => Number(value)),
})

const form = useForm({
  defaultValues: { age: '13' } satisfies z.input<typeof schema>,
  validators: { onChange: schema },
  onSubmit: ({ value }) => {
    const parsed = schema.parse(value)
    saveProfile({ age: parsed.age })
  },
})
```

## Choose the Right Composition Level

Use the least abstraction that will stay maintainable.

Use `useForm` and `form.Field` when:

- The form is small or one-off.
- You are debugging or proving a behavior.
- Direct render props make the API easier to understand.

Use `createFormHook` when:

- The app has a design system.
- Many forms repeat labels, inputs, errors, descriptions, and submit buttons.
- You want app-specific field components without losing field-name type safety.

Good production pattern:

```tsx
// form-context.ts
export const { fieldContext, formContext, useFieldContext, useFormContext } =
  createFormHookContexts()

// fields/text-field.tsx
export function TextField({ label }: { label: string }) {
  const field = useFieldContext<string>()

  return (
    <label htmlFor={field.name}>
      <span>{label}</span>
      <input
        id={field.name}
        name={field.name}
        value={field.state.value}
        onBlur={field.handleBlur}
        onChange={(event) => field.handleChange(event.target.value)}
        aria-invalid={!field.state.meta.isValid || undefined}
      />
      {field.state.meta.isTouched && !field.state.meta.isValid ? (
        <span role="alert">{field.state.meta.errors.join(', ')}</span>
      ) : null}
    </label>
  )
}

// form.ts
export const { useAppForm, withForm, withFieldGroup } = createFormHook({
  fieldContext,
  formContext,
  fieldComponents: { TextField },
  formComponents: { SubmitButton },
})
```

Antipatterns:

- Repeating raw `<form.Field>` markup across dozens of screens when the app already has standardized form controls.
- Creating a generic wrapper that erases field value types.
- Chaining many app-form extensions in a platform package. Official guidance warns that multiple extension chains can hurt TypeScript performance; keep extension layers shallow.
- Using typed form context as the normal way to pass a form instance. Prefer `withForm`; use context only when a router outlet or third-party component prevents prop passing.

## Wire Fields Explicitly

TanStack Form fields are controlled. A field render function must pass the current value and event handlers to the real input or UI component.

Good text input:

```tsx
<form.Field name="contact.email">
  {(field) => (
    <input
      id={field.name}
      name={field.name}
      value={field.state.value}
      onBlur={field.handleBlur}
      onChange={(event) => field.handleChange(event.target.value)}
    />
  )}
</form.Field>
```

Good number input:

```tsx
<form.Field name="lineItems[0].quantity">
  {(field) => (
    <input
      type="number"
      value={field.state.value}
      onBlur={field.handleBlur}
      onChange={(event) => field.handleChange(event.target.valueAsNumber)}
    />
  )}
</form.Field>
```

Good checkbox with a UI library:

```tsx
<form.Field name="sendWelcomeEmail">
  {(field) => (
    <Checkbox
      checked={field.state.value}
      onCheckedChange={(checked) => field.handleChange(checked === true)}
      onBlur={field.handleBlur}
    />
  )}
</form.Field>
```

Antipatterns:

- Passing `event.target.value` into a number field and later wondering why schema validation receives strings.
- Omitting `onBlur` while using `onBlur` or `onBlurAsync` validators.
- Using `defaultValue` for an input that must stay controlled by TanStack Form.
- Assuming every component uses DOM `onChange`; map to the component's real controlled props, such as `checked`, `onCheckedChange`, `selectedKey`, or `onValueChange`.

## Validation Strategy

Pick validation placement and timing intentionally.

Use field-level validators for rules about one field:

```tsx
<form.Field
  name="username"
  validators={{
    onChange: ({ value }) =>
      value.length < 3 ? 'Username must be at least 3 characters' : undefined,
  }}
>
  {(field) => <UsernameInput field={field} />}
</form.Field>
```

Use form-level validators for cross-field and whole-form rules:

```tsx
const form = useForm({
  defaultValues: {
    startDate: '',
    endDate: '',
  },
  validators: {
    onSubmit: ({ value }) => {
      if (value.endDate <= value.startDate) {
        return {
          form: 'Fix the schedule before continuing.',
          fields: {
            endDate: 'End date must be after start date.',
          },
        }
      }
      return undefined
    },
  },
})
```

Use Standard Schema for shared structural validation:

```tsx
const accountSchema = z.object({
  email: z.string().email(),
  password: z.string().min(12),
})

const form = useForm({
  defaultValues: { email: '', password: '' },
  validators: {
    onChange: accountSchema,
  },
})
```

Use async validation only with debounce unless there is a strong reason not to:

```tsx
<form.Field
  name="username"
  asyncDebounceMs={500}
  validators={{
    onChange: ({ value }) =>
      value.length < 3 ? 'Enter at least 3 characters' : undefined,
    onChangeAsync: async ({ value }) => {
      const available = await api.usernames.isAvailable(value)
      return available ? undefined : 'That username is already taken'
    },
  }}
>
  {(field) => <UsernameInput field={field} />}
</form.Field>
```

By default, async validation runs after the sync validator succeeds. Use `asyncAlways: true` only when the async rule must run even with sync errors.

Use dynamic validation for submit-first UX:

```tsx
const form = useForm({
  defaultValues: {
    firstName: '',
    lastName: '',
  },
  validationLogic: revalidateLogic({
    mode: 'submit',
    modeAfterSubmission: 'blur',
  }),
  validators: {
    onDynamic: ({ value }) => ({
      fields: {
        firstName: value.firstName ? undefined : 'First name is required',
        lastName: value.lastName ? undefined : 'Last name is required',
      },
    }),
  },
})
```

Antipatterns:

- Using `onDynamic` without `validationLogic: revalidateLogic()`. It will not be called.
- Combining field and form validators for the same field without deciding which error wins. Field-specific validation can overwrite form-level field errors.
- Running username availability checks on every keystroke without `asyncDebounceMs` or `onChangeAsyncDebounceMs`.
- Putting API writes, redirects, analytics, or resets in validators. Validators should return errors.
- Validating only on change for large forms when the product expects "show errors after submit, then revalidate touched fields".

## Error Modeling and Display

String errors are simple, but TanStack Form supports typed custom error values. Use richer error objects when the UI needs severity, codes, translation keys, or remediation actions.

Good custom error:

```tsx
type FieldError =
  | { kind: 'message'; message: string }
  | { kind: 'quota'; remaining: number }

<form.Field
  name="seats"
  validators={{
    onChange: ({ value }): FieldError | undefined =>
      value > plan.remainingSeats
        ? { kind: 'quota', remaining: plan.remainingSeats }
        : undefined,
  }}
>
  {(field) => {
    const error = field.state.meta.errors[0]

    return (
      <>
        <SeatStepper value={field.state.value} onChange={field.handleChange} />
        {error?.kind === 'quota' ? (
          <p role="alert">Only {error.remaining} seats are available.</p>
        ) : null}
      </>
    )
  }}
</form.Field>
```

Use `errorMap` when error source matters:

```tsx
<form.Field
  name="email"
  disableErrorFlat
  validators={{
    onChange: ({ value }) =>
      value.includes('@') ? undefined : 'Enter a valid email.',
    onSubmit: ({ value }) =>
      value.endsWith('@example.com') ? 'Use a personal email.' : undefined,
  }}
>
  {(field) => (
    <>
      {field.state.meta.errorMap.onChange ? (
        <InlineHint>{field.state.meta.errorMap.onChange}</InlineHint>
      ) : null}
      {field.state.meta.errorMap.onSubmit ? (
        <Alert>{field.state.meta.errorMap.onSubmit}</Alert>
      ) : null}
    </>
  )}
</form.Field>
```

Map server validation to fields from a form validator when the server validates the whole payload:

```tsx
const form = useForm({
  defaultValues,
  validators: {
    onSubmitAsync: async ({ value }) => {
      const result = await validateCheckout(value)

      if (result.ok) return undefined

      return {
        form: result.message,
        fields: {
          'contact.email': result.fieldErrors.email,
          'shipping.postalCode': result.fieldErrors.postalCode,
        },
      }
    },
  },
})
```

Antipatterns:

- Rendering errors before the field is touched unless the UX explicitly wants immediate errors.
- Joining object errors with `errors.join(', ')` and displaying `[object Object]`.
- Hiding form-level errors when the API can return non-field failures.
- Assuming Standard Schema form-level errors are always strings. Schema errors can be records keyed by field name.

## Reactivity and Performance

TanStack Form does not rerender React components automatically just because form state changes. Subscribe to the exact state needed.

Good UI subscription:

```tsx
<form.Subscribe
  selector={(state) => [state.canSubmit, state.isSubmitting, state.isPristine]}
>
  {([canSubmit, isSubmitting, isPristine]) => (
    <button
      type="submit"
      aria-disabled={!canSubmit || isPristine || isSubmitting}
    >
      {isSubmitting ? 'Saving...' : 'Save'}
    </button>
  )}
</form.Subscribe>
```

Good logic subscription:

```tsx
const country = useStore(form.store, (state) => state.values.shipping.country)
const requiresProvince = country === 'US' || country === 'CA'
```

Antipattern:

```tsx
// Rerenders for any form state change in a large form.
const formState = useStore(form.store)
```

Better:

```tsx
const canSubmit = useStore(form.store, (state) => state.canSubmit)
```

Use `form.Subscribe` for UI fragments because it rerenders only the subscription child, not the whole parent component. Use `useStore` when component logic needs the value.

Avoid `useField` for broad reactivity outside of thoughtful field components. The official docs discourage it for this use case; prefer store selectors or `form.Subscribe`.

Remember that dirty state is persistent in TanStack Form. A field can remain `isDirty` after returning to its default value. Use `isDefaultValue` to recreate non-persistent dirty behavior:

```tsx
const hasUnsavedChanges = useStore(
  form.store,
  (state) => !state.isDefaultValue,
)
```

## Linked Fields and Side Effects

Use linked-field validators when another field should trigger revalidation:

```tsx
<form.Field
  name="confirmPassword"
  validators={{
    onChangeListenTo: ['password'],
    onChange: ({ value, fieldApi }) =>
      value === fieldApi.form.getFieldValue('password')
        ? undefined
        : 'Passwords do not match',
  }}
>
  {(field) => <PasswordInput field={field} />}
</form.Field>
```

Use listeners when a change should cause a side effect:

```tsx
<form.Field
  name="shipping.country"
  listeners={{
    onChange: ({ value }) => {
      form.setFieldValue('shipping.province', '')
      form.setFieldValue('shipping.postalCode', '')
      void shippingQuoteCache.prefetch(value)
    },
    onChangeDebounceMs: 300,
  }}
>
  {(field) => <CountrySelect field={field} />}
</form.Field>
```

Antipatterns:

- Resetting another field inside a validator.
- Revalidating dependent fields manually in event handlers when `onChangeListenTo` or `onBlurListenTo` is the correct model.
- Using listeners to return validation errors. Listeners are for side effects; validators are for errors.
- Forgetting to debounce listener-driven API calls.

## Arrays and Nested Data

Use `mode="array"` for array values and the array field helpers for mutation.

Good line-item editor:

```tsx
<form.Field name="lineItems" mode="array">
  {(itemsField) => (
    <section>
      {itemsField.state.value.map((item, index) => (
        <div key={item.id}>
          <form.Field name={`lineItems[${index}].sku`}>
            {(field) => <SkuCombobox field={field} />}
          </form.Field>
          <form.Field name={`lineItems[${index}].quantity`}>
            {(field) => (
              <QuantityInput
                value={field.state.value}
                onChange={field.handleChange}
                onBlur={field.handleBlur}
              />
            )}
          </form.Field>
          <button type="button" onClick={() => itemsField.removeValue(index)}>
            Remove
          </button>
        </div>
      ))}
      <button
        type="button"
        onClick={() =>
          itemsField.pushValue({
            id: crypto.randomUUID(),
            sku: '',
            quantity: 1,
          })
        }
      >
        Add item
      </button>
    </section>
  )}
</form.Field>
```

Use `insertValue`, `replaceValue`, `removeValue`, `swapValues`, `moveValue`, and `clearValues` through the array field when editing dynamic lists. Use stable domain IDs as React keys when items can be reordered.

Antipatterns:

- Mutating `field.state.value` directly.
- Using array indexes as React keys in reorderable collections when items have stable IDs.
- Keeping array UI state outside the form when it belongs in the submitted payload.
- Forgetting that nested field names are index-based, for example `lineItems[2].quantity`.

## Form Groups and Wizards

Use `form.FormGroup` for sub-forms inside one parent form, especially multi-step flows. This avoids splitting each step into an unrelated form and then manually stitching together submission and validation.

Good wizard pattern:

```tsx
const [step, setStep] = useState<'account' | 'billing'>('account')

const form = useForm({
  defaultValues: {
    account: { email: '', password: '' },
    billing: { plan: 'team', seats: 5 },
  },
})

return (
  <>
    {step === 'account' ? (
      <form.FormGroup
        name="account"
        validators={{ onSubmit: accountSchema }}
        onGroupSubmit={() => setStep('billing')}
      >
        {(group) => (
          <form
            onSubmit={(event) => {
              event.preventDefault()
              event.stopPropagation()
              void group.handleSubmit()
            }}
          >
            <group.Field name="email">
              {(field) => <EmailInput field={field} />}
            </group.Field>
            <button type="submit">Continue</button>
          </form>
        )}
      </form.FormGroup>
    ) : null}
  </>
)
```

Group validation uses field names relative to the group:

```tsx
<form.FormGroup
  name="account"
  validators={{
    onChange: ({ value }) => ({
      fields: {
        email: value.email ? undefined : 'Email is required',
      },
    }),
  }}
/>
```

For dynamic group validation, put `onDynamic` on the group itself instead of assuming the parent form's dynamic validator will run when a sub-form is submitted.

Antipatterns:

- Building each wizard step as a fully separate form and merging values manually at the end.
- Returning full parent paths from group validators. Use keys relative to the group.
- Using parent `onDynamic` validation as the only validation for sub-form submission.

## Async Initial Values

Use TanStack Query or the application's existing cache layer to load edit data. Do not put ad hoc fetching, cache invalidation, and loading state directly inside field components.

Good pattern:

```tsx
function EditCustomerPage({ customerId }: { customerId: string }) {
  const customerQuery = useQuery({
    queryKey: ['customer', customerId],
    queryFn: () => customers.get(customerId),
  })

  const form = useForm({
    defaultValues: {
      name: customerQuery.data?.name ?? '',
      email: customerQuery.data?.email ?? '',
    },
    onSubmit: async ({ value }) => {
      await customers.update(customerId, value)
    },
  })

  if (customerQuery.isLoading) return <Spinner />
  if (customerQuery.isError) return <LoadError />

  return <CustomerForm form={form} />
}
```

Decide how reinitialization should work when fetched data changes. For edit screens, do not silently overwrite user edits after the form has become dirty. If the app needs to refresh values, use an explicit reset action or compare `isDefaultValue`/dirty metadata before resetting.

Antipatterns:

- Rendering empty defaults, letting the user type, and then overwriting values when data arrives.
- Fetching the same record independently in every field component.
- Treating async initial values as validation errors instead of load state.

## Submission Handling

Always prevent native form submission and stop propagation when the surrounding framework or parent forms can observe submit events.

```tsx
<form
  onSubmit={(event) => {
    event.preventDefault()
    event.stopPropagation()
    void form.handleSubmit()
  }}
>
  {/* fields */}
</form>
```

Use `onSubmitMeta` when the same form has multiple submit actions:

```tsx
type SubmitMeta = {
  action: 'saveDraft' | 'publish'
}

const form = useForm({
  defaultValues,
  onSubmitMeta: { action: 'saveDraft' } satisfies SubmitMeta,
  onSubmit: async ({ value, meta }) => {
    if (meta.action === 'saveDraft') {
      await saveDraft(value)
    } else {
      await publish(value)
    }
  },
})

<button
  type="button"
  onClick={() => void form.handleSubmit({ action: 'saveDraft' })}
>
  Save draft
</button>
<button
  type="button"
  onClick={() => void form.handleSubmit({ action: 'publish' })}
>
  Publish
</button>
```

Use `onSubmitInvalid` for focus management or analytics on failed submissions:

```tsx
const form = useForm({
  defaultValues,
  validators: { onChange: schema },
  onSubmitInvalid: () => {
    const firstInvalid = document.querySelector(
      '[aria-invalid="true"]',
    ) as HTMLInputElement | null

    firstInvalid?.focus()
  },
})
```

Antipatterns:

- Relying on schema transforms without parsing in `onSubmit`.
- Triggering multiple submit actions through submit buttons and native form behavior without explicit `handleSubmit` metadata.
- Using `<button type="reset" onClick={() => form.reset()}>` without `event.preventDefault()`. Prefer `type="button"` for custom resets.

## UI Libraries and Accessibility

Keep TanStack Form headless. Translate field state into the host app's design-system contract.

Good shadcn-style checkbox:

```tsx
<form.Field name="acceptedTerms">
  {(field) => (
    <Checkbox
      checked={field.state.value}
      onCheckedChange={(checked) => field.handleChange(checked === true)}
      onBlur={field.handleBlur}
      aria-invalid={!field.state.meta.isValid || undefined}
    />
  )}
</form.Field>
```

Good Material UI-style text field:

```tsx
<form.Field name="email">
  {(field) => (
    <TextField
      id={field.name}
      name={field.name}
      value={field.state.value}
      onChange={(event) => field.handleChange(event.target.value)}
      onBlur={field.handleBlur}
      error={field.state.meta.isTouched && !field.state.meta.isValid}
      helperText={
        field.state.meta.isTouched
          ? field.state.meta.errors.join(', ')
          : undefined
      }
    />
  )}
</form.Field>
```

Accessibility practices:

- Connect labels to fields with `htmlFor`/`id` or the UI library's equivalent.
- Use `aria-invalid` only when the field is invalid and the UX is ready to expose the error.
- Render validation messages in an accessible error region, such as `role="alert"` when immediate announcement is desired.
- If avoiding disabled buttons for accessibility, use `aria-disabled` and guard the submit handler.
- In React Native, manage focus with refs because DOM query APIs are unavailable.

Antipatterns:

- Replacing the app's UI library with raw inputs just because an official example uses plain HTML.
- Passing TanStack field props wholesale into a UI component whose event/value contract differs.
- Showing errors visually without linking or announcing them accessibly.

## Testing and Debugging

Test behavior, not only rendering.

High-value test cases:

- Initial values render correctly after sync and async data loads.
- `onBlur` validators do not run until blur.
- Submit-first dynamic validation shows errors on submit and revalidates with the configured post-submit mode.
- Async validators debounce network calls and surface `isValidating` UI.
- Server errors map to nested fields and form-level alerts.
- Array add/remove/reorder operations preserve intended values.
- Dependent fields revalidate through `onChangeListenTo` or reset through listeners.
- Reset uses `form.reset()` without native reset side effects.
- `onSubmitMeta` chooses the correct save/publish/back action.

Debugging practices:

- Add TanStack Form Devtools in development for complex flows.
- Inspect `field.state.meta.errorMap` when an error appears under the wrong validation source.
- Inspect `form.state.fieldMeta` when the UI and validation disagree.
- Confirm that the form subscribes to the state it renders.
- Confirm package versions and TypeScript settings before chasing type inference issues. The official TypeScript docs require `strict: true`, TypeScript 5.4 or newer, and recommend locking `@tanstack/react-form` to a patch version because type improvements can ship in patch releases.

## Review Checklist

Use this checklist during code review:

- The value type, defaults, and field names describe the same object.
- The implementation uses current official option names and APIs.
- Field controls pass the correct typed value into `field.handleChange`.
- `handleBlur` is wired when blur validation exists.
- Standard Schema transforms are parsed explicitly in submit code when transformed output is needed.
- Dynamic validation includes `revalidateLogic()`.
- Async validators and listener-side network calls are debounced.
- Validators are pure and listeners contain side effects.
- Store subscriptions use selectors or `form.Subscribe`.
- Arrays use field helper methods instead of direct mutation.
- Form groups use relative error keys and group-specific validation.
- Server errors are mapped to `form` and `fields` intentionally.
- Error UI handles non-string custom errors safely.
- Reset avoids native reset conflicts.
- Accessibility semantics match the app's standards.
- Tests cover the validation timing and submission paths touched by the change.
