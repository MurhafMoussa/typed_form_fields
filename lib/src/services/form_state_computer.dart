import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/services/form_debounced_validation_service.dart';
import 'package:typed_form_fields/src/services/form_field_manager.dart';
import 'package:typed_form_fields/src/services/form_validation_service.dart';

/// Service responsible for computing form state changes
class FormStateComputer {
  final FormValidationService _validationService;
  final FormDebouncedValidationService _debouncedValidationService;

  FormStateComputer({
    FormValidationService? validationService,
    FormDebouncedValidationService? debouncedValidationService,
  })  : _validationService = validationService ?? FormValidationService(),
        _debouncedValidationService =
            debouncedValidationService ?? FormDebouncedValidationService();

  /// Get the validation service for direct access
  FormValidationService get validationService => _validationService;

  /// Get the debounced validation service for direct access
  FormDebouncedValidationService get debouncedValidationService =>
      _debouncedValidationService;

  /// Compute new state after field update with debouncing
  void computeFieldUpdateStateWithDebounce({
    required String fieldName,
    required Object? value,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required FormFieldManager fieldManager,
    required BuildContext context,
    required void Function(TypedFormState) onStateComputed,
  }) {
    // Update values immediately
    final newValues = Map<String, Object?>.from(currentValues)
      ..[fieldName] = value;

    // Handle different validation strategies
    switch (validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        // No validation on field change
        onStateComputed(
          TypedFormState(
            values: newValues,
            errors: currentErrors,
            isValid: false, // Will be computed on submit
            validationStrategy: validationStrategy,
            fieldTypes: fieldManager.getFieldTypes(),
          ),
        );
        break;

      case ValidationStrategy.allFieldsRealTime:
        // Debounced validation for all fields
        _debouncedValidationService.validateAllFieldsWithDebounce(
          values: newValues,
          validators: fieldManager.validators,
          context: context,
          onValidationComplete: (errors) {
            final overallValid = _validationService.computeOverallValidity(
              values: newValues,
              validators: fieldManager.validators,
              touchedFields: fieldManager.touchedFields,
              context: context,
            );
            onStateComputed(
              TypedFormState(
                values: newValues,
                errors: errors,
                isValid: overallValid,
                validationStrategy: validationStrategy,
                fieldTypes: fieldManager.getFieldTypes(),
              ),
            );
          },
        );
        break;

      case ValidationStrategy.realTimeOnly:
        // Debounced validation for current field only
        _debouncedValidationService.validateFieldWithDebounce(
          fieldName: fieldName,
          value: value,
          validators: fieldManager.validators,
          context: context,
          onValidationComplete: (error, errors) {
            final newErrors = Map<String, String>.from(currentErrors);
            if (error != null) {
              newErrors[fieldName] = error;
            } else {
              newErrors.remove(fieldName);
            }

            final overallValid = _validationService.computeOverallValidity(
              values: newValues,
              validators: fieldManager.validators,
              touchedFields: fieldManager.touchedFields,
              context: context,
            );

            onStateComputed(
              TypedFormState(
                values: newValues,
                errors: newErrors,
                isValid: overallValid,
                validationStrategy: validationStrategy,
                fieldTypes: fieldManager.getFieldTypes(),
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
            fieldTypes: fieldManager.getFieldTypes(),
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
    required FormFieldManager fieldManager,
    required BuildContext context,
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
          _validationService.validateFields(
            values: newValues,
            validators: fieldManager.validators,
            context: context,
          ),
        );
        break;
      case ValidationStrategy.realTimeOnly:
        // Validate only the field being edited
        final validator = fieldManager.validators[fieldName];
        if (validator != null) {
          final error = _validationService.validateField(
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
        : _validationService.computeOverallValidity(
            values: newValues,
            validators: fieldManager.validators,
            touchedFields: fieldManager.touchedFields,
            context: context,
          );

    return TypedFormState(
      values: newValues,
      errors: newErrors,
      isValid: overallValid,
      validationStrategy: validationStrategy,
      fieldTypes: fieldManager.getFieldTypes(),
    );
  }

  /// Compute new state after multiple field updates
  TypedFormState computeFieldsUpdateState({
    required Map<String, Object?> fieldValues,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required FormFieldManager fieldManager,
    required BuildContext context,
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
          _validationService.validateFields(
            values: newValues,
            validators: fieldManager.validators,
            context: context,
          ),
        );
        break;
      case ValidationStrategy.realTimeOnly:
        // Validate only edited fields
        for (final fieldName in fieldValues.keys) {
          final validator = fieldManager.validators[fieldName];
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
      isValid: _validationService.computeOverallValidity(
        values: newValues,
        validators: fieldManager.validators,
        touchedFields: fieldManager.touchedFields,
        context: context,
      ),
      validationStrategy: validationStrategy,
      fieldTypes: fieldManager.getFieldTypes(),
    );
  }

  /// Compute new state after error updates
  TypedFormState computeErrorUpdateState({
    required Map<String, String> newErrors,
    required Map<String, Object?> currentValues,
    required ValidationStrategy validationStrategy,
    required FormFieldManager fieldManager,
    required BuildContext context,
  }) {
    return TypedFormState(
      values: currentValues,
      errors: newErrors,
      isValid: _validationService.computeOverallValidityWithErrors(
        values: currentValues,
        errors: newErrors,
        touchedFields: fieldManager.touchedFields,
        validators: fieldManager.validators,
        context: context,
      ),
      validationStrategy: validationStrategy,
      fieldTypes: fieldManager.getFieldTypes(),
    );
  }

  /// Compute new state after validation type change
  TypedFormState computeValidationStrategyChangeState({
    required ValidationStrategy newValidationStrategy,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required FormFieldManager fieldManager,
    required BuildContext context,
  }) {
    return TypedFormState(
      values: currentValues,
      errors: currentErrors,
      isValid: _validationService.computeOverallValidity(
        values: currentValues,
        validators: fieldManager.validators,
        touchedFields: fieldManager.touchedFields,
        context: context,
      ),
      validationStrategy: newValidationStrategy,
      fieldTypes: fieldManager.getFieldTypes(),
    );
  }
}
