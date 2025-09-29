import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/services/form_debounced_validation_service.dart';
import 'package:typed_form_fields/src/services/form_field_manager.dart';
import 'package:typed_form_fields/src/services/form_state_computer.dart';
import 'package:typed_form_fields/src/services/form_validation_service.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('FormStateComputer', () {
    late FormStateComputer stateComputer;
    late FormFieldManager fieldManager;
    late MockBuildContext mockContext;

    setUp(() {
      stateComputer = FormStateComputer();
      fieldManager = FormFieldManager(
        fields: [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [MockValidator<String>()],
          ),
          FormFieldDefinition<int>(
              name: 'age', validators: [MockValidator<int>()]),
        ],
      );
      mockContext = MockBuildContext();
    });

    group('computeFieldUpdateState', () {
      test('should compute state for onSubmit validation type', () {
        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'old error'};

        final result = stateComputer.computeFieldUpdateState(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.onSubmit,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.errors, currentErrors); // Should not change
        expect(result.isValid, isFalse);
        expect(result.validationType, ValidationType.onSubmit);
      });

      test('should compute state for allFields validation type', () {
        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = <String, String>{};

        final result = stateComputer.computeFieldUpdateState(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.allFields,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.errors, isNotEmpty); // Should validate all fields
        expect(result.validationType, ValidationType.allFields);
      });

      test('should compute state for fieldsBeingEdited validation type', () {
        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = <String, String>{};

        final result = stateComputer.computeFieldUpdateState(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.fieldsBeingEdited,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.errors.containsKey('email'), isTrue);
        expect(result.validationType, ValidationType.fieldsBeingEdited);
      });

      test('should remove error when validation passes in fieldsBeingEdited',
          () {
        // Create a field manager with a validator that returns null (no error)
        final noErrorFieldManager = FormFieldManager(
          fields: [
            FormFieldDefinition<String>(
              name: 'email',
              validators: [NoErrorValidator<String>()],
            ),
          ],
        );

        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'Previous error'};

        final result = stateComputer.computeFieldUpdateState(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.fieldsBeingEdited,
          fieldManager: noErrorFieldManager,
          context: mockContext,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.errors.containsKey('email'), isFalse);
      });

      test('should compute state for disabled validation type', () {
        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'old error'};

        final result = stateComputer.computeFieldUpdateState(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.disabled,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.errors, isEmpty); // Should clear all errors
        expect(result.validationType, ValidationType.disabled);
      });

      test('should remove error when validation passes with debounce', () {
        final noErrorFieldManager = FormFieldManager(
          fields: [
            FormFieldDefinition<String>(
              name: 'email',
              validators: [NoErrorValidator<String>()],
            ),
          ],
        );

        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'Previous error'};

        bool stateComputed = false;
        stateComputer.computeFieldUpdateStateWithDebounce(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.fieldsBeingEdited,
          fieldManager: noErrorFieldManager,
          context: mockContext,
          onStateComputed: (newState) {
            stateComputed = true;
            expect(newState.values['email'], 'new@example.com');
            expect(newState.errors.containsKey('email'),
                isFalse); // Error should be removed
          },
        );

        expect(stateComputed,
            isFalse); // Should not compute immediately due to debounce
      });
    });

    group('computeFieldsUpdateState', () {
      test('should compute state for multiple fields with fieldsBeingEdited',
          () {
        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = <String, String>{};
        final fieldValues = {'email': 'new@example.com', 'age': 30};

        final result = stateComputer.computeFieldsUpdateState(
          fieldValues: fieldValues,
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.fieldsBeingEdited,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.values['age'], 30);
        expect(result.validationType, ValidationType.fieldsBeingEdited);
      });

      test('should remove errors when validation passes for multiple fields',
          () {
        final noErrorFieldManager = FormFieldManager(
          fields: [
            FormFieldDefinition<String>(
              name: 'email',
              validators: [NoErrorValidator<String>()],
            ),
            FormFieldDefinition<int>(
              name: 'age',
              validators: [NoErrorValidator<int>()],
            ),
          ],
        );

        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = {'email': 'old error', 'age': 'age error'};
        final fieldValues = {'email': 'new@example.com', 'age': 30};

        final result = stateComputer.computeFieldsUpdateState(
          fieldValues: fieldValues,
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.fieldsBeingEdited,
          fieldManager: noErrorFieldManager,
          context: mockContext,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.values['age'], 30);
        expect(result.errors, isEmpty); // Should remove all errors
      });

      test('should clear all errors for disabled validation type', () {
        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = {'email': 'old error', 'age': 'age error'};
        final fieldValues = {'email': 'new@example.com', 'age': 30};

        final result = stateComputer.computeFieldsUpdateState(
          fieldValues: fieldValues,
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.disabled,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.values['age'], 30);
        expect(result.errors, isEmpty); // Should clear all errors
        expect(result.validationType, ValidationType.disabled);
      });
    });

    group('computeFieldsUpdateState', () {
      test('should compute state for multiple field updates', () {
        final currentValues = {'email': 'old@example.com', 'age': 20};
        final currentErrors = <String, String>{};
        final fieldValues = {'email': 'new@example.com', 'age': 30};

        final result = stateComputer.computeFieldsUpdateState(
          fieldValues: fieldValues,
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.allFields,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.values['age'], 30);
        expect(result.validationType, ValidationType.allFields);
      });

      test('should handle onSubmit validation type for multiple fields', () {
        final currentValues = {'email': 'old@example.com', 'age': 20};
        final currentErrors = {'email': 'old error'};
        final fieldValues = {'email': 'new@example.com', 'age': 30};

        final result = stateComputer.computeFieldsUpdateState(
          fieldValues: fieldValues,
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.onSubmit,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.values['age'], 30);
        expect(result.errors, currentErrors); // Should not change
      });
    });

    group('computeErrorUpdateState', () {
      test('should compute state with new errors', () {
        final currentValues = {'email': 'test@example.com', 'age': 25};
        final newErrors = {'email': 'Email error', 'age': 'Age error'};

        final result = stateComputer.computeErrorUpdateState(
          newErrors: newErrors,
          currentValues: currentValues,
          validationType: ValidationType.allFields,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.values, currentValues);
        expect(result.errors, newErrors);
        expect(result.validationType, ValidationType.allFields);
      });

      test('should compute validity based on errors', () {
        final currentValues = {'email': 'test@example.com', 'age': 25};
        final newErrors = <String, String>{}; // No errors

        final result = stateComputer.computeErrorUpdateState(
          newErrors: newErrors,
          currentValues: currentValues,
          validationType: ValidationType.allFields,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.errors, isEmpty);
        // Validity depends on touched fields and validation
      });
    });

    group('computeValidationTypeChangeState', () {
      test('should compute state for validation type change', () {
        final currentValues = {'email': 'test@example.com', 'age': 25};
        final currentErrors = {'email': 'Email error'};

        final result = stateComputer.computeValidationTypeChangeState(
          newValidationType: ValidationType.fieldsBeingEdited,
          currentValues: currentValues,
          currentErrors: currentErrors,
          fieldManager: fieldManager,
          context: mockContext,
        );

        expect(result.values, currentValues);
        expect(result.errors, currentErrors);
        expect(result.validationType, ValidationType.fieldsBeingEdited);
      });
    });

    group('computeFieldUpdateStateWithDebounce', () {
      test('should handle debounced validation for onSubmit', () {
        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'old error'};
        TypedFormState? capturedState;

        stateComputer.computeFieldUpdateStateWithDebounce(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.onSubmit,
          fieldManager: fieldManager,
          context: mockContext,
          onStateComputed: (state) {
            capturedState = state;
          },
        );

        expect(capturedState, isNotNull);
        expect(capturedState!.values['email'], 'new@example.com');
        expect(capturedState!.errors, currentErrors);
        expect(capturedState!.validationType, ValidationType.onSubmit);
      });

      test('should handle debounced validation for allFields', () async {
        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = <String, String>{};
        TypedFormState? capturedState;

        stateComputer.computeFieldUpdateStateWithDebounce(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.allFields,
          fieldManager: fieldManager,
          context: mockContext,
          onStateComputed: (state) {
            capturedState = state;
          },
        );

        // Should not be called immediately
        expect(capturedState, isNull);

        // Wait for debounce delay
        await Future<void>.delayed(const Duration(milliseconds: 350));

        // Should be called after delay
        expect(capturedState, isNotNull);
        expect(capturedState!.values['email'], 'new@example.com');
        expect(capturedState!.validationType, ValidationType.allFields);
      });

      test(
        'should handle debounced validation for fieldsBeingEdited',
        () async {
          final currentValues = {'email': 'old@example.com', 'age': 25};
          final currentErrors = <String, String>{};
          TypedFormState? capturedState;

          stateComputer.computeFieldUpdateStateWithDebounce(
            fieldName: 'email',
            value: 'new@example.com',
            currentValues: currentValues,
            currentErrors: currentErrors,
            validationType: ValidationType.fieldsBeingEdited,
            fieldManager: fieldManager,
            context: mockContext,
            onStateComputed: (state) {
              capturedState = state;
            },
          );

          // Should not be called immediately
          expect(capturedState, isNull);

          // Wait for debounce delay
          await Future<void>.delayed(const Duration(milliseconds: 350));

          // Should be called after delay
          expect(capturedState, isNotNull);
          expect(capturedState!.values['email'], 'new@example.com');
          expect(
            capturedState!.validationType,
            ValidationType.fieldsBeingEdited,
          );
        },
      );

      test('should handle disabled validation type', () {
        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'old error'};
        TypedFormState? capturedState;

        stateComputer.computeFieldUpdateStateWithDebounce(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationType: ValidationType.disabled,
          fieldManager: fieldManager,
          context: mockContext,
          onStateComputed: (state) {
            capturedState = state;
          },
        );

        expect(capturedState, isNotNull);
        expect(capturedState!.values['email'], 'new@example.com');
        expect(capturedState!.errors, isEmpty);
        expect(capturedState!.validationType, ValidationType.disabled);
      });
    });

    group('getters', () {
      test('should provide access to validation service', () {
        expect(stateComputer.validationService, isA<FormValidationService>());
      });

      test('should provide access to debounced validation service', () {
        expect(
          stateComputer.debouncedValidationService,
          isA<FormDebouncedValidationService>(),
        );
      });
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockValidator<T> implements Validator<T> {
  @override
  String? validate(T? value, BuildContext context) {
    return 'Mock error';
  }
}

class NoErrorValidator<T> implements Validator<T> {
  @override
  String? validate(T? value, BuildContext context) {
    return null; // Always returns no error
  }
}
