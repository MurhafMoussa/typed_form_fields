import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:typed_form_fields/src/models/models.dart';
import 'package:typed_form_fields/src/services/form_field_manager.dart';
import 'package:typed_form_fields/src/services/form_state_computer.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

part 'core_form_cubit.freezed.dart';
part 'core_form_state.dart';

/// Form cubit with type-safe state access
class CoreFormCubit extends Cubit<CoreFormState> {
  CoreFormCubit({
    List<TypedFormField> fields = const [],
    ValidationType validationType = ValidationType.allFields,
  }) : super(CoreFormState.initial()) {
    _fieldManager = FormFieldManager(fields: fields);
    _stateComputer = FormStateComputer();

    // Single emit call with all initial values
    emit(
      CoreFormState(
        values: _fieldManager.getInitialValues(),
        errors: {},
        isValid: false,
        validationType: validationType,
        fieldTypes: _fieldManager.getFieldTypes(),
      ),
    );
  }

  late final FormFieldManager _fieldManager;
  late final FormStateComputer _stateComputer;

  /// Type-safe getter for field values
  T? getValue<T>(String fieldName) => state.getValue<T>(fieldName);

  /// Type-safe update method for a single field
  void updateField<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
  }) {
    // Field existence check
    if (!_fieldManager.fieldExists(fieldName)) {
      throw ArgumentError('Field "$fieldName" does not exist');
    }

    // Type check
    if (value != null) {
      final expectedType = _fieldManager.getFieldType(fieldName);
      if (expectedType != null && expectedType != T) {
        throw TypeError();
      }
    }

    // Mark this field as touched
    _fieldManager.markFieldAsTouched(fieldName);

    // Compute new state using the state computer
    final newState = _stateComputer.computeFieldUpdateState(
      fieldName: fieldName,
      value: value,
      currentValues: state.values,
      currentErrors: state.errors,
      validationType: state.validationType,
      fieldManager: _fieldManager,
      context: context,
    );

    _emitIfChanged(newState);
  }

  /// Type-safe update method for a single field with debouncing
  void updateFieldWithDebounce<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
  }) {
    // Field existence check
    if (!_fieldManager.fieldExists(fieldName)) {
      throw ArgumentError('Field "$fieldName" does not exist');
    }

    // Type check
    if (value != null) {
      final expectedType = _fieldManager.getFieldType(fieldName);
      if (expectedType != null && expectedType != T) {
        throw TypeError();
      }
    }

    // Mark this field as touched
    _fieldManager.markFieldAsTouched(fieldName);

    // Compute new state using debounced validation
    _stateComputer.computeFieldUpdateStateWithDebounce(
      fieldName: fieldName,
      value: value,
      currentValues: state.values,
      currentErrors: state.errors,
      validationType: state.validationType,
      fieldManager: _fieldManager,
      context: context,
      onStateComputed: (newState) {
        _emitIfChanged(newState);
      },
    );
  }

  /// Updates multiple fields at once with a single state emission
  void updateFields<T>({
    required Map<String, T?> fieldValues,
    required BuildContext context,
  }) {
    // Field existence and type check, then mark fields as touched
    for (final entry in fieldValues.entries) {
      final fieldName = entry.key;
      final value = entry.value;

      // Field existence check
      if (!_fieldManager.fieldExists(fieldName)) {
        throw ArgumentError('Field "$fieldName" does not exist');
      }

      // Type check
      if (value != null) {
        final expectedType = _fieldManager.getFieldType(fieldName);
        if (expectedType != null && expectedType != T) {
          throw TypeError();
        }
      }
    }

    // Mark fields as touched
    _fieldManager.markFieldsAsTouched(fieldValues.keys.toList());

    // Compute new state using the state computer
    final newState = _stateComputer.computeFieldsUpdateState(
      fieldValues: fieldValues,
      currentValues: state.values,
      currentErrors: state.errors,
      validationType: state.validationType,
      fieldManager: _fieldManager,
      context: context,
    );

    _emitIfChanged(newState);
  }

  /// Call this when you need to change the validation rules for a field based on
  /// other state in your application (e.g., making a field required based on a checkbox).
  void updateFieldValidators<T>({
    required String name,
    required List<Validator<T>> validators,
    required BuildContext context,
  }) {
    // Update field validators using the field manager
    _fieldManager.updateFieldValidators<T>(name: name, validators: validators);

    // Re-validate all fields with the new rules to update errors and form validity
    final newErrors = _stateComputer.validationService.validateFields(
      values: state.values,
      validators: _fieldManager.validators,
      context: context,
    );
    final newIsValid = _stateComputer.validationService.computeOverallValidity(
      values: state.values,
      validators: _fieldManager.validators,
      touchedFields: _fieldManager.touchedFields,
      context: context,
    );

    // Emit the new state with updated errors and validity
    _emitIfChanged(state.copyWith(errors: newErrors, isValid: newIsValid));
  }

  /// Emits new state only if it's different from the current state
  void _emitIfChanged(CoreFormState newState) {
    if (newState != state) {
      emit(newState);
    }
  }

  /// Sets a new validation type for the form
  void setValidationType(ValidationType validationType) {
    _emitIfChanged(state.copyWith(validationType: validationType));
  }

  /// Validates the entire form
  void validateForm(
    BuildContext context, {
    required VoidCallback onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    if (state.validationType == ValidationType.onSubmit) {
      final newErrors = _stateComputer.validationService.validateFields(
        values: state.values,
        validators: _fieldManager.validators,
        context: context,
      );
      _emitIfChanged(
        state.copyWith(errors: newErrors, isValid: newErrors.isEmpty),
      );
    }

    if (state.isValid) {
      onValidationPass();
    } else {
      onValidationFail?.call();
      setValidationType(ValidationType.fieldsBeingEdited);
    }
  }

  /// Validates a field immediately (no debouncing)
  ///
  /// This is useful for blur events, form submission, etc.
  void validateFieldImmediately({
    required String fieldName,
    required BuildContext context,
  }) {
    if (!_fieldManager.fieldExists(fieldName)) {
      throw ArgumentError('Field "$fieldName" does not exist');
    }

    final value = state.values[fieldName];
    final validator = _fieldManager.validators[fieldName];

    if (validator != null) {
      final error = _stateComputer.validationService.validateField(
        validator: validator,
        value: value,
        context: context,
      );

      final newErrors = Map<String, String>.from(state.errors);
      if (error != null) {
        newErrors[fieldName] = error;
      } else {
        newErrors.remove(fieldName);
      }

      final overallValid =
          _stateComputer.validationService.computeOverallValidity(
        values: state.values,
        validators: _fieldManager.validators,
        touchedFields: _fieldManager.touchedFields,
        context: context,
      );

      _emitIfChanged(state.copyWith(errors: newErrors, isValid: overallValid));
    }
  }

  /// Resets the form to its initial state
  void resetForm() {
    // Reset all fields to their initial values
    _fieldManager.resetTouchedFields();

    // Reset to null values (as expected by tests)
    final resetValues = <String, Object?>{};
    for (final fieldName in _fieldManager.validators.keys) {
      resetValues[fieldName] = null;
    }

    _emitIfChanged(
      state.copyWith(values: resetValues, errors: {}, isValid: false),
    );
  }

  /// Marks all fields as touched and validates them
  void touchAllFields(BuildContext context) {
    // Mark all fields as touched
    _fieldManager.markAllFieldsAsTouched();

    // Validate all fields
    final newErrors = _stateComputer.validationService.validateFields(
      values: state.values,
      validators: _fieldManager.validators,
      context: context,
    );

    // Update state
    _emitIfChanged(
      state.copyWith(
        errors: newErrors,
        isValid: _stateComputer.validationService.computeOverallValidity(
          values: state.values,
          validators: _fieldManager.validators,
          touchedFields: _fieldManager.touchedFields,
          context: context,
        ),
      ),
    );
  }

  /// Manually set an error for a specific field
  ///
  /// This allows setting custom validation errors from outside the normal validation flow.
  /// Useful for server-side validation errors or custom validation logic.
  ///
  /// Parameters:
  /// - [fieldName]: The name of the field to set the error for
  /// - [errorMessage]: The error message to display. If null, any existing error is cleared.
  void updateError({
    required String fieldName,
    String? errorMessage,
    required BuildContext context,
  }) {
    // Ensure the field exists
    if (!_fieldManager.fieldExists(fieldName)) {
      throw ArgumentError('Field "$fieldName" does not exist in the form');
    }

    final newErrors = Map<String, String>.from(state.errors);

    if (errorMessage != null) {
      newErrors[fieldName] = errorMessage;
    } else {
      newErrors.remove(fieldName);
    }

    // Mark field as touched since we're manually validating it
    _fieldManager.markFieldAsTouched(fieldName);

    // Compute overall validity based on current values and new errors
    final overallValid =
        _stateComputer.validationService.computeOverallValidityWithErrors(
      values: state.values,
      errors: newErrors,
      touchedFields: _fieldManager.touchedFields,
      validators: _fieldManager.validators,
      context: context,
    );

    _emitIfChanged(state.copyWith(errors: newErrors, isValid: overallValid));
  }

  /// Manually set multiple errors at once
  ///
  /// This allows setting custom validation errors for multiple fields.
  /// Useful for handling server-side validation responses.
  ///
  /// Parameters:
  /// - [errors]: Map of field names to error messages. If a field's error is null, any existing error is cleared.
  void updateErrors({
    required Map<String, String?> errors,
    required BuildContext context,
  }) {
    final newErrors = Map<String, String>.from(state.errors);

    // Process each error
    for (final entry in errors.entries) {
      final fieldName = entry.key;
      final errorMessage = entry.value;

      // Ensure the field exists
      if (!_fieldManager.fieldExists(fieldName)) {
        throw ArgumentError('Field "$fieldName" does not exist in the form');
      }

      // Mark field as touched since we're manually validating it
      _fieldManager.markFieldAsTouched(fieldName);

      if (errorMessage != null) {
        newErrors[fieldName] = errorMessage;
      } else {
        newErrors.remove(fieldName);
      }
    }

    // Compute overall validity based on current values and new errors
    final overallValid =
        _stateComputer.validationService.computeOverallValidityWithErrors(
      values: state.values,
      errors: newErrors,
      touchedFields: _fieldManager.touchedFields,
      validators: _fieldManager.validators,
      context: context,
    );
    _emitIfChanged(state.copyWith(errors: newErrors, isValid: overallValid));
  }

  /// Disposes of all resources
  @override
  Future<void> close() {
    _stateComputer.debouncedValidationService.dispose();
    return super.close();
  }
}
