import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Result of field management operations
class FieldLifecycleResult {
  final Map<String, Object?> newValues;
  final Map<String, Type> newFieldTypes;
  final Map<String, String> newErrors;
  final bool newIsValid;

  const FieldLifecycleResult({
    required this.newValues,
    required this.newFieldTypes,
    required this.newErrors,
    required this.newIsValid,
  });
}

/// Interface for managing form field addition and removal operations
abstract class FieldLifecycle {
  /// Add a single field to the form dynamically
  FieldLifecycleResult addField<T>({
    required FormFieldDefinition<T> field,
    required Map<String, Object?> currentValues,
    required Map<String, Type> currentFieldTypes,
    required Map<String, String> currentErrors,
    required BuildContext context,
  });

  /// Add multiple fields to the form dynamically
  FieldLifecycleResult addFields({
    required List<FormFieldDefinition> fields,
    required Map<String, Object?> currentValues,
    required Map<String, Type> currentFieldTypes,
    required Map<String, String> currentErrors,
    required BuildContext context,
  });

  /// Remove a single field from the form dynamically
  FieldLifecycleResult removeField({
    required String fieldName,
    required Map<String, Object?> currentValues,
    required Map<String, Type> currentFieldTypes,
    required Map<String, String> currentErrors,
    required BuildContext context,
  });

  /// Remove multiple fields from the form dynamically
  FieldLifecycleResult removeFields({
    required List<String> fieldNames,
    required Map<String, Object?> currentValues,
    required Map<String, Type> currentFieldTypes,
    required Map<String, String> currentErrors,
    required BuildContext context,
  });
}

/// Default implementation of FieldLifecycle
class DefaultFieldLifecycle implements FieldLifecycle {
  final StateCalculation stateCalculation;
  final FieldRegistry fieldRegistry;
  DefaultFieldLifecycle({
    required this.stateCalculation,
    required this.fieldRegistry,
  });
  @override
  FieldLifecycleResult addField<T>({
    required FormFieldDefinition<T> field,
    required Map<String, Object?> currentValues,
    required Map<String, Type> currentFieldTypes,
    required Map<String, String> currentErrors,
    required BuildContext context,
  }) {
    // Check if field already exists
    if (fieldRegistry.fieldExists(field.name)) {
      throw FormFieldError.fieldAlreadyExists(fieldName: field.name);
    }

    // Add field to field service
    fieldRegistry.addField(field);

    // Update form state with new field
    final newValues = Map<String, Object?>.from(currentValues);
    newValues[field.name] = field.initialValue;

    final newFieldTypes = Map<String, Type>.from(currentFieldTypes);
    newFieldTypes[field.name] = T;

    // Validate all fields to update form validity
    final newErrors = stateCalculation.validateFields(
      values: newValues,
      validators: fieldRegistry.validators,
      context: context,
    );

    final newIsValid = stateCalculation.computeOverallValidity(
      values: newValues,
      validators: fieldRegistry.validators,
      touchedFields: fieldRegistry.touchedFields,
      context: context,
    );

    return FieldLifecycleResult(
      newValues: newValues,
      newFieldTypes: newFieldTypes,
      newErrors: newErrors,
      newIsValid: newIsValid,
    );
  }

  @override
  FieldLifecycleResult addFields({
    required List<FormFieldDefinition> fields,
    required Map<String, Object?> currentValues,
    required Map<String, Type> currentFieldTypes,
    required Map<String, String> currentErrors,
    required BuildContext context,
  }) {
    // Check for existing fields
    for (final field in fields) {
      if (fieldRegistry.fieldExists(field.name)) {
        throw FormFieldError.fieldAlreadyExists(fieldName: field.name);
      }
    }

    // Add all fields to field service
    for (final field in fields) {
      fieldRegistry.addField(field);
    }

    // Update form state with new fields
    final newValues = Map<String, Object?>.from(currentValues);
    final newFieldTypes = Map<String, Type>.from(currentFieldTypes);

    for (final field in fields) {
      newValues[field.name] = field.initialValue;
      newFieldTypes[field.name] = field.valueType;
    }

    // Validate all fields to update form validity
    final newErrors = stateCalculation.validateFields(
      values: newValues,
      validators: fieldRegistry.validators,
      context: context,
    );

    final newIsValid = stateCalculation.computeOverallValidity(
      values: newValues,
      validators: fieldRegistry.validators,
      touchedFields: fieldRegistry.touchedFields,
      context: context,
    );

    return FieldLifecycleResult(
      newValues: newValues,
      newFieldTypes: newFieldTypes,
      newErrors: newErrors,
      newIsValid: newIsValid,
    );
  }

