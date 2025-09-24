import 'package:flutter/widgets.dart';
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
}
