import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Service responsible for computing form state changes and validation
class StateCalculation {
  final ValidationDebounce _validationDebounce;
  StateCalculation({
    ValidationDebounce? debouncedValidationService,
  }) : _validationDebounce = debouncedValidationService ?? ValidationDebounce();

  /// Get the debounced validation service for direct access
  ValidationDebounce get validationDebounce => _validationDebounce;

  /// Compute new state after field update with debouncing
  void computeFieldUpdateStateWithDebounce({
    required String fieldName,
    required Object? value,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
    required FieldRegistry fieldRegistry,
    required void Function(TypedFormState) onStateComputed,
  }) {
    // Update values immediately
    final newValues = Map<String, Object?>.from(currentValues)
      ..[fieldName] = value;

    // Handle different validation strategies
    switch (validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        // No validation on field change - maintain current validation state
        onStateComputed(
          TypedFormState(
            values: newValues,
            errors: currentErrors,
            isValid: validationStrategy.initialValidationState,
            validationStrategy: validationStrategy,
            fieldTypes: fieldRegistry.fieldTypes,
          ),
        );
        break;

      case ValidationStrategy.allFieldsRealTime:
        // Debounced validation for all fields
        _validationDebounce.validateAllFieldsWithDebounce(
          values: newValues,
          validators: fieldRegistry.validators,
          context: context,
          onValidationComplete: (errors) {
            final overallValid = computeOverallValidity(
              values: newValues,
              validators: fieldRegistry.validators,
              touchedFields: fieldRegistry.touchedFields,
              context: context,
            );
            onStateComputed(
              TypedFormState(
                values: newValues,
                errors: errors,
                isValid: overallValid,
                validationStrategy: validationStrategy,
                fieldTypes: fieldRegistry.fieldTypes,
              ),
            );
          },
        );
        break;

      case ValidationStrategy.realTimeOnly:
        // Debounced validation for current field only
        _validationDebounce.validateFieldWithDebounce(
          fieldName: fieldName,
          value: value,
          validators: fieldRegistry.validators,
          context: context,
          onValidationComplete: (error, errors) {
            final newErrors = Map<String, String>.from(currentErrors);
            if (error != null) {
              newErrors[fieldName] = error;
            } else {
              newErrors.remove(fieldName);
            }

            final overallValid = computeOverallValidity(
              values: newValues,
              validators: fieldRegistry.validators,
              touchedFields: fieldRegistry.touchedFields,
              context: context,
            );

            onStateComputed(
              TypedFormState(
                values: newValues,
                errors: newErrors,
                isValid: overallValid,
                validationStrategy: validationStrategy,
                fieldTypes: fieldRegistry.fieldTypes,
              ),
            );
          },
        );
        break;

      case ValidationStrategy.disabled:
        // No validation
        onStateComputed(
          TypedFormState(
            values: newValues,
            errors: {},
            isValid: false,
            validationStrategy: validationStrategy,
            fieldTypes: fieldRegistry.fieldTypes,
          ),
        );
        break;
    }
  }

