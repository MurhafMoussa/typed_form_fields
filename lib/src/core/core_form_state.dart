part of 'core_form_cubit.dart';

@freezed
abstract class CoreFormState with _$CoreFormState {
  const factory CoreFormState({
    required Map<String, Object?> values,
    required Map<String, String> errors,
    required bool isValid,
    @Default(ValidationType.fieldsBeingEdited) ValidationType validationType,
    required Map<String, Type> fieldTypes,
  }) = _CoreFormState;
  const CoreFormState._();
  factory CoreFormState.initial() => const CoreFormState(
        values: {},
        errors: {},
        isValid: false,
        fieldTypes: {},
      );

  /// Type-safe getter for field values
  @useResult
  T? getValue<T>(String fieldName) {
    // Check if field exists
    if (!values.containsKey(fieldName)) {
      throw ArgumentError('Field "$fieldName" does not exist in the form');
    }

    // Check type compatibility
    final expectedType = fieldTypes[fieldName];
    if (expectedType != null && expectedType != T) {
      throw TypeError();
    }

    // Return value with proper type
    final value = values[fieldName];
    if (value == null) return null;
    if (value is T) return value as T;

    // Fallback for type mismatch
    return null;
  }

  /// Get error for a specific field
  @useResult
  String? getError(String fieldName) => errors[fieldName];

  /// Check if a field has an error
  @useResult
  bool hasError(String fieldName) => errors.containsKey(fieldName);
}

/// Enum representing the available form validation strategies
enum ValidationType {
  /// Validation occurs only upon form submission
  onSubmit,

  /// All fields are validated whenever any field is updated
  allFields,

  /// Only the field currently being edited is validated
  fieldsBeingEdited,

  /// Validation is disabled
  disabled,
}
