/// Service responsible for managing touched field state.
///
/// This service encapsulates all logic related to tracking which fields
/// the user has interacted with, providing a clean interface for
/// touch state management operations.
abstract class FieldTracking {
  /// Get the touched fields map
  Map<String, bool> get touchedFields;

  /// Check if a field is touched
  bool isFieldTouched(String fieldName);

  /// Mark a field as touched
  void markFieldAsTouched(String fieldName);

  /// Mark multiple fields as touched
  void markFieldsAsTouched(List<String> fieldNames);

  /// Mark all fields as touched
  void markAllFieldsAsTouched();

  /// Get all touched field names
  List<String> getTouchedFieldNames();

  /// Get all untouched field names
  List<String> getUntouchedFieldNames();

  /// Reset a specific field to untouched state
  void resetFieldTouched(String fieldName);

  /// Reset all fields to untouched state
  void resetTouchedFields();

  /// Reset specific fields to untouched state
  void resetFieldsTouched(List<String> fieldNames);

  /// Check if any fields have been touched
  bool hasAnyTouchedFields();

  /// Check if all fields have been touched
  bool areAllFieldsTouched();

  /// Get the count of touched fields
  int getTouchedFieldsCount();

  /// Get the count of untouched fields
  int getUntouchedFieldsCount();

  /// Initialize touched state for a new field
  void initializeFieldTouchedState(String fieldName);

  /// Remove touched state for a field (when field is removed from form)
  void removeFieldTouchedState(String fieldName);
}

/// Default implementation of FieldTracking
class DefaultFieldTracking implements FieldTracking {
  final Map<String, bool> _touchedFields = {};

  DefaultFieldTracking({List<String> fieldNames = const []}) {
    // Initialize all provided fields as untouched
    for (final fieldName in fieldNames) {
      _touchedFields[fieldName] = false;
    }
  }

  @override
  Map<String, bool> get touchedFields => Map.unmodifiable(_touchedFields);

  @override
  bool isFieldTouched(String fieldName) {
    return _touchedFields[fieldName] ?? false;
  }

  @override
  void markFieldAsTouched(String fieldName) {
    if (_touchedFields.containsKey(fieldName)) {
      _touchedFields[fieldName] = true;
    }
  }

  @override
  void markFieldsAsTouched(List<String> fieldNames) {
    for (final fieldName in fieldNames) {
      markFieldAsTouched(fieldName);
    }
  }

  @override
  void markAllFieldsAsTouched() {
    for (final fieldName in _touchedFields.keys) {
      _touchedFields[fieldName] = true;
    }
  }

  @override
  List<String> getTouchedFieldNames() {
    return _touchedFields.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  List<String> getUntouchedFieldNames() {
    return _touchedFields.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  void resetFieldTouched(String fieldName) {
    if (_touchedFields.containsKey(fieldName)) {
      _touchedFields[fieldName] = false;
    }
  }

  @override
  void resetTouchedFields() {
    for (final fieldName in _touchedFields.keys) {
      _touchedFields[fieldName] = false;
    }
  }

  @override
  void resetFieldsTouched(List<String> fieldNames) {
    for (final fieldName in fieldNames) {
      resetFieldTouched(fieldName);
    }
  }

  @override
  bool hasAnyTouchedFields() {
    return _touchedFields.values.any((touched) => touched);
  }

  @override
  bool areAllFieldsTouched() {
    return _touchedFields.isNotEmpty &&
        _touchedFields.values.every((touched) => touched);
  }

  @override
  int getTouchedFieldsCount() {
    return _touchedFields.values.where((touched) => touched).length;
  }

  @override
  int getUntouchedFieldsCount() {
    return _touchedFields.values.where((touched) => !touched).length;
  }

  @override
  void initializeFieldTouchedState(String fieldName) {
    _touchedFields[fieldName] = false;
  }

  @override
  void removeFieldTouchedState(String fieldName) {
    _touchedFields.remove(fieldName);
  }
}