  @override
  FieldLifecycleResult removeField({
    required String fieldName,
    required Map<String, Object?> currentValues,
    required Map<String, Type> currentFieldTypes,
    required Map<String, String> currentErrors,
    required BuildContext context,
  }) {
    // Check if field exists
    if (!fieldRegistry.fieldExists(fieldName)) {
      throw FormFieldError.fieldNotFound(
        fieldName: fieldName,
        availableFields: fieldRegistry.fieldNames,
        fieldTypes: fieldRegistry.fieldTypes,
        currentValues: currentValues,
      );
    }

    // Remove field from field service
    fieldRegistry.removeField(fieldName);

    // Update form state by removing field
    final newValues = Map<String, Object?>.from(currentValues);
    newValues.remove(fieldName);

    final newFieldTypes = Map<String, Type>.from(currentFieldTypes);
    newFieldTypes.remove(fieldName);

    final newErrors = Map<String, String>.from(currentErrors);
    newErrors.remove(fieldName);

    // Validate remaining fields to update form validity
    final validatedErrors = stateCalculation.validateFields(
      values: newValues,
      validators: fieldRegistry.validators,
      context: context,
    );

    final newIsValid = stateCalculation.computeOverallValidity(
      values: newValues,
      validators: fieldRegistry.validators,
      touchedFields: fieldRegistry.touchedFields,
      context: context,
    );

    return FieldLifecycleResult(
      newValues: newValues,
      newFieldTypes: newFieldTypes,
      newErrors: validatedErrors,
      newIsValid: newIsValid,
    );
  }

  @override
  FieldLifecycleResult removeFields({
    required List<String> fieldNames,
    required Map<String, Object?> currentValues,
    required Map<String, Type> currentFieldTypes,
    required Map<String, String> currentErrors,
    required BuildContext context,
  }) {
    // Check if all fields exist
    for (final fieldName in fieldNames) {
      if (!fieldRegistry.fieldExists(fieldName)) {
        throw FormFieldError.fieldNotFound(
          fieldName: fieldName,
          availableFields: fieldRegistry.fieldNames,
          fieldTypes: fieldRegistry.fieldTypes,
          currentValues: currentValues,
        );
      }
    }

    // Remove all fields from field service
    for (final fieldName in fieldNames) {
      fieldRegistry.removeField(fieldName);
    }

    // Update form state by removing fields
    final newValues = Map<String, Object?>.from(currentValues);
    final newFieldTypes = Map<String, Type>.from(currentFieldTypes);
    final newErrors = Map<String, String>.from(currentErrors);

    for (final fieldName in fieldNames) {
      newValues.remove(fieldName);
      newFieldTypes.remove(fieldName);
      newErrors.remove(fieldName);
    }

    // Validate remaining fields to update form validity
    final validatedErrors = stateCalculation.validateFields(
      values: newValues,
      validators: fieldRegistry.validators,
      context: context,
    );

    final newIsValid = stateCalculation.computeOverallValidity(
      values: newValues,
      validators: fieldRegistry.validators,
      touchedFields: fieldRegistry.touchedFields,
      context: context,
    );

    return FieldLifecycleResult(
      newValues: newValues,
      newFieldTypes: newFieldTypes,
      newErrors: validatedErrors,
      newIsValid: newIsValid,
    );
  }
}
