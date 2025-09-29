import 'package:typed_form_fields/src/models/models.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

/// Service responsible for managing form fields and their operations
class FormFieldManager {
  late final List<FormFieldDefinition> _fields;
  late final Map<String, Validator> _validators;
  late final Map<String, bool> _touchedFields;

  FormFieldManager({List<FormFieldDefinition> fields = const []}) {
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
  List<FormFieldDefinition> get fields => _fields;

  /// Get the validators map
  Map<String, Validator> get validators => _validators;

  /// Get the touched fields map
  Map<String, bool> get touchedFields => _touchedFields;

  /// Get the list of field names
  List<String> get fieldNames => _fields.map((field) => field.name).toList();

  /// Get the map of field types
  Map<String, Type> get fieldTypes => {
        for (final field in _fields) field.name: field.valueType,
      };

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
    final newField = (oldField as FormFieldDefinition<T>).copyWith(
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

  /// Add a field dynamically
  void addField(FormFieldDefinition field) {
    if (fieldExists(field.name)) {
      throw ArgumentError('Field "${field.name}" already exists');
    }

    _fields.add(field);
    _validators[field.name] = field.createValidator();
    _touchedFields[field.name] = false;
  }

  /// Remove a field dynamically
  void removeField(String fieldName) {
    if (!fieldExists(fieldName)) {
      throw ArgumentError('Field "$fieldName" does not exist');
    }

    _fields.removeWhere((field) => field.name == fieldName);
    _validators.remove(fieldName);
    _touchedFields.remove(fieldName);
  }
}
