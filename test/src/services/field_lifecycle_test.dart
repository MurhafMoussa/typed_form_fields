import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/services/field_lifecycle.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/services/state_calculation.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('FieldLifecycle', () {
    late FieldLifecycle lifecycleManager;
    late FieldRegistry fieldRegistry;
    late StateCalculation stateComputer;
    late BuildContext context;

    setUp(() {
      fieldRegistry = DefaultFieldRegistry(
        fields: [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [MockValidator<String>()],
            initialValue: 'test@example.com',
          ),
          FormFieldDefinition<String>(
            name: 'password',
            validators: [MockValidator<String>()],
            initialValue: 'password123',
          ),
        ],
      );
      stateComputer = StateCalculation();
      lifecycleManager = DefaultFieldLifecycle(
        stateCalculation: stateComputer,
        fieldRegistry: fieldRegistry,
      );
    });

    testWidgets('should initialize with default state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                context = ctx;
                return Container();
              },
            ),
          ),
        ),
      );

      // Test that the service can be instantiated
      expect(lifecycleManager, isA<FieldLifecycle>());
      expect(lifecycleManager, isA<DefaultFieldLifecycle>());
    });

    group('Field Addition Operations', () {
      testWidgets('should add single field successfully',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final newField = FormFieldDefinition<String>(
          name: 'username',
          validators: [MockValidator<String>()],
          initialValue: 'john_doe',
        );

        final result = lifecycleManager.addField<String>(
          field: newField,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentFieldTypes: {'email': String, 'password': String},
          currentErrors: {},
          context: context,
        );

        expect(result.newValues['username'], 'john_doe');
        expect(result.newFieldTypes['username'], String);
        expect(result.newValues.length, 3); // email, password, username
        expect(result.newFieldTypes.length, 3);
        expect(fieldRegistry.fieldExists('username'), isTrue);
      });

      testWidgets('should add multiple fields successfully',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final newFields = [
          FormFieldDefinition<String>(
            name: 'username',
            validators: [MockValidator<String>()],
            initialValue: 'john_doe',
          ),
          FormFieldDefinition<int>(
            name: 'age',
            validators: [MockValidator<int>()],
            initialValue: 25,
          ),
        ];

        final result = lifecycleManager.addFields(
          fields: newFields,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentFieldTypes: {'email': String, 'password': String},
          currentErrors: {},
          context: context,
        );

        expect(result.newValues['username'], 'john_doe');
        expect(result.newValues['age'], 25);
        expect(result.newFieldTypes['username'], String);
        expect(result.newFieldTypes['age'], int);
        expect(result.newValues.length, 4); // email, password, username, age
        expect(result.newFieldTypes.length, 4);
        expect(fieldRegistry.fieldExists('username'), isTrue);
        expect(fieldRegistry.fieldExists('age'), isTrue);
      });

      testWidgets('should throw FormFieldError when adding existing field',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final existingField = FormFieldDefinition<String>(
          name: 'email', // This field already exists
          validators: [MockValidator<String>()],
          initialValue: 'new@example.com',
        );

        expect(
          () => lifecycleManager.addField<String>(
            field: existingField,
            currentValues: {
              'email': 'test@example.com',
              'password': 'password123'
            },
            currentFieldTypes: {'email': String, 'password': String},
            currentErrors: {},
            context: context,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });

      testWidgets(
          'should throw FormFieldError when adding multiple fields with existing field',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final newFields = [
          FormFieldDefinition<String>(
            name: 'username',
            validators: [MockValidator<String>()],
            initialValue: 'john_doe',
          ),
          FormFieldDefinition<String>(
            name: 'email', // This field already exists
            validators: [MockValidator<String>()],
            initialValue: 'new@example.com',
          ),
        ];

        expect(
          () => lifecycleManager.addFields(
            fields: newFields,
            currentValues: {
              'email': 'test@example.com',
              'password': 'password123'
            },
            currentFieldTypes: {'email': String, 'password': String},
            currentErrors: {},
            context: context,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('Field Removal Operations', () {
      testWidgets('should remove single field successfully',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = lifecycleManager.removeField(
          fieldName: 'email',
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentFieldTypes: {'email': String, 'password': String},
          currentErrors: {'email': 'Email error'},
          context: context,
        );

        expect(result.newValues.containsKey('email'), isFalse);
        expect(result.newFieldTypes.containsKey('email'), isFalse);
        expect(result.newErrors.containsKey('email'), isFalse);
        expect(result.newValues.length, 1); // Only password remains
        expect(result.newFieldTypes.length, 1);
        expect(fieldRegistry.fieldExists('email'), isFalse);
      });

      testWidgets('should remove multiple fields successfully',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = lifecycleManager.removeFields(
          fieldNames: ['email', 'password'],
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentFieldTypes: {'email': String, 'password': String},
          currentErrors: {'email': 'Email error', 'password': 'Password error'},
          context: context,
        );

        expect(result.newValues.containsKey('email'), isFalse);
        expect(result.newValues.containsKey('password'), isFalse);
        expect(result.newFieldTypes.containsKey('email'), isFalse);
        expect(result.newFieldTypes.containsKey('password'), isFalse);
        expect(result.newErrors.containsKey('email'), isFalse);
        expect(result.newErrors.containsKey('password'), isFalse);
        expect(result.newValues.length, 0);
        expect(result.newFieldTypes.length, 0);
        expect(fieldRegistry.fieldExists('email'), isFalse);
        expect(fieldRegistry.fieldExists('password'), isFalse);
      });

      testWidgets(
          'should throw FormFieldError when removing non-existent field',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(
          () => lifecycleManager.removeField(
            fieldName: 'nonExistent',
            currentValues: {
              'email': 'test@example.com',
              'password': 'password123'
            },
            currentFieldTypes: {'email': String, 'password': String},
            currentErrors: {},
            context: context,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });

      testWidgets(
          'should throw FormFieldError when removing multiple fields with non-existent field',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(
          () => lifecycleManager.removeFields(
            fieldNames: ['email', 'nonExistent'],
            currentValues: {
              'email': 'test@example.com',
              'password': 'password123'
            },
            currentFieldTypes: {'email': String, 'password': String},
            currentErrors: {},
            context: context,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('State Management Integration', () {
      testWidgets('should update form validity after adding field',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final newField = FormFieldDefinition<String>(
          name: 'username',
          validators: [MockValidator<String>()],
          initialValue: 'john_doe',
        );

        final result = lifecycleManager.addField<String>(
          field: newField,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentFieldTypes: {'email': String, 'password': String},
          currentErrors: {},
          context: context,
        );

        expect(result.newIsValid, isA<bool>());
        expect(result.newErrors, isA<Map<String, String>>());
      });

      testWidgets('should update form validity after removing field',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = lifecycleManager.removeField(
          fieldName: 'email',
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentFieldTypes: {'email': String, 'password': String},
          currentErrors: {'email': 'Email error'},
          context: context,
        );

        expect(result.newIsValid, isA<bool>());
        expect(result.newErrors, isA<Map<String, String>>());
      });

      testWidgets('should preserve existing field values and types',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final newField = FormFieldDefinition<String>(
          name: 'username',
          validators: [MockValidator<String>()],
          initialValue: 'john_doe',
        );

        final result = lifecycleManager.addField<String>(
          field: newField,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentFieldTypes: {'email': String, 'password': String},
          currentErrors: {},
          context: context,
        );

        // Verify existing fields are preserved
        expect(result.newValues['email'], 'test@example.com');
        expect(result.newValues['password'], 'password123');
        expect(result.newFieldTypes['email'], String);
        expect(result.newFieldTypes['password'], String);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle adding field with null initial value',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final newField = FormFieldDefinition<String?>(
          name: 'optionalField',
          validators: [MockValidator<String?>()],
          initialValue: null,
        );

        final result = lifecycleManager.addField<String?>(
          field: newField,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentFieldTypes: {'email': String, 'password': String},
          currentErrors: {},
          context: context,
        );

        expect(result.newValues['optionalField'], isNull);
        expect(result.newFieldTypes['optionalField'], isA<Type>());
        expect(fieldRegistry.fieldExists('optionalField'), isTrue);
      });

      testWidgets('should handle removing all fields',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = lifecycleManager.removeFields(
          fieldNames: ['email', 'password'],
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentFieldTypes: {'email': String, 'password': String},
          currentErrors: {},
          context: context,
        );

        expect(result.newValues.isEmpty, isTrue);
        expect(result.newFieldTypes.isEmpty, isTrue);
        expect(result.newErrors.isEmpty, isTrue);
      });

      testWidgets('should handle adding field with existing errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final newField = FormFieldDefinition<String>(
          name: 'username',
          validators: [MockValidator<String>()],
          initialValue: 'john_doe',
        );

        final result = lifecycleManager.addField<String>(
          field: newField,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentFieldTypes: {'email': String, 'password': String},
          currentErrors: {'email': 'Email error'}, // Existing error
          context: context,
        );

        expect(result.newValues['username'], 'john_doe');
        expect(result.newFieldTypes['username'], String);
        expect(result.newErrors, isA<Map<String, String>>());
      });
    });
  });
}

// Mock validator for testing
class MockValidator<T> extends Validator<T> {
  @override
  String? validate(T? value, BuildContext context) {
    if (value == null || value.toString().isEmpty) {
      return 'Field is required';
    }
    return null;
  }
}
