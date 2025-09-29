import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/src/validators/typed_cross_field_validator.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

/// Service responsible for handling form validation logic
class FormValidationService {
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
      if (validator is TypedCrossFieldValidator &&
          validator.dependentFields.contains(changedFieldName)) {
        final value = values[fieldName];
        final error = validator.validate(value, context);
        if (error != null) {
          errors[fieldName] = error;
        }
      }
    }

    return errors;
  }

  /// Validates a field and its dependents
  ///
  /// This validates the specified field and any fields that depend on it.
  Map<String, String> validateFieldAndDependents({
    required String fieldName,
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
  }) {
    final errors = <String, String>{};

    // First validate the field itself
    final fieldError = validateFieldByName(
      fieldName: fieldName,
      values: values,
      validators: validators,
      context: context,
    );
    if (fieldError != null) {
      errors[fieldName] = fieldError;
    }

    // Then validate dependent fields
    final dependentErrors = validateDependentFields(
      changedFieldName: fieldName,
      values: values,
      validators: validators,
      context: context,
    );
    errors.addAll(dependentErrors);

    return errors;
  }
}
