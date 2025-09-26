# Typed Form Fields

A **production-ready** Flutter package for **type-safe form validation** with **universal widget integration**. The high-performance `FieldWrapper<T>` widget makes any Flutter widget work seamlessly with reactive form validation.

## 🏆 **Production Ready**

- ✅ **18 files at 100% test coverage**
- ✅ **457 comprehensive tests**
- ✅ **Performance optimized** with BlocConsumer
- ✅ **TDD approach** with extensive edge case testing
- ✅ **Production-grade error handling**

## 🚀 **Key Features**

### ✅ **FieldWrapper<T> - High-Performance Universal Form Integration**

The `FieldWrapper<T>` is the **core widget** that transforms any Flutter widget into a reactive, validated form field with **optimized performance**:

```dart
FieldWrapper<String>(
  fieldName: 'email',
  debounceTime: Duration(milliseconds: 300),
  transformValue: (value) => value.toLowerCase().trim(),
  onFieldStateChanged: (value, error, hasError) {
    // React to changes without rebuilding
    print('Field changed: $value, hasError: $hasError');
  },
  builder: (context, value, error, hasError, updateValue) {
    // Use ANY Flutter widget here!
    return TextFormField(
      initialValue: value,
      onChanged: updateValue,
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: hasError ? error : null,
      ),
    );
  },
)
```

**Performance Features**:

- 🚀 **BlocConsumer** with `buildWhen`/`listenWhen` for minimal rebuilds
- 🎯 **Field-specific updates** - only rebuilds when relevant data changes
- 📡 **Listener support** - react to changes without triggering rebuilds
- ⚡ **Debouncing** - optimized for rapid input scenarios

**Works with ANY widget**: TextField, Checkbox, Slider, Dropdown, Radio, Switch, or your custom widgets!

### ✅ **Complete Validation System**

- **11 Languages**: Built-in localization support
- **Cross-field validation**: Password confirmation, field matching
- **Conditional validation**: Rules that change based on other fields
- **Composite validation**: Combine multiple validators
- **BLoC integration**: Reactive state management
- **Performance**: Debouncing, caching, efficient updates

## 🎨 **Pre-built Widgets**

The library includes **7 production-ready widgets** that work seamlessly with the form system:

### 📝 **Text Input Widgets**

#### `TypedTextField`

Universal text input with all TextFormField parameters:

```dart
TypedTextField(
  name: 'email',
  label: 'Email Address',
  keyboardType: TextInputType.emailAddress,
  hintText: 'Enter your email',
  obscureText: false, // For passwords
  maxLines: 1, // Or null for multiline
  debounceTime: Duration(milliseconds: 300),
  transformValue: (value) => value.toLowerCase().trim(),
)
```

### ✅ **Selection Widgets**

#### `TypedCheckbox`

Checkbox with title and subtitle support:

```dart
TypedCheckbox(
  name: 'terms',
  title: Text('I agree to the terms'),
  subtitle: Text('Please read our terms and conditions'),
  tristate: false, // true/false/null support
)
```

#### `TypedSwitch`

Switch with title and subtitle support:

```dart
TypedSwitch(
  name: 'notifications',
  title: Text('Enable notifications'),
  subtitle: Text('Receive push notifications'),
  activeColor: Colors.green,
)
```

#### `TypedDropdown<T>`

Generic dropdown with custom item builders:

```dart
TypedDropdown<String>(
  name: 'country',
  label: 'Select Country',
  items: ['USA', 'Canada', 'UK'],
  itemBuilder: (item) => Text('🌍 $item'),
  isExpanded: true,
)
```

### 🎚️ **Range Widgets**

#### `TypedSlider`

Slider with value display and range validation:

```dart
TypedSlider(
  name: 'volume',
  label: 'Volume Level',
  min: 0.0,
  max: 100.0,
  divisions: 10,
  showValue: true,
  activeColor: Colors.blue,
)
```

### 📅 **Date & Time Widgets**

#### `TypedDatePicker`

Date picker with formatting options:

```dart
TypedDatePicker(
  name: 'birthdate',
  label: 'Date of Birth',
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
  dateFormat: 'dd/MM/yyyy',
  prefixIcon: Icon(Icons.calendar_today),
)
```

#### `TypedTimePicker`

Time picker with 12/24 hour support:

```dart
TypedTimePicker(
  name: 'meeting_time',
  label: 'Meeting Time',
  use24HourFormat: true,
  prefixIcon: Icon(Icons.access_time),
)
```

### 🔧 **All Widgets Support**

- **Form Integration** - Automatic state management via `FieldWrapper<T>`
- **Validation** - Built-in error display and validation
- **Customization** - All original widget parameters supported
- **Controllers** - Optional `TextEditingController` support with proper disposal
- **Debouncing** - Configurable update delays
- **Value Transformation** - Transform values before storing
- **Localization** - Error messages in 11 languages

## Installation

