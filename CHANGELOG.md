# Changelog

## 1.1.0 - Major Architecture Refactor: Typed Prefix Migration

### 🚀 **Breaking Changes**

- **Zero Dependencies Architecture**: Moved from `flutter_bloc` dependency to zero external dependencies

  - **Before**: Required `BlocProvider` and `CoreFormCubit` from `flutter_bloc`
  - **After**: Uses `TypedFormProvider` with built-in state management (no external dependencies)
  - **Migration**: Replace `BlocProvider(create: (context) => CoreFormCubit(...))` with `TypedFormProvider(...)`

- **Renamed core classes** to use "Typed" prefix for better clarity and consistency:
  - `FieldWrapper` → `TypedFieldWrapper`
  - `CoreFormCubit` → `TypedFormController`
  - `CoreFormState` → `TypedFormState`
  - `CommonValidators` → `TypedCommonValidators`
  - `CrossFieldValidators` → `TypedCrossFieldValidators`
  - `ConditionalValidator` → `TypedConditionalValidator`
  - `CompositeValidator` → `TypedCompositeValidator`
  - `ValidatorLocalizations` → `TypedValidatorLocalizations`

### ✨ **New Features**

- **Enhanced Form State Management**: Improved `TypedFormController` with better state handling and validation logic
- **Advanced Cross-Field Validation**: New static helper methods in `TypedCrossFieldValidators`:
  - `matches()` - Field value matching validation
  - `differentFrom()` - Field value difference validation
  - `requiredWhen()` - Conditional required field validation
  - `requiredWhenNotEmpty()` - Required when another field is not empty
  - `dateBefore()` / `dateAfter()` - Date comparison validations
  - `greaterThan()` / `lessThan()` - Numeric comparison validations
  - `sumCondition()` - Sum-based validation
  - `atLeastOneRequired()` - At least one field required validation
- **Improved Form Reset**: `resetForm()` now resets to initial values instead of null
- **Enhanced Form Listener**: `TypedFormListener` converted to StatefulWidget for better lifecycle management

### 🔧 **Improvements**

- **Better Test Coverage**: Achieved 100% test coverage for core validation components
- **Performance Optimizations**: Enhanced form state management and validation performance
- **Integration Testing**: Added comprehensive integration tests for end-to-end form functionality
- **Performance Benchmarking**: Added benchmark tests for form operations
- **Code Quality**: Removed test-specific code from production files
- **Documentation**: Updated README.md with correct class names and examples

### 🐛 **Bug Fixes**

- Fixed form state initialization issues in `TypedFormProvider`
- Fixed cross-field validation triggering in tests
- Fixed form reset behavior to use initial values
- Fixed integration test compilation and runtime errors
- Fixed benchmark test compilation issues
- Fixed logical inconsistencies in test expectations

### 📚 **Documentation**

- Updated all examples to use new "Typed" prefixed class names
- Enhanced README.md with corrected API references
- Improved code examples and usage patterns
- Updated package exports to include all Typed classes

### 🧪 **Testing**

- Added comprehensive integration tests for dynamic form scenarios
- Added performance benchmark tests
- Improved test coverage for cross-field validators
- Enhanced test coverage for common validators
- Added fallback error message testing
- Fixed all test compilation and runtime issues

## 1.0.0 - Initial Release

- 🎉 First public release of `typed_form_fields`!
- Type-safe, universal form field wrapper (`FieldWrapper<T>`) for any widget
- **Required `flutter_bloc` dependency** for state management
- Core form management: `CoreFormCubit`, `CoreFormState` (BLoC-based)
- Validation system: `CommonValidators`, `CrossFieldValidators`, `ConditionalValidator`, `CompositeValidator`
- Form field definition: `TypedFormField<T>` (already "Typed" prefixed)
- 7 pre-built widgets: TypedTextField, TypedCheckbox, TypedSwitch, TypedDropdown, TypedSlider, TypedDatePicker, TypedTimePicker
- Complete validation system: required, email, min/max, pattern, phone, credit card, URL, custom, and more
- Cross-field validation (e.g., password confirmation, field matching)
- Conditional validation (validate only when certain conditions are met)
- Composite and chainable validators
- BLoC integration for reactive state management
- Debouncing and performance optimizations
- Built-in localization for 11 languages
- Dynamic form updates: add/remove fields, update validation rules, update errors at runtime
- Full error handling and type safety
- Comprehensive documentation and examples
