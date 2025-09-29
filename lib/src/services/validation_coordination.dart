import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

/// Result of validation orchestration
class ValidationCoordinationResult {
  final bool shouldValidate;
  final bool shouldSwitchStrategy;
  final ValidationStrategy? newStrategy;
  final Map<String, String> newErrors;
  final bool shouldRevalidate;
  final String? fieldName;
  final dynamic value;
  final List<Validator>? validators;

  const ValidationCoordinationResult({
    required this.shouldValidate,
    this.shouldSwitchStrategy = false,
    this.newStrategy,
    this.newErrors = const <String, String>{},
    this.shouldRevalidate = false,
    this.fieldName,
    this.value,
    this.validators,
  });
}

/// Interface for orchestrating form validation operations
abstract class ValidationCoordination {
  /// Get initial validation state
  TypedFormState getInitialValidationState({
    required ValidationStrategy validationStrategy,
  });

  /// Orchestrate validation based on strategy
  ValidationCoordinationResult coordinateValidation({
    required ValidationStrategy strategy,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
  });

  /// Orchestrate form submission validation
  ValidationCoordinationResult coordinateFormSubmission({
    required ValidationStrategy strategy,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
    required VoidCallback onValidationPass,
    required VoidCallback? onValidationFail,
  });

  /// Orchestrate single error update
  ValidationCoordinationResult coordinateErrorUpdate({
    required String fieldName,
    required String? errorMessage,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
  });

  /// Orchestrate multiple error updates
  ValidationCoordinationResult coordinateMultipleErrorUpdates({
    required Map<String, String?> errors,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
  });

  /// Orchestrate field validation
  ValidationCoordinationResult coordinateFieldValidation({
    required String fieldName,
    required dynamic value,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
  });

  /// Orchestrate validator updates
  ValidationCoordinationResult coordinateValidatorUpdate({
    required String fieldName,
    required List<Validator> validators,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
  });
}

/// Default implementation of ValidationCoordination
class DefaultValidationCoordination implements ValidationCoordination {
  DefaultValidationCoordination({required this.fieldRegistry});
  final FieldRegistry fieldRegistry;

  /// Helper method to check if two types are compatible
  bool _isTypeCompatible(Type actualType, Type expectedType) {
    // Direct type match
    if (actualType == expectedType) return true;

    // Handle nullable types - check if the non-nullable version matches
    final actualTypeString = actualType.toString();
    final expectedTypeString = expectedType.toString();

    // Remove '?' from nullable types for comparison
    final actualNonNullable = actualTypeString.replaceAll('?', '');
    final expectedNonNullable = expectedTypeString.replaceAll('?', '');

    return actualNonNullable == expectedNonNullable;
  }

