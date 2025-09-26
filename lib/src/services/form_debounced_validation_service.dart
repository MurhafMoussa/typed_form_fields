import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/src/services/form_validation_service.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

/// Service responsible for debounced form validation
class FormDebouncedValidationService {
  final FormValidationService _validationService;
  final Map<String, Timer> _debounceTimers = {};
  final Duration _debounceDelay;

  FormDebouncedValidationService({
    FormValidationService? validationService,
    Duration debounceDelay = const Duration(milliseconds: 300),
  })  : _validationService = validationService ?? FormValidationService(),
        _debounceDelay = debounceDelay;

  /// Validates a field with debouncing
  ///
  /// This method will cancel any pending validation for the field and
  /// schedule a new validation after the debounce delay.
  void validateFieldWithDebounce({
    required String fieldName,
    required Object? value,
    required Map<String, Validator> validators,
    required BuildContext context,
    required void Function(String?, Map<String, String>) onValidationComplete,
  }) {
    // Cancel previous timer for this field
    _debounceTimers[fieldName]?.cancel();

    // Set new timer
    _debounceTimers[fieldName] = Timer(_debounceDelay, () {
      _performValidation(
        fieldName: fieldName,
        value: value,
        validators: validators,
        context: context,
        onValidationComplete: onValidationComplete,
      );
    });
  }

  /// Validates a field immediately (no debouncing)
  ///
  /// This is useful for blur events, form submission, etc.
  void validateFieldImmediately({
    required String fieldName,
    required Object? value,
    required Map<String, Validator> validators,
    required BuildContext context,
    required void Function(String?, Map<String, String>) onValidationComplete,
  }) {
    // Cancel any pending debounced validation
    _debounceTimers[fieldName]?.cancel();

    _performValidation(
      fieldName: fieldName,
      value: value,
      validators: validators,
      context: context,
      onValidationComplete: onValidationComplete,
    );
  }

  /// Validates all fields with debouncing
  void validateAllFieldsWithDebounce({
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
    required void Function(Map<String, String>) onValidationComplete,
  }) {
    // Cancel all pending timers
    _cancelAllTimers();

    // Set new timer for all fields validation
    _debounceTimers['_all_fields'] = Timer(_debounceDelay, () {
      final errors = _validationService.validateFields(
        values: values,
        validators: validators,
        context: context,
      );
      onValidationComplete(errors);
    });
  }

  /// Validates all fields immediately
  void validateAllFieldsImmediately({
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
    required void Function(Map<String, String>) onValidationComplete,
  }) {
    // Cancel all pending timers
    _cancelAllTimers();

    final errors = _validationService.validateFields(
      values: values,
      validators: validators,
      context: context,
    );
    onValidationComplete(errors);
  }

  /// Performs the actual validation
  void _performValidation({
    required String fieldName,
    required Object? value,
    required Map<String, Validator> validators,
    required BuildContext context,
    required void Function(String?, Map<String, String>) onValidationComplete,
  }) {
    final validator = validators[fieldName];
    if (validator == null) {
      onValidationComplete(null, {});
      return;
    }

    final error = _validationService.validateField(
      validator: validator,
      value: value,
      context: context,
    );

    onValidationComplete(error, {fieldName: error ?? ''});
  }

  /// Cancels all pending validation timers
  void _cancelAllTimers() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  /// Cancels validation for a specific field
  void cancelFieldValidation(String fieldName) {
    _debounceTimers[fieldName]?.cancel();
    _debounceTimers.remove(fieldName);
  }

  /// Disposes of all resources
  void dispose() {
    _cancelAllTimers();
  }

  /// Gets the validation service for direct access
  FormValidationService get validationService => _validationService;
}
