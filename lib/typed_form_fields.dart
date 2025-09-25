/// A type-safe, universal form field wrapper with BLoC integration.
///
/// This library provides generic FieldWrapper&lt;T&gt; for any data type with built-in
/// validation, debouncing, and performance optimizations.
library;

// Core exports
export 'src/core/core_form_cubit.dart';
// Models exports
export 'src/models/typed_form_field.dart';
export 'src/services/form_debounced_validation_service.dart';
export 'src/services/form_field_manager.dart';
export 'src/services/form_state_computer.dart';
// Services exports
export 'src/services/form_validation_service.dart';
export 'src/validators/composite_validator.dart';
// Validators exports
export 'src/validators/validators.dart';
// Widgets exports
export 'src/widgets/field_wrapper.dart';
export 'src/widgets/typed_checkbox.dart';
export 'src/widgets/typed_date_picker.dart';
export 'src/widgets/typed_dropdown.dart';
export 'src/widgets/typed_slider.dart';
export 'src/widgets/typed_switch.dart';
// Pre-built widgets
export 'src/widgets/typed_text_field.dart';
export 'src/widgets/typed_time_picker.dart';
