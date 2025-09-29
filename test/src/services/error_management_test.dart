import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/services/error_management.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/services/state_calculation.dart';
import 'package:typed_form_fields/src/services/validation_coordination.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('ErrorManagement', () {
    late ErrorManagement errorManager;
    late FieldRegistry fieldRegistry;
    late StateCalculation stateComputer;
    late ValidationCoordination orchestrator;
    late BuildContext mockContext;

    setUp(() {
      fieldRegistry = DefaultFieldRegistry(
          fields: TestFieldFactory.createEmailAndAgeFields());
      stateComputer = StateCalculation();
      orchestrator =
          DefaultValidationCoordination(fieldRegistry: fieldRegistry);
      errorManager = DefaultErrorManagement(
        validationCoordination: orchestrator,
        fieldRegistry: fieldRegistry,
        stateCalculation: stateComputer,
      );
    });

    group('updateError', () {
      testWidgets('should update single field error',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com', 'age': 25};
        final currentErrors = <String, String>{};

        final newState = errorManager.updateError(
          fieldName: 'email',
          errorMessage: 'Custom error',
          currentValues: currentValues,
          currentErrors: currentErrors,
          context: mockContext,
        );

        expect(newState.values, currentValues);
        expect(newState.errors['email'], 'Custom error');
        expect(newState.fieldTypes, fieldRegistry.fieldTypes);
      });

      testWidgets('should clear error when errorMessage is null',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com', 'age': 25};
        final currentErrors = {'email': 'Previous error'};

        final newState = errorManager.updateError(
          fieldName: 'email',
          errorMessage: null,
          currentValues: currentValues,
          currentErrors: currentErrors,
          context: mockContext,
        );

        expect(newState.values, currentValues);
        expect(newState.errors.containsKey('email'), isFalse);
        expect(newState.fieldTypes, fieldRegistry.fieldTypes);
      });

      testWidgets(
          'should throw FormFieldError for non-existent field in updateError',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com'};
        final currentErrors = <String, String>{};

        expect(
          () => errorManager.updateError(
            fieldName: 'nonexistent',
            errorMessage: 'Error',
            currentValues: currentValues,
            currentErrors: currentErrors,
            context: mockContext,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('updateErrors', () {
      testWidgets('should update multiple field errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com', 'age': 25};
        final currentErrors = <String, String>{};

        final newState = errorManager.updateErrors(
          errors: {
            'email': 'Email error',
            'age': 'Age error',
          },
          currentValues: currentValues,
          currentErrors: currentErrors,
          context: mockContext,
        );

        expect(newState.values, currentValues);
        expect(newState.errors['email'], 'Email error');
        expect(newState.errors['age'], 'Age error');
        expect(newState.fieldTypes, fieldRegistry.fieldTypes);
      });

      testWidgets('should clear errors when errorMessage is null',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com', 'age': 25};
        final currentErrors = {
          'email': 'Previous error',
          'age': 'Previous error'
        };

        final newState = errorManager.updateErrors(
          errors: {
            'email': null,
            'age': 'New age error',
          },
          currentValues: currentValues,
          currentErrors: currentErrors,
          context: mockContext,
        );

        expect(newState.values, currentValues);
        expect(newState.errors.containsKey('email'), isFalse);
        expect(newState.errors['age'], 'New age error');
        expect(newState.fieldTypes, fieldRegistry.fieldTypes);
      });

      testWidgets(
          'should throw FormFieldError for non-existent field in updateErrors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com'};
        final currentErrors = <String, String>{};

        expect(
          () => errorManager.updateErrors(
            errors: {'nonexistent': 'Error'},
            currentValues: currentValues,
            currentErrors: currentErrors,
            context: mockContext,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });
    });
  });
}

class MockBuildContext {
  // Simple mock that doesn't extend BuildContext to avoid implementation issues
}

class TestFieldFactory {
  static List<FormFieldDefinition> createEmailAndAgeFields() {
    return [
      FormFieldDefinition<String>(
        name: 'email',
        validators: [MockValidator<String>()],
        initialValue: 'test@example.com',
      ),
      FormFieldDefinition<int>(
        name: 'age',
        validators: [MockValidator<int>()],
        initialValue: 25,
      ),
    ];
  }
}

class MockValidator<T> extends Validator<T> {
  @override
  String? validate(T? value, BuildContext context) {
    if (value == null || value.toString().isEmpty) {
      return 'Mock error';
    }
    return null;
  }
}
