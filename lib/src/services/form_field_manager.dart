import 'package:typed_form_fields/src/models/models.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

/// Service responsible for managing form fields and their operations
class FormFieldManager {
  late final List<TypedFormField> _fields;
  late final Map<String, Validator> _validators;
  late final Map<String, bool> _touchedFields;

  FormFieldManager({List<TypedFormField> fields = const []}) {
    _validators = {};
    _touchedFields = {};
    _fields = fields;

    // Initialize validators and mark fields as untouched
    for (final field in fields) {
      _validators[field.name] = field.createValidator();
      _touchedFields[field.name] = false;
    }
  }

  /// Get the list of fields
  List<TypedFormField> get fields => _fields;

  /// Get the validators map
  Map<String, Validator> get validators => _validators;

  /// Get the touched fields map
  Map<String, bool> get touchedFields => _touchedFields;

  /// Check if a field exists
  bool fieldExists(String fieldName) {
    return _validators.containsKey(fieldName);
  }

  /// Get the expected type for a field
  Type? getFieldType(String fieldName) {
    final field = _fields.firstWhere(
      (field) => field.name == fieldName,
      orElse: () => throw ArgumentError('Field "$fieldName" does not exist'),
    );
    return field.valueType;
  }

  /// Mark a field as touched
  void markFieldAsTouched(String fieldName) {
    if (_touchedFields.containsKey(fieldName)) {
      _touchedFields[fieldName] = true;
    }
  }

  /// Mark multiple fields as touched
  void markFieldsAsTouched(List<String> fieldNames) {
    for (final fieldName in fieldNames) {
      markFieldAsTouched(fieldName);
    }
  }

  /// Mark all fields as touched
  void markAllFieldsAsTouched() {
    for (final field in _touchedFields.keys) {
      _touchedFields[field] = true;
    }
  }

  /// Reset all fields to untouched
  void resetTouchedFields() {
    for (final field in _touchedFields.keys) {
      _touchedFields[field] = false;
    }
  }

  /// Update field validators
  void updateFieldValidators<T>({
    required String name,
    required List<Validator<T>> validators,
  }) {
    final fieldIndex = _fields.indexWhere((field) => field.name == name);

    if (fieldIndex == -1) {
      throw ArgumentError('Field "$name" does not exist in the form');
    }

    // Update the stored field definition using copyWith
    final oldField = _fields[fieldIndex];
    final newField = (oldField as TypedFormField<T>).copyWith(
      validators: validators,
    );
    _fields[fieldIndex] = newField;

    // Re-create the composite validator and update the internal map
    _validators[name] = newField.createValidator();
  }

  /// Get initial values for all fields
  Map<String, Object?> getInitialValues() {
    final values = <String, Object?>{};
    for (final field in _fields) {
      values[field.name] = field.initialValue;
    }
    return values;
  }

  /// Get field types map
  Map<String, Type> getFieldTypes() {
    final fieldTypes = <String, Type>{};
    for (final field in _fields) {
      fieldTypes[field.name] = field.valueType;
    }
    return fieldTypes;
  }
}