```bash
flutter pub add typed_form_fields
```

## Quick Start

### 🎯 **FieldWrapper Integration (Recommended)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [
              CommonValidators.required<String>(),
              CommonValidators.email(),
            ],
            initialValue: '',
          ),
          TypedFormField<bool>(
            name: 'subscribe',
            validators: [],
            initialValue: false,
          ),
        ],
      ),
      child: Column(
        children: [
          // Using pre-built widget
          TypedTextField(
            name: 'email',
            label: 'Email Address',
            keyboardType: TextInputType.emailAddress,
            debounceTime: Duration(milliseconds: 300),
          ),

          SizedBox(height: 16),

          // Using pre-built checkbox
          TypedCheckbox(
            name: 'subscribe',
            title: Text('Subscribe to newsletter'),
          ),

          SizedBox(height: 24),

          // Submit button with reactive validation
          BlocBuilder<CoreFormCubit, CoreFormState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isValid ? () {
                  // Type-safe access to form values
                  final email = state.getValue<String>('email');
                  final subscribe = state.getValue<bool>('subscribe');
                  print('Email: $email, Subscribe: $subscribe');
                } : null,
                child: Text('Submit'),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## 🎨 **Custom Validators**

Create powerful custom validators with full type safety:

```dart
// Simple custom validator
final customValidator = CommonValidators.custom<String>(
  (value) => value?.contains('@company.com') == true
      ? null
      : 'Must be a company email',
);

// Advanced custom validator with context
class CompanyEmailValidator extends Validator<String> {
  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;

    final allowedDomains = ['company.com', 'subsidiary.com'];
    final domain = value.split('@').last;

    return allowedDomains.contains(domain)
        ? null
        : 'Email must be from: ${allowedDomains.join(', ')}';
  }
}
```

## 📋 **Common Validators**

| Validator             | Description              | Example                                                                                      |
| --------------------- | ------------------------ | -------------------------------------------------------------------------------------------- |
| `required<T>()`       | Field cannot be empty    | `CommonValidators.required<String>()`                                                        |
| `email()`             | Valid email format       | `CommonValidators.email()`                                                                   |
| `minLength(int)`      | Minimum character length | `CommonValidators.minLength(8)`                                                              |
| `maxLength(int)`      | Maximum character length | `CommonValidators.maxLength(50)`                                                             |
| `pattern(RegExp)`     | Matches regex pattern    | `CommonValidators.pattern(RegExp(r'^\d+$'))`                                                 |
| `min(num)`            | Minimum numeric value    | `CommonValidators.min(18)`                                                                   |
| `max(num)`            | Maximum numeric value    | `CommonValidators.max(100)`                                                                  |
| `phoneNumber()`       | Valid phone number       | `CommonValidators.phoneNumber()`                                                             |
| `creditCard()`        | Valid credit card        | `CommonValidators.creditCard()`                                                              |
| `url()`               | Valid URL format         | `CommonValidators.url()`                                                                     |
| `custom<T>(function)` | **Your custom logic**    | `CommonValidators.custom<String>((v) => v?.contains('x') == true ? null : 'Must contain x')` |

## 🔗 **Cross-Field Validation**

```dart
// Password confirmation
CrossFieldValidators.matches('password', 'confirmPassword')

// Custom cross-field validator
class TotalBudgetValidator extends CrossFieldValidator {
  @override
  String get targetField => 'totalBudget';

  @override
  String? validateWithDependencies(
    dynamic value,
    Map<String, dynamic> allValues,
    BuildContext context,
  ) {
    final marketing = allValues['marketingBudget'] as double? ?? 0;
    final development = allValues['developmentBudget'] as double? ?? 0;
    final total = value as double? ?? 0;

    if (total < marketing + development) {
      return 'Total budget must be at least ${marketing + development}';
    }

    return null;
  }
}
```

## 🌍 **Localization**

Built-in support for 11 languages:

```dart
// Automatic localization
CommonValidators.required<String>().validate(null, context)
// Returns "Este campo es obligatorio." in Spanish
```

## 🔄 **Dynamic Form Updates**

The `CoreFormCubit` provides comprehensive APIs for **real-time form updates**:

### ✅ **Update Error Messages**

```dart
// Set custom error for a specific field (e.g., from API response)
context.read<CoreFormCubit>().updateError(
  fieldName: 'email',
  errorMessage: 'Email already exists',
  context: context,
);

// Clear error for a specific field
context.read<CoreFormCubit>().updateError(
  fieldName: 'email',
  errorMessage: null, // null clears the error
  context: context,
);

// Update multiple errors at once
context.read<CoreFormCubit>().updateErrors(
  errors: {
    'email': 'Email already exists',
    'username': 'Username is taken',
    'phone': null, // Clear phone error
  },
  context: context,
);
```

### ✅ **Update Validation Rules**

```dart
// Update validators for a field dynamically
context.read<CoreFormCubit>().updateFieldValidators<String>(
  name: 'password',
  validators: [
    CommonValidators.required<String>(),
    CommonValidators.minLength(12), // Increased security requirement
    CommonValidators.pattern(RegExp(r'^(?=.*[A-Z])(?=.*[!@#$%^&*])')),
  ],
  context: context,
);
```

### ✅ **Update Field Values**

```dart
// Update single field value
context.read<CoreFormCubit>().updateField<String>(
  fieldName: 'country',
  value: 'USA',
  context: context,
);

// Update multiple fields at once
context.read<CoreFormCubit>().updateFields<String>(
  fieldValues: {
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'john.doe@example.com',
  },
  context: context,
);
```

### ✅ **Update Validation Type**

```dart
// Change validation behavior for the entire form
context.read<CoreFormCubit>().setValidationType(ValidationType.onSubmit);

// Available validation types:
// - ValidationType.allFields: Validate all fields on every change
// - ValidationType.fieldsBeingEdited: Only validate fields being edited
// - ValidationType.onSubmit: Only validate on form submission
```

### ✅ **Dynamic Field Management**

```dart
// Add new fields dynamically
context.read<CoreFormCubit>().addField<String>(
  field: TypedFormField<String>(
    name: 'newField',
    validators: [CommonValidators.required<String>()],
    initialValue: '',
  ),
  context: context,
);

// Add multiple fields at once
context.read<CoreFormCubit>().addFields(
  fields: [
    TypedFormField<String>(name: 'field1', validators: [], initialValue: ''),
    TypedFormField<bool>(name: 'field2', validators: [], initialValue: false),
  ],
  context: context,
);

// Remove fields dynamically
context.read<CoreFormCubit>().removeField('fieldName', context: context);
context.read<CoreFormCubit>().removeFields(['field1', 'field2'], context: context);
```

### ✅ **Form Control Methods**

```dart
// Validate entire form (useful for submit buttons)
context.read<CoreFormCubit>().validateForm(
  context,
  onValidationPass: () => print('Form is valid!'),
  onValidationFail: () => print('Form has errors'),
);

// Validate specific field immediately (no debouncing)
context.read<CoreFormCubit>().validateFieldImmediately(
  fieldName: 'email',
  context: context,
);

// Mark all fields as touched and validate them
context.read<CoreFormCubit>().touchAllFields(context);

// Reset form to initial state
context.read<CoreFormCubit>().resetForm();
```

**Use Cases:**

- 🌐 **API Integration** - Handle server-side validation errors
- 🔐 **Conditional Validation** - Change rules based on user selections
- 📱 **Progressive Forms** - Add/remove fields as user progresses
- 🎯 **Dynamic Requirements** - Adjust validation based on business logic
- 🔄 **Multi-step Forms** - Update validation per step

## 🏗 **Architecture**

### Current Features (Production Ready)

- ✅ **FieldWrapper<T>** - Universal widget integration
- ✅ **Pre-built widgets** - 7 production-ready widgets (TextField, Checkbox, Switch, Dropdown, Slider, DatePicker, TimePicker)
- ✅ **Type-safe validation** - Compile-time type checking
- ✅ **Custom validators** - Easy to create and reuse
- ✅ **BLoC integration** - Reactive state management
- ✅ **Cross-field validation** - Field interdependencies
- ✅ **Conditional validation** - Dynamic validation rules
- ✅ **Localization** - 11 languages supported
- ✅ **Performance** - Debouncing, caching, efficient updates

## 🎯 **Why FieldWrapper?**

**Before FieldWrapper:**

```dart
// Lots of boilerplate, manual state management
TextFormField(
  controller: _controller,
  onChanged: (value) => _cubit.updateField('email', value, context),
  validator: (value) => _validator.validate(value, context),
  decoration: InputDecoration(
    errorText: _cubit.state.getError('email'),
  ),
)
```

**With FieldWrapper:**

```dart
// Clean, declarative, works with ANY widget
FieldWrapper<String>(
  fieldName: 'email',
  debounceTime: Duration(milliseconds: 300),
  transformValue: (value) => value.toLowerCase().trim(),
  builder: (context, value, error, hasError, updateValue) {
    return TextFormField(
      initialValue: value,
      onChanged: updateValue,
      decoration: InputDecoration(
        errorText: hasError ? error : null,
      ),
    );
  },
)
```

**Benefits:**

- 🎯 **Universal** - Works with any Flutter widget
- 🔒 **Type-safe** - Compile-time type checking
- ⚡ **Performance** - Built-in debouncing and optimization
- 🧩 **Composable** - Easy to combine and reuse
- 🎨 **Flexible** - Full control over UI while handling validation
- 🔄 **Reactive** - Automatic UI updates on state changes

## 📄 **License**

MIT License - see LICENSE file for details.

---

**Ready to build better forms?** Start with `FieldWrapper<T>` and create your custom validators! 🚀
