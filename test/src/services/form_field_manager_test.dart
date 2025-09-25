import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/models/typed_form_field.dart';
import 'package:typed_form_fields/src/services/form_field_manager.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('FormFieldManager', () {
    late FormFieldManager fieldManager;
    late List<TypedFormField> testFields;

    setUp(() {
      testFields = [
        TypedFormField<String>(
          name: 'email',
          validators: [MockValidator<String>()],
          initialValue: 'initial@example.com',
        ),
        TypedFormField<int>(
          name: 'age',
          validators: [MockValidator<int>()],
          initialValue: 25,
        ),
        const TypedFormField<String>(name: 'name', validators: []),
      ];
      fieldManager = FormFieldManager(fields: testFields);
    });

    group('constructor', () {
      test('should initialize with provided fields', () {
        expect(fieldManager.fields, testFields);
        expect(fieldManager.validators.length, 3);
        expect(fieldManager.touchedFields.length, 3);
        expect(fieldManager.touchedFields['email'], isFalse);
        expect(fieldManager.touchedFields['age'], isFalse);
        expect(fieldManager.touchedFields['name'], isFalse);
      });

      test('should initialize with empty fields list', () {
        final emptyManager = FormFieldManager();
        expect(emptyManager.fields, isEmpty);
        expect(emptyManager.validators, isEmpty);
        expect(emptyManager.touchedFields, isEmpty);
      });
    });

    group('fieldExists', () {
      test('should return true for existing field', () {
        expect(fieldManager.fieldExists('email'), isTrue);
        expect(fieldManager.fieldExists('age'), isTrue);
        expect(fieldManager.fieldExists('name'), isTrue);
      });

      test('should return false for non-existing field', () {
        expect(fieldManager.fieldExists('nonExistent'), isFalse);
        expect(fieldManager.fieldExists(''), isFalse);
      });
    });

    group('getFieldType', () {
      test('should return correct type for existing field', () {
        expect(fieldManager.getFieldType('email'), String);
        expect(fieldManager.getFieldType('age'), int);
        expect(fieldManager.getFieldType('name'), String);
      });

      test('should throw ArgumentError for non-existing field', () {
        expect(
          () => fieldManager.getFieldType('nonExistent'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('markFieldAsTouched', () {
      test('should mark existing field as touched', () {
        fieldManager.markFieldAsTouched('email');
        expect(fieldManager.touchedFields['email'], isTrue);
        expect(fieldManager.touchedFields['age'], isFalse);
      });

      test('should not throw error for non-existing field', () {
        expect(
          () => fieldManager.markFieldAsTouched('nonExistent'),
          returnsNormally,
        );
      });
    });

    group('markFieldsAsTouched', () {
      test('should mark multiple fields as touched', () {
        fieldManager.markFieldsAsTouched(['email', 'age']);
        expect(fieldManager.touchedFields['email'], isTrue);
        expect(fieldManager.touchedFields['age'], isTrue);
        expect(fieldManager.touchedFields['name'], isFalse);
      });

      test('should handle empty list', () {
        fieldManager.markFieldsAsTouched([]);
        expect(fieldManager.touchedFields['email'], isFalse);
        expect(fieldManager.touchedFields['age'], isFalse);
      });

      test('should handle non-existing fields gracefully', () {
        fieldManager.markFieldsAsTouched(['email', 'nonExistent', 'age']);
        expect(fieldManager.touchedFields['email'], isTrue);
        expect(fieldManager.touchedFields['age'], isTrue);
        expect(fieldManager.touchedFields['name'], isFalse);
      });
    });

    group('markAllFieldsAsTouched', () {
      test('should mark all fields as touched', () {
        fieldManager.markAllFieldsAsTouched();
        expect(fieldManager.touchedFields['email'], isTrue);
        expect(fieldManager.touchedFields['age'], isTrue);
        expect(fieldManager.touchedFields['name'], isTrue);
      });
    });

    group('resetTouchedFields', () {
      test('should reset all fields to untouched', () {
        // First mark all as touched
        fieldManager.markAllFieldsAsTouched();
        expect(fieldManager.touchedFields['email'], isTrue);

        // Then reset
        fieldManager.resetTouchedFields();
        expect(fieldManager.touchedFields['email'], isFalse);
        expect(fieldManager.touchedFields['age'], isFalse);
        expect(fieldManager.touchedFields['name'], isFalse);
      });
    });

    group('updateFieldValidators', () {
      test('should update validators for existing field', () {
        final newValidators = [
          MockValidator<String>(),
          MockValidator<String>(),
        ];

        fieldManager.updateFieldValidators<String>(
          name: 'email',
          validators: newValidators,
        );

        // Check that the field was updated
        final updatedField = fieldManager.fields.firstWhere(
          (field) => field.name == 'email',
        );
        expect(updatedField.validators, newValidators);
      });

      test('should throw ArgumentError for non-existing field', () {
        expect(
          () => fieldManager.updateFieldValidators<String>(
            name: 'nonExistent',
            validators: [MockValidator<String>()],
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should update validators map', () {
        final newValidators = [MockValidator<String>()];

        fieldManager.updateFieldValidators<String>(
          name: 'email',
          validators: newValidators,
        );

        // The validators map should be updated
        expect(fieldManager.validators['email'], isNotNull);
      });
    });

    group('getInitialValues', () {
      test('should return initial values for all fields', () {
        final initialValues = fieldManager.getInitialValues();

        expect(initialValues['email'], 'initial@example.com');
        expect(initialValues['age'], 25);
        expect(initialValues['name'], isNull);
      });

      test('should return empty map for empty field manager', () {
        final emptyManager = FormFieldManager();
        final initialValues = emptyManager.getInitialValues();

        expect(initialValues, isEmpty);
      });
    });

    group('getFieldTypes', () {
      test('should return field types for all fields', () {
        final fieldTypes = fieldManager.getFieldTypes();

        expect(fieldTypes['email'], String);
        expect(fieldTypes['age'], int);
        expect(fieldTypes['name'], String);
      });

      test('should return empty map for empty field manager', () {
        final emptyManager = FormFieldManager();
        final fieldTypes = emptyManager.getFieldTypes();

        expect(fieldTypes, isEmpty);
      });
    });

    group('getters', () {
      test('should provide access to fields', () {
        expect(fieldManager.fields, testFields);
      });

      test('should provide access to validators', () {
        expect(fieldManager.validators.length, 3);
        expect(fieldManager.validators['email'], isNotNull);
        expect(fieldManager.validators['age'], isNotNull);
        expect(fieldManager.validators['name'], isNotNull);
      });

      test('should provide access to touched fields', () {
        expect(fieldManager.touchedFields.length, 3);
        expect(fieldManager.touchedFields['email'], isFalse);
        expect(fieldManager.touchedFields['age'], isFalse);
        expect(fieldManager.touchedFields['name'], isFalse);
      });
    });
  });

  group('Dynamic Field Management', () {
    late FormFieldManager fieldManager;

    setUp(() {
      fieldManager = FormFieldManager(fields: [
        const TypedFormField<String>(name: 'email', validators: []),
      ]);
    });

    group('addField', () {
      test('should add a new field successfully', () {
        // Arrange
        const newField = TypedFormField<String>(name: 'phone', validators: []);

        // Act
        fieldManager.addField(newField);

        // Assert
        expect(fieldManager.fieldExists('phone'), isTrue);
        expect(fieldManager.fields.length, 2);
      });

      test('should throw ArgumentError when adding existing field', () {
        // Arrange - This test covers line 124
        const existingField =
            TypedFormField<String>(name: 'email', validators: []);

        // Act & Assert
        expect(
          () => fieldManager.addField(existingField),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('removeField', () {
      test('should remove an existing field successfully', () {
        // Act
        fieldManager.removeField('email');

        // Assert
        expect(fieldManager.fieldExists('email'), isFalse);
        expect(fieldManager.fields.length, 0);
      });

      test('should throw ArgumentError when removing non-existent field', () {
        // Act & Assert - This test covers line 135
        expect(
          () => fieldManager.removeField('nonexistent'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}

class MockValidator<T> implements Validator<T> {
  @override
  String? validate(T? value, BuildContext context) {
    return 'Mock error';
  }
}
