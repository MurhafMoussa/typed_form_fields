import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/services/field_tracking.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

// Mock validator for testing
class MockValidator<T> implements Validator<T> {
  final String? errorMessage;

  MockValidator({this.errorMessage});

  @override
  String? validate(T? value, context) => errorMessage;
}

void main() {
  group('FieldRegistry', () {
    late DefaultFieldRegistry fieldRegistry;
    late List<FormFieldDefinition> testFields;

    setUp(() {
      testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [MockValidator<String>(errorMessage: 'Invalid email')],
          initialValue: 'test@example.com',
        ),
        FormFieldDefinition<int>(
          name: 'age',
          validators: [MockValidator<int>(errorMessage: 'Invalid age')],
          initialValue: 25,
        ),
        FormFieldDefinition<bool>(
          name: 'termsAccepted',
          validators: [MockValidator<bool>(errorMessage: 'Must accept terms')],
          initialValue: false,
        ),
      ];

      fieldRegistry = DefaultFieldRegistry(fields: testFields);
    });

    group('Initialization', () {
      test('should initialize with provided fields', () {
        expect(fieldRegistry.fields, testFields);
        expect(fieldRegistry.fieldNames,
            containsAll(['email', 'age', 'termsAccepted']));
      });

      test('should create validators for all fields', () {
        final validators = fieldRegistry.validators;
        expect(validators.keys, containsAll(['email', 'age', 'termsAccepted']));
        expect(validators['email'], isA<Validator>());
        expect(validators['age'], isA<Validator>());
        expect(validators['termsAccepted'], isA<Validator>());
      });

      test('should initialize touched fields service', () {
        expect(fieldRegistry.touchedFieldsService, isA<FieldTracking>());
        expect(fieldRegistry.touchedFields.keys,
            containsAll(['email', 'age', 'termsAccepted']));
      });

      test('should get correct field types', () {
        final fieldTypes = fieldRegistry.fieldTypes;
        expect(fieldTypes['email'], String);
        expect(fieldTypes['age'], int);
        expect(fieldTypes['termsAccepted'], bool);
      });
    });

    group('Field Existence and Type Operations', () {
      test('should check if field exists', () {
        expect(fieldRegistry.fieldExists('email'), true);
        expect(fieldRegistry.fieldExists('age'), true);
        expect(fieldRegistry.fieldExists('nonExistent'), false);
      });

      test('should get field type for existing field', () {
        expect(fieldRegistry.getFieldType('email'), String);
        expect(fieldRegistry.getFieldType('age'), int);
        expect(fieldRegistry.getFieldType('termsAccepted'), bool);
      });

      test('should throw error when getting type for non-existent field', () {
        expect(
          () => fieldRegistry.getFieldType('nonExistent'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Initial Values Operations', () {
      test('should get initial values for all fields', () {
        final initialValues = fieldRegistry.getInitialValues();

        expect(initialValues['email'], 'test@example.com');
        expect(initialValues['age'], 25);
        expect(initialValues['termsAccepted'], false);
      });

      test('should handle null initial values', () {
        final fieldWithNullValue = FormFieldDefinition<String>(
          name: 'nullableField',
          validators: [MockValidator<String>()],
          initialValue: null,
        );

        final serviceWithNull =
            DefaultFieldRegistry(fields: [fieldWithNullValue]);
        final initialValues = serviceWithNull.getInitialValues();

        expect(initialValues['nullableField'], null);
      });
    });

    group('Field Addition Operations', () {
      test('should add new field to service', () {
        final newField = FormFieldDefinition<String>(
          name: 'newField',
          validators: [MockValidator<String>()],
          initialValue: 'newValue',
        );

        fieldRegistry.addField(newField);

        expect(fieldRegistry.fieldExists('newField'), true);
        expect(fieldRegistry.getFieldType('newField'), String);
        expect(fieldRegistry.getInitialValues()['newField'], 'newValue');
        expect(fieldRegistry.validators['newField'], isA<Validator>());
        expect(fieldRegistry.touchedFieldsService.isFieldTouched('newField'),
            false);
      });

      test('should add field with validators', () {
        final fieldWithValidators = FormFieldDefinition<String>(
          name: 'validatedField',
          validators: [
            MockValidator<String>(errorMessage: 'Error 1'),
            MockValidator<String>(errorMessage: 'Error 2'),
          ],
          initialValue: 'value',
        );

        fieldRegistry.addField(fieldWithValidators);

        expect(fieldRegistry.validators['validatedField'], isA<Validator>());
      });
    });

    group('Field Removal Operations', () {
      test('should remove field from service', () {
        fieldRegistry.removeField('age');

        expect(fieldRegistry.fieldExists('age'), false);
        expect(fieldRegistry.validators.keys, isNot(contains('age')));
        expect(fieldRegistry.touchedFields.keys, isNot(contains('age')));
        expect(fieldRegistry.fieldNames, isNot(contains('age')));
      });

      test('should remove field from touched fields service', () {
        // Mark field as touched first
        fieldRegistry.touchedFieldsService.markFieldAsTouched('age');
        expect(fieldRegistry.touchedFieldsService.isFieldTouched('age'), true);

        // Remove field
        fieldRegistry.removeField('age');

        // Should be removed from touched fields service
        expect(fieldRegistry.touchedFieldsService.isFieldTouched('age'), false);
      });

      test('should handle removing non-existent field gracefully', () {
        expect(() => fieldRegistry.removeField('nonExistent'), returnsNormally);
      });
    });

    group('Field Validator Updates', () {
      test('should update field validators', () {
        final newValidators = [
          MockValidator<String>(errorMessage: 'New error 1'),
          MockValidator<String>(errorMessage: 'New error 2'),
        ];

        fieldRegistry.updateFieldValidators<String>('email', newValidators);

        expect(fieldRegistry.validators['email'], isA<Validator>());
      });

      test('should throw error when updating validators for non-existent field',
          () {
        final newValidators = [MockValidator<String>()];

        expect(
          () => fieldRegistry.updateFieldValidators<String>(
              'nonExistent', newValidators),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should update field definition when updating validators', () {
        final originalField =
            fieldRegistry.fields.firstWhere((f) => f.name == 'email');
        final newValidators = [
          MockValidator<String>(errorMessage: 'Updated error')
        ];

        fieldRegistry.updateFieldValidators<String>('email', newValidators);

        final updatedField =
            fieldRegistry.fields.firstWhere((f) => f.name == 'email');
        expect(updatedField.validators, newValidators);
        expect(updatedField.initialValue, originalField.initialValue);
      });
    });

    group('Touched Fields Integration', () {
      test('should delegate touched fields operations to service', () {
        fieldRegistry.touchedFieldsService.markFieldAsTouched('email');

        expect(fieldRegistry.touchedFields['email'], true);
        expect(
            fieldRegistry.touchedFieldsService.isFieldTouched('email'), true);
      });

      test('should maintain consistency between touched fields and service',
          () {
        fieldRegistry.touchedFieldsService.markAllFieldsAsTouched();

        final touchedFields = fieldRegistry.touchedFields;
        final serviceTouchedFields =
            fieldRegistry.touchedFieldsService.touchedFields;

        expect(touchedFields, serviceTouchedFields);
      });
    });

    group('Custom FieldTracking Integration', () {
      test('should use custom touched fields service when provided', () {
        final customTouchedService =
            DefaultFieldTracking(fieldNames: ['custom']);
        final serviceWithCustom = DefaultFieldRegistry(
          fields: testFields,
          touchedFieldsService: customTouchedService,
        );

        expect(serviceWithCustom.touchedFieldsService, customTouchedService);
      });

      test('should initialize custom touched fields service with field names',
          () {
        final customTouchedService = DefaultFieldTracking();
        final serviceWithCustom = DefaultFieldRegistry(
          fields: testFields,
          touchedFieldsService: customTouchedService,
        );

        // The custom service should be used as-is, not reinitialized
        expect(serviceWithCustom.touchedFieldsService, customTouchedService);
      });
    });

    group('Edge Cases', () {
      test('should handle empty fields list', () {
        final emptyService = DefaultFieldRegistry();

        expect(emptyService.fields, isEmpty);
        expect(emptyService.fieldNames, isEmpty);
        expect(emptyService.validators, isEmpty);
        expect(emptyService.touchedFields, isEmpty);
      });

      test('should handle fields with no validators', () {
        final fieldWithoutValidators = FormFieldDefinition<String>(
          name: 'noValidators',
          validators: [],
          initialValue: 'value',
        );

        final serviceWithoutValidators =
            DefaultFieldRegistry(fields: [fieldWithoutValidators]);

        expect(serviceWithoutValidators.validators['noValidators'],
            isA<Validator>());
      });

      test('should handle duplicate field names gracefully', () {
        final duplicateFields = [
          FormFieldDefinition<String>(
              name: 'duplicate', validators: [], initialValue: 'first'),
          FormFieldDefinition<String>(
              name: 'duplicate', validators: [], initialValue: 'second'),
        ];

        final serviceWithDuplicates =
            DefaultFieldRegistry(fields: duplicateFields);

        // Should handle duplicates (last one wins)
        expect(serviceWithDuplicates.fields.length, 2);
        expect(serviceWithDuplicates.getInitialValues()['duplicate'], 'second');
      });
    });

    group('Immutability', () {
      test('should return unmodifiable touched fields map', () {
        final touchedFields = fieldRegistry.touchedFields;

        expect(() => touchedFields['email'] = true,
            throwsA(isA<UnsupportedError>()));
      });

      test('should return validators map', () {
        final validators = fieldRegistry.validators;

        expect(validators, isA<Map<String, Validator>>());
        expect(validators.keys, containsAll(['email', 'age', 'termsAccepted']));
      });
    });
  });
}
