import 'package:flutter/foundation.dart';

/// Custom error class for form field errors with helpful suggestions and debug information.
/// 
/// This error provides detailed information to help developers understand and fix
/// form-related issues quickly, especially useful for junior developers.
class FormFieldError extends Error {
  /// The name of the field that caused the error
  final String fieldName;
  
  /// A clear description of what went wrong
  final String message;
  
  /// A helpful suggestion on how to fix the issue
  final String suggestion;
  
  /// Additional debug information (only included in debug mode)
  final String? debugInfo;

  FormFieldError({
    required this.fieldName,
    required this.message,
    required this.suggestion,
    this.debugInfo,
  });

  /// Creates a FormFieldError for when a field doesn't exist
  factory FormFieldError.fieldNotFound({
    required String fieldName,
    required List<String> availableFields,
    required Map<String, Type> fieldTypes,
    required Map<String, Object?> currentValues,
  }) {
    final suggestion = availableFields.isEmpty
        ? 'Add the field to your CoreFormCubit constructor first.'
        : 'Available fields: ${availableFields.join(', ')}. Check the field name spelling.';
    
    String? debugInfo;
    if (kDebugMode) {
      debugInfo = 'Available fields: $availableFields\n'
          'Field types: $fieldTypes\n'
          'Current values: $currentValues';
    }

    return FormFieldError(
      fieldName: fieldName,
      message: 'Field "$fieldName" does not exist in the form.',
      suggestion: suggestion,
      debugInfo: debugInfo,
    );
  }

  /// Creates a FormFieldError for type mismatches
  factory FormFieldError.typeMismatch({
    required String fieldName,
    required Type expectedType,
    required Type actualType,
    required String operation,
  }) {
    final suggestion = operation == 'getValue'
        ? 'Use getValue<$expectedType>(\'$fieldName\') instead of getValue<$actualType>(\'$fieldName\').'
        : 'Use FieldWrapper<$expectedType> or updateField<$expectedType>() instead of <$actualType>.';

    String? debugInfo;
    if (kDebugMode) {
      debugInfo = 'Expected type: $expectedType\n'
          'Actual type: $actualType\n'
          'Operation: $operation\n'
          'Field: $fieldName';
    }

    return FormFieldError(
      fieldName: fieldName,
      message: 'Type mismatch for field "$fieldName": expected $expectedType but got $actualType.',
      suggestion: suggestion,
      debugInfo: debugInfo,
    );
  }

  /// Creates a FormFieldError for when trying to add a field that already exists
  factory FormFieldError.fieldAlreadyExists({
    required String fieldName,
  }) {
    return FormFieldError(
      fieldName: fieldName,
      message: 'Field "$fieldName" already exists in the form.',
      suggestion: 'Use updateFieldValidators() to modify existing field validators, or removeField() first.',
    );
  }

  /// Creates a FormFieldError for performance warnings
  factory FormFieldError.performanceWarning({
    required String fieldName,
    required String issue,
    required String recommendation,
  }) {
    return FormFieldError(
      fieldName: fieldName,
      message: 'Performance Warning: $issue',
      suggestion: recommendation,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('FormFieldError in field "$fieldName":');
    buffer.writeln('  $message');
    buffer.writeln('  Suggestion: $suggestion');
    
    if (debugInfo != null && kDebugMode) {
      buffer.writeln('  Debug Info: $debugInfo');
    }
    
    return buffer.toString();
  }
}