  /// Compute new state after field update
  TypedFormState computeFieldUpdateState({
    required String fieldName,
    required Object? value,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
    required FieldRegistry fieldRegistry,
  }) {
    final newValues = Map<String, Object?>.from(currentValues)
      ..[fieldName] = value;
    final newErrors = Map<String, String>.from(currentErrors);

    // Update errors based on the active validation strategy
    switch (validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        // In onSubmit mode, we don't update errors on field change
        break;
      case ValidationStrategy.allFieldsRealTime:
        // Validate all fields when any field is updated
        newErrors.clear();
        newErrors.addAll(
          validateFields(
            values: newValues,
            validators: fieldRegistry.validators,
            context: context,
          ),
        );
        break;
      case ValidationStrategy.realTimeOnly:
        // Validate only the field being edited
        final validator = fieldRegistry.validators[fieldName];
        if (validator != null) {
          final error = validateField(
            validator: validator,
            value: value,
            context: context,
          );
          if (error != null) {
            newErrors[fieldName] = error;
          } else {
            newErrors.remove(fieldName);
          }
        }
        break;
      case ValidationStrategy.disabled:
        newErrors.clear();
        break;
    }

    // Compute overall validity
    final overallValid = validationStrategy == ValidationStrategy.disabled
        ? true // Always valid when validation is disabled
        : computeOverallValidity(
            values: newValues,
            validators: fieldRegistry.validators,
            touchedFields: fieldRegistry.touchedFields,
            context: context,
          );

    return TypedFormState(
      values: newValues,
      errors: newErrors,
      isValid: overallValid,
      validationStrategy: validationStrategy,
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }

  /// Compute new state after multiple field updates
  TypedFormState computeFieldsUpdateState({
    required Map<String, Object?> fieldValues,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
    required FieldRegistry fieldRegistry,
  }) {
    final newValues = Map<String, Object?>.from(currentValues);
    final newErrors = Map<String, String>.from(currentErrors);

    // Update values
    for (final entry in fieldValues.entries) {
      newValues[entry.key] = entry.value;
    }

    // Update errors based on validation strategy
    switch (validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        // No validation on field change
        break;
      case ValidationStrategy.allFieldsRealTime:
        // Validate all fields
        newErrors.clear();
        newErrors.addAll(
          validateFields(
            values: newValues,
            validators: fieldRegistry.validators,
            context: context,
          ),
        );
        break;
      case ValidationStrategy.realTimeOnly:
        // Validate only edited fields
        for (final fieldName in fieldValues.keys) {
          final validator = fieldRegistry.validators[fieldName];
          if (validator != null) {
            final value = newValues[fieldName];
            final error = validator.validate(value, context);
            if (error != null) {
              newErrors[fieldName] = error;
            } else {
              newErrors.remove(fieldName);
            }
          }
        }
        break;
      case ValidationStrategy.disabled:
        newErrors.clear();
        break;
    }

    return TypedFormState(
      values: newValues,
      errors: newErrors,
      isValid: computeOverallValidity(
        values: newValues,
        validators: fieldRegistry.validators,
        touchedFields: fieldRegistry.touchedFields,
        context: context,
      ),
      validationStrategy: validationStrategy,
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }

  /// Compute new state after error updates
  TypedFormState computeErrorUpdateState({
    required Map<String, String> newErrors,
    required Map<String, Object?> currentValues,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
    required FieldRegistry fieldRegistry,
  }) {
    return TypedFormState(
      values: currentValues,
      errors: newErrors,
      isValid: computeOverallValidityWithErrors(
        values: currentValues,
        errors: newErrors,
        touchedFields: fieldRegistry.touchedFields,
        validators: fieldRegistry.validators,
        context: context,
      ),
      validationStrategy: validationStrategy,
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }

  /// Compute new state after validation type change
  TypedFormState computeValidationStrategyChangeState({
    required ValidationStrategy newValidationStrategy,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required BuildContext context,
    required FieldRegistry fieldRegistry,
  }) {
    return TypedFormState(
      values: currentValues,
      errors: currentErrors,
      isValid: computeOverallValidity(
        values: currentValues,
        validators: fieldRegistry.validators,
        touchedFields: fieldRegistry.touchedFields,
        context: context,
      ),
      validationStrategy: newValidationStrategy,
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }

  // ===== VALIDATION METHODS (moved from FormValidationService) =====

  /// Validates a single field with its validator
  String? validateField<T>({
    required Validator validator,
    T? value,
    required BuildContext context,
  }) {
    return validator.validate(value, context);
  }

  /// Validates a single field by name and returns the error message if any
  String? validateFieldByName({
    required String fieldName,
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
  }) {
    final validator = validators[fieldName];
    if (validator == null) return null;

    final value = values[fieldName];
    return validator.validate(value, context);
  }

  /// Validates all fields based on the provided values map and returns a map of errors
  Map<String, String> validateFields({
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
  }) {
    final errors = <String, String>{};

    for (final fieldName in validators.keys) {
      final error = validateFieldByName(
        fieldName: fieldName,
        values: values,
        validators: validators,
        context: context,
      );
      if (error != null) {
        errors[fieldName] = error;
      }
    }

    return errors;
  }

  /// Computes the overall form validity
  bool computeOverallValidity({
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required Map<String, bool> touchedFields,
    required BuildContext context,
  }) {
    // Use the same field iteration as validateFields for consistency
    for (final fieldName in validators.keys) {
      // If the field hasn't been touched yet, the form is not valid
      if (touchedFields[fieldName] != true) return false;

      // If the field fails its validation, the form is not valid
      final error = validateFieldByName(
        fieldName: fieldName,
        values: values,
        validators: validators,
        context: context,
      );
      if (error != null) {
        return false;
      }
    }
    return true;
  }

  /// Computes the overall form validity without requiring touched fields
  /// This is useful for initial validation or when you want to check validity
  /// regardless of user interaction
  bool computeOverallValidityIgnoringTouched({
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
  }) {
    // Check if all fields pass validation, regardless of touched state
    for (final fieldName in validators.keys) {
      final error = validateFieldByName(
        fieldName: fieldName,
        values: values,
        validators: validators,
        context: context,
      );
      if (error != null) {
        return false;
      }
    }
    return true;
  }

  /// Computes the overall form validity with custom errors
  ///
  /// This is a variation of computeOverallValidity that takes explicit errors
  /// rather than computing them from validators.
  bool computeOverallValidityWithErrors({
    required Map<String, Object?> values,
    required Map<String, String> errors,
    required Map<String, bool> touchedFields,
    required Map<String, Validator> validators,
    required BuildContext context,
  }) {
    // If there are any errors, the form is not valid
    if (errors.isNotEmpty) return false;

    for (final field in values.keys) {
      // If the field hasn't been touched yet, the form is not valid
      if (touchedFields[field] != true) return false;

      // If the field fails its validation, the form is not valid
      final validator = validators[field];
      if (validator != null) {
        final value = values[field];
        if (validator.validate(value, context) != null) {
          return false;
        }
      }
    }
    return true;
  }

  /// Validates fields that depend on the changed field
  ///
  /// This method finds all validators that have the changed field as a dependency
  /// and re-validates those fields. This is more efficient than validating all fields.
  Map<String, String> validateDependentFields({
    required String changedFieldName,
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
  }) {
    final errors = <String, String>{};

    // Find all fields that depend on the changed field
    for (final entry in validators.entries) {
      final fieldName = entry.key;
      final validator = entry.value;

      // Check if this validator is a CrossFieldValidator that depends on the changed field
      if (validator is TypedCrossFieldValidator) {
        if (validator.dependentFields.contains(changedFieldName)) {
          final value = values[fieldName];
          final error = validator.validate(value, context);
          if (error != null) {
            errors[fieldName] = error;
          }
        }
      }
    }

    return errors;
  }
}