  @override
  TypedFormState getInitialValidationState({
    required ValidationStrategy validationStrategy,
  }) {
    return TypedFormState(
      values: fieldRegistry.getInitialValues(),
      errors: {},
      isValid: validationStrategy.initialValidationState,
      validationStrategy: validationStrategy,
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }

  @override
  ValidationCoordinationResult coordinateValidation({
    required ValidationStrategy strategy,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
  }) {
    return ValidationCoordinationResult(
      shouldValidate: strategy.shouldValidateOnFieldUpdate(),
    );
  }

  @override
  ValidationCoordinationResult coordinateFormSubmission({
    required ValidationStrategy strategy,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
    required VoidCallback onValidationPass,
    required VoidCallback? onValidationFail,
  }) {
    final shouldValidate = strategy.shouldValidateOnSubmission();

    if (!shouldValidate) {
      return const ValidationCoordinationResult(shouldValidate: false);
    }

    // Check if strategy should switch after validation failure
    if (strategy.hasValidationErrorsFromEmptyValues(currentValues)) {
      return ValidationCoordinationResult(
        shouldValidate: true,
        shouldSwitchStrategy: true,
        newStrategy: strategy.getStrategyAfterValidationFailure(),
      );
    }

    return const ValidationCoordinationResult(shouldValidate: true);
  }

  @override
  ValidationCoordinationResult coordinateErrorUpdate({
    required String fieldName,
    required String? errorMessage,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
  }) {
    if (!fieldRegistry.fieldExists(fieldName)) {
      throw FormFieldError.fieldNotFound(
        fieldName: fieldName,
        availableFields: fieldRegistry.fieldNames,
        fieldTypes: fieldRegistry.fieldTypes,
        currentValues: currentValues,
      );
    }

    final newErrors = <String, String>{};
    // Copy existing errors, filtering out null values
    for (final entry in currentErrors.entries) {
      if (entry.value != null) {
        newErrors[entry.key] = entry.value!;
      }
    }

    // Add or update the field error
    if (errorMessage != null) {
      newErrors[fieldName] = errorMessage;
    } else {
      newErrors.remove(fieldName);
    }

    return ValidationCoordinationResult(
      shouldValidate: false,
      newErrors: newErrors,
      shouldRevalidate: true,
    );
  }

  @override
  ValidationCoordinationResult coordinateMultipleErrorUpdates({
    required Map<String, String?> errors,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
  }) {
    // Validate all field names exist
    for (final fieldName in errors.keys) {
      if (!fieldRegistry.fieldExists(fieldName)) {
        throw FormFieldError.fieldNotFound(
          fieldName: fieldName,
          availableFields: fieldRegistry.fieldNames,
          fieldTypes: fieldRegistry.fieldTypes,
          currentValues: currentValues,
        );
      }
    }

    final newErrors = <String, String>{};
    // Copy existing errors, filtering out null values
    for (final entry in currentErrors.entries) {
      if (entry.value != null) {
        newErrors[entry.key] = entry.value!;
      }
    }

    // Add new errors, filtering out null values
    for (final entry in errors.entries) {
      if (entry.value != null) {
        newErrors[entry.key] = entry.value!;
      } else {
        newErrors.remove(entry.key);
      }
    }

    return ValidationCoordinationResult(
      shouldValidate: false,
      newErrors: newErrors,
      shouldRevalidate: true,
    );
  }

  @override
  ValidationCoordinationResult coordinateFieldValidation({
    required String fieldName,
    required dynamic value,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
  }) {
    if (!fieldRegistry.fieldExists(fieldName)) {
      throw FormFieldError.fieldNotFound(
        fieldName: fieldName,
        availableFields: fieldRegistry.fieldNames,
        fieldTypes: fieldRegistry.fieldTypes,
        currentValues: currentValues,
      );
    }

    // Type validation - check if the value type matches the expected field type
    if (value != null) {
      final expectedType = fieldRegistry.getFieldType(fieldName);
      if (expectedType != null) {
        // Get the actual type of the value
        final actualType = value.runtimeType;

        // Check if types are compatible
        if (!_isTypeCompatible(actualType, expectedType)) {
          throw FormFieldError.typeMismatch(
            fieldName: fieldName,
            expectedType: expectedType,
            actualType: actualType,
            operation: 'orchestrateFieldValidation',
          );
        }
      }
    }

    return ValidationCoordinationResult(
      shouldValidate: true,
      fieldName: fieldName,
      value: value,
    );
  }

  @override
  ValidationCoordinationResult coordinateValidatorUpdate({
    required String fieldName,
    required List<Validator> validators,
    required Map<String, Object?> currentValues,
    required Map<String, String?> currentErrors,
    required BuildContext context,
  }) {
    if (!fieldRegistry.fieldExists(fieldName)) {
      throw FormFieldError.fieldNotFound(
        fieldName: fieldName,
        availableFields: fieldRegistry.fieldNames,
        fieldTypes: fieldRegistry.fieldTypes,
        currentValues: currentValues,
      );
    }

    return ValidationCoordinationResult(
      shouldValidate: false,
      shouldRevalidate: true,
      fieldName: fieldName,
      validators: validators,
    );
  }
}
