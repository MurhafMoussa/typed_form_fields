# Typed Form Fields

A powerful Flutter package for **type-safe form validation** with **universal widget integration**. The core `FieldWrapper<T>` widget makes any Flutter widget work seamlessly with reactive form validation.

## 🚀 **Key Features**

### ✅ **FieldWrapper<T> - Universal Form Integration**

The `FieldWrapper<T>` is the **core widget** that transforms any Flutter widget into a reactive, validated form field:

```dart
FieldWrapper<String>(
  fieldName: 'email',
  debounceTime: Duration(milliseconds: 300),
  transformValue: (value) => value.toLowerCase().trim(),
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

**Works with ANY widget**: TextField, Checkbox, Slider, Dropdown, Radio, Switch, or your custom widgets!

### ✅ **Custom Validators Made Easy**

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

// Use in FieldWrapper
FieldWrapper<String>(
  fieldName: 'email',
  builder: (context, value, error, hasError, updateValue) {
    return TextFormField(/* ... */);
  },
)

// Define in form fields
TypedFormField<String>(
  name: 'email',
  validators: [
    CommonValidators.required<String>(),
    CommonValidators.email(),
    CompanyEmailValidator(), // Your custom validator
  ],
)
```

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
              // Add your custom validators here!
              CommonValidators.custom<String>(
                (value) => value?.endsWith('.edu') == true
                    ? null
                    : 'Must be an educational email',
              ),
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
          // Email field - works with any widget!
          FieldWrapper<String>(
            fieldName: 'email',
            debounceTime: Duration(milliseconds: 300),
            transformValue: (value) => value.toLowerCase().trim(),
            builder: (context, value, error, hasError, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Educational Email',
                  errorText: hasError ? error : null,
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              );
            },
          ),

          SizedBox(height: 16),

          // Checkbox field - same FieldWrapper pattern!
          FieldWrapper<bool>(
            fieldName: 'subscribe',
            builder: (context, value, error, hasError, updateValue) {
              return CheckboxListTile(
                title: Text('Subscribe to newsletter'),
                value: value ?? false,
                onChanged: updateValue,
              );
            },
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

### 🔧 **Basic Validation (Without State Management)**

```dart
class SimpleForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) => CompositeValidator<String>([
              CommonValidators.required<String>(),
              CommonValidators.email(),
              // Custom validator inline
              CommonValidators.custom<String>(
                (value) => value?.contains('test') == true
                    ? 'Test emails not allowed'
                    : null,
              ),
            ]).validate(value, context),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Form is valid!
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

## 🎨 **Custom Validators**

### Simple Custom Validators

```dart
// Inline custom validator
final noTestEmails = CommonValidators.custom<String>(
  (value) => value?.contains('test') == true
      ? 'Test emails not allowed'
      : null,
);

// Age validator
final ageValidator = CommonValidators.custom<int>(
  (age) => age != null && age >= 18
      ? null
      : 'Must be 18 or older',
);

// Password strength
final strongPassword = CommonValidators.custom<String>(
  (password) {
    if (password == null || password.length < 12) {
      return 'Password must be at least 12 characters';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain special characters';
    }
    return null;
  },
);
```

### Advanced Custom Validators

```dart
// Custom validator class with localization
class UniqueUsernameValidator extends Validator<String> {
  final List<String> existingUsernames;

  const UniqueUsernameValidator(this.existingUsernames);

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;

    if (existingUsernames.contains(value.toLowerCase())) {
      // Use localization if available
      final localizations = ValidatorLocalizations.of(context);
      return localizations?.customMessage('Username already taken')
          ?? 'Username already taken';
    }

    return null;
  }
}

// Business rule validator
class BusinessHoursValidator extends Validator<DateTime> {
  @override
  String? validate(DateTime? value, BuildContext context) {
    if (value == null) return null;

    final hour = value.hour;
    final isWeekend = value.weekday > 5;

    if (isWeekend) {
      return 'Appointments not available on weekends';
    }

    if (hour < 9 || hour > 17) {
      return 'Appointments only available 9 AM - 5 PM';
    }

    return null;
  }
}

// Use custom validators
TypedFormField<String>(
  name: 'username',
  validators: [
    CommonValidators.required<String>(),
    CommonValidators.minLength(3),
    UniqueUsernameValidator(['admin', 'root', 'user']),
  ],
),
```

### Conditional Custom Validators

```dart
// Validator that depends on other form values
class ConditionalRequiredValidator extends Validator<String> {
  final String dependsOnField;
  final dynamic requiredWhenValue;

  const ConditionalRequiredValidator(this.dependsOnField, this.requiredWhenValue);

  @override
  String? validate(String? value, BuildContext context) {
    // Access form state through BLoC
    final formState = context.read<CoreFormCubit>().state;
    final dependentValue = formState.values[dependsOnField];

    if (dependentValue == requiredWhenValue) {
      return CommonValidators.required<String>().validate(value, context);
    }

    return null;
  }
}

// Usage
TypedFormField<String>(
  name: 'companyName',
  validators: [
    ConditionalRequiredValidator('accountType', 'business'),
  ],
),
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

// Custom localized validators
class LocalizedValidator extends Validator<String> {
  @override
  String? validate(String? value, BuildContext context) {
    if (value?.isEmpty == true) {
      final localizations = ValidatorLocalizations.of(context);
      return localizations.required;
    }
    return null;
  }
}
```

## 📚 **Examples**

- [**FieldWrapper Universal Integration**](examples/field_wrapper_example.dart) - Core feature with 5+ widget types
- [**Registration Form**](examples/registration_form.dart) - Complete form with custom validators
- [**Multi-Step Form**](examples/multi_step_form.dart) - Complex wizard with cross-field validation
- [**BLoC Integration**](examples/bloc_form.dart) - Advanced state management patterns

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

### Planned Features

- 🚧 **Form builder** - `EasyForm` for declarative form creation
- 🚧 **More field types** - File uploads, rich text, multi-select
- 🚧 **Advanced widgets** - Radio groups, chip selectors, rating widgets

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

## 🛠 **Troubleshooting**

**Validation not working?**

- Ensure you're using `BlocProvider` with `CoreFormCubit`
- Check that field names match between `TypedFormField` and `FieldWrapper`
- Verify validators are added to the field definition

**Type errors?**

- Make sure `FieldWrapper<T>` generic type matches your field type
- Use `state.getValue<T>('fieldName')` with correct type parameter

**Performance issues?**

- Add `debounceTime` to `FieldWrapper` for fields that update frequently
- Use `transformValue` to clean data before validation

## 📄 **License**

MIT License - see LICENSE file for details.

---

**Ready to build better forms?** Start with `FieldWrapper<T>` and create your custom validators! 🚀
