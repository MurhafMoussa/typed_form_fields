import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// A high-performance universal wrapper widget that provides form validation integration
/// for any type of form field widget. This widget extracts the common
/// pattern used across all form fields for state management, validation,
/// and error handling with optimized rebuilds and listener support.
///
/// **Key Features:**
/// - **Universal**: Works with any widget type (TextField, Checkbox, Radio, etc.)
/// - **Performance Optimized**: Uses BlocConsumer with buildWhen/listenWhen for minimal rebuilds
/// - **BlocProvider Access**: Can reach CoreFormCubit from anywhere in subtree
/// - **Type Safety**: Generic support for different field value types
/// - **Debouncing**: Optional delayed updates for performance
/// - **Value Transformation**: Optional value processing before form updates
/// - **Error Handling**: Consistent error extraction and display
/// - **Listener Support**: React to field state changes without rebuilding
///
/// **Usage Example:**
/// ```dart
/// FieldWrapper<String>(
///   fieldName: 'email',
///   initialValue: 'user@example.com',
///   debounceTime: Duration(milliseconds: 300),
///   transformValue: (value) => value.toLowerCase().trim(),
///   onFieldStateChanged: (value, error, hasError) {
///     // React to field changes without rebuilding
///     print('Field changed: $value, hasError: $hasError');
///   },
///   builder: (context, value, error, hasError, updateValue) {
///     return TextFormField(
///       initialValue: value,
///       onChanged: updateValue,
///       decoration: InputDecoration(
///         labelText: 'Email',
///         errorText: hasError ? error : null,
///       ),
///     );
///   },
/// )
/// ```
class FieldWrapper<T> extends StatefulWidget {
  const FieldWrapper({
    super.key,
    required this.fieldName,
    required this.builder,
    this.initialValue,
    this.debounceTime,
    this.transformValue,
    this.onValueChanged,
    this.onFieldStateChanged,
  });

  /// Unique identifier for the field within the form.
  final String fieldName;

  /// Builder function that receives the current field state and returns a widget.
  ///
  /// Parameters:
  /// - `context`: Build context
  /// - `value`: Current field value (can be null)
  /// - `error`: Current error message (can be null)
  /// - `hasError`: Whether the field has an error
  /// - `updateValue`: Function to call when the field value changes
  final Widget Function(
    BuildContext context,
    T? value,
    String? error,
    bool hasError,
    void Function(T? value) updateValue,
  ) builder;

  /// Initial value for the field.
  final T? initialValue;

  /// Time to wait before triggering form updates after value changes.
  /// Useful for search fields or other scenarios where you want to
  /// reduce the number of form updates during rapid changes.
  final Duration? debounceTime;

  /// Function to transform the value before updating the form state.
  /// Useful for formatting or normalizing input.
  final T Function(T value)? transformValue;

  /// Callback fired when the field value changes (before debouncing).
  final void Function(T? value)? onValueChanged;

  /// Callback fired when the field state changes (value, error, or hasError).
  /// This listener is called without triggering a rebuild, making it perfect
  /// for side effects like logging, analytics, or triggering other actions.
  final void Function(T? value, String? error, bool hasError)?
      onFieldStateChanged;

  @override
  State<FieldWrapper<T>> createState() => _FieldWrapperState<T>();
}

class _FieldWrapperState<T> extends State<FieldWrapper<T>> {
  Timer? _debounceTimer;
  T? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;

    // Update form state with initial value if provided
    if (_currentValue != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateFormState(_currentValue);
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _updateValue(T? value) {
    setState(() {
      _currentValue = value;
    });

    // Call the immediate callback if provided
    widget.onValueChanged?.call(value);

    // Handle debounced form updates
    if (widget.debounceTime != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceTime!, () {
        _updateFormState(value);
      });
    } else {
      _updateFormState(value);
    }
  }

  void _updateFormState(T? value) {
    final transformedValue = value != null && widget.transformValue != null
        ? widget.transformValue!(value)
        : value;

    context.read<CoreFormCubit>().updateField(
          fieldName: widget.fieldName,
          value: transformedValue,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoreFormCubit, CoreFormState>(
      // Only rebuild when this specific field's data changes
      buildWhen: (previous, current) {
        final previousError = previous.errors[widget.fieldName];
        final currentError = current.errors[widget.fieldName];
        final previousValue = previous.values[widget.fieldName];
        final currentValue = current.values[widget.fieldName];

        // Rebuild if value or error state changed for this field
        return previousValue != currentValue || previousError != currentError;
      },

      // Listen to field state changes without rebuilding
      listenWhen: (previous, current) {
        final previousError = previous.errors[widget.fieldName];
        final currentError = current.errors[widget.fieldName];
        final previousValue = previous.values[widget.fieldName];
        final currentValue = current.values[widget.fieldName];

        // Listen when this field's state changes
        return previousValue != currentValue || previousError != currentError;
      },

      listener: (context, state) {
        // Call the field state change listener if provided
        if (widget.onFieldStateChanged != null) {
          final error = state.errors[widget.fieldName];
          final hasError = error != null && error.isNotEmpty;
          final formValue = state.values[widget.fieldName] as T?;
          final effectiveValue = formValue ?? _currentValue;

          widget.onFieldStateChanged!(effectiveValue, error, hasError);
        }
      },

      builder: (context, state) {
        final error = state.errors[widget.fieldName];
        final hasError = error != null && error.isNotEmpty;
        final formValue = state.values[widget.fieldName] as T?;

        // Use form value if available, otherwise use current local value
        final effectiveValue = formValue ?? _currentValue;

        return widget.builder(
          context,
          effectiveValue,
          error,
          hasError,
          _updateValue,
        );
      },
    );
  }
}
