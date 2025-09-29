import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';

void main() {
  group('CoreFormState', () {
    late TypedFormState state;

    setUp(() {
      state = const TypedFormState(
        values: {'email': 'test@example.com', 'age': 25, 'name': 'John Doe'},
        errors: {'email': 'Email error', 'age': 'Age error'},
        isValid: false,
        validationType: ValidationType.allFields,
        fieldTypes: {'email': String, 'age': int, 'name': String},
      );
    });

    group('constructor', () {
      test('should create state with provided values', () {
        expect(state.values, {
          'email': 'test@example.com',
          'age': 25,
          'name': 'John Doe',
        });
        expect(state.errors, {'email': 'Email error', 'age': 'Age error'});
        expect(state.isValid, isFalse);
        expect(state.validationType, ValidationType.allFields);
        expect(state.fieldTypes, {'email': String, 'age': int, 'name': String});
      });

      test('should use default validation type when not provided', () {
        const stateWithDefault = TypedFormState(
          values: {'email': 'test@example.com'},
          errors: {},
          isValid: true,
          fieldTypes: {'email': String},
        );

        expect(
          stateWithDefault.validationType,
          ValidationType.fieldsBeingEdited,
        );
      });
    });

    group('initial factory', () {
      test('should create initial state with empty values', () {
        final initialState = TypedFormState.initial();

        expect(initialState.values, isEmpty);
        expect(initialState.errors, isEmpty);
        expect(initialState.isValid, isFalse);
        expect(initialState.validationType, ValidationType.fieldsBeingEdited);
        expect(initialState.fieldTypes, isEmpty);
      });
    });

    group('getValue', () {
      test('should return correct value for existing field', () {
        expect(state.getValue<String>('email'), 'test@example.com');
        expect(state.getValue<int>('age'), 25);
        expect(state.getValue<String>('name'), 'John Doe');
      });

      test('should return null for null value', () {
        final stateWithNull = state.copyWith(
          values: {...state.values, 'email': null},
        );

        expect(stateWithNull.getValue<String>('email'), isNull);
      });

      test('should throw FormFieldError for non-existing field', () {
        expect(
          () => state.getValue<String>('nonExistent'),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('should throw FormFieldError for wrong type', () {
        expect(
          () => state.getValue<int>('email'), // email is String, not int
          throwsA(isA<FormFieldError>()),
        );

        expect(
          () => state.getValue<String>('age'), // age is int, not String
          throwsA(isA<FormFieldError>()),
        );
      });

      test('should handle null field type gracefully', () {
        // Create a state with a field that has no type defined
        const stateWithNullType = TypedFormState(
          values: {'email': 'test@example.com'},
          errors: {},
          isValid: false,
          validationType: ValidationType.allFields,
          fieldTypes: {}, // No field types defined
        );

        // When field types is empty, getValue should still work but without type checking
        expect(stateWithNullType.getValue<String>('email'), 'test@example.com');
      });
    });

    group('getError', () {
      test('should return error for field with error', () {
        expect(state.getError('email'), 'Email error');
        expect(state.getError('age'), 'Age error');
      });

      test('should return null for field without error', () {
        expect(state.getError('name'), isNull);
      });

      test('should return null for non-existing field', () {
        expect(state.getError('nonExistent'), isNull);
      });
    });

    group('hasError', () {
      test('should return true for field with error', () {
        expect(state.hasError('email'), isTrue);
        expect(state.hasError('age'), isTrue);
      });

      test('should return false for field without error', () {
        expect(state.hasError('name'), isFalse);
      });

      test('should return false for non-existing field', () {
        expect(state.hasError('nonExistent'), isFalse);
      });
    });

    group('copyWith', () {
      test('should create new state with updated values', () {
        final newState = state.copyWith(
          values: {'email': 'new@example.com'},
          isValid: true,
        );

        expect(newState.values['email'], 'new@example.com');
        expect(
          newState.values['age'],
          isNull,
        ); // copyWith replaces the entire values map
        expect(newState.isValid, isTrue);
        expect(newState.errors, state.errors); // Should remain unchanged
      });

      test('should create new state with updated errors', () {
        final newState = state.copyWith(errors: {'email': 'New email error'});

        expect(newState.errors['email'], 'New email error');
        expect(
          newState.errors['age'],
          isNull,
        ); // copyWith replaces the entire errors map
        expect(newState.values, state.values); // Should remain unchanged
      });

      test('should create new state with updated validation type', () {
        final newState = state.copyWith(
          validationType: ValidationType.onSubmit,
        );

        expect(newState.validationType, ValidationType.onSubmit);
        expect(newState.values, state.values); // Should remain unchanged
        expect(newState.errors, state.errors); // Should remain unchanged
      });

      test('should create new state with updated field types', () {
        final newState = state.copyWith(
          fieldTypes: {'email': int}, // Change email type to int
        );

        expect(newState.fieldTypes['email'], int);
        expect(
          newState.fieldTypes['age'],
          isNull,
        ); // copyWith replaces the entire fieldTypes map
        expect(newState.values, state.values); // Should remain unchanged
      });
    });

    group('equality', () {
      test('should be equal to identical state', () {
        final identicalState = TypedFormState(
          values: state.values,
          errors: state.errors,
          isValid: state.isValid,
          validationType: state.validationType,
          fieldTypes: state.fieldTypes,
        );

        expect(state, equals(identicalState));
      });

      test('should not be equal to different state', () {
        final differentState = state.copyWith(isValid: true);

        expect(state, isNot(equals(differentState)));
      });
    });

    group('toString', () {
      test('should include all properties in string representation', () {
        final stringRepresentation = state.toString();

        expect(stringRepresentation, contains('test@example.com'));
        expect(stringRepresentation, contains('Email error'));
        expect(stringRepresentation, contains('false'));
        expect(stringRepresentation, contains('ValidationType.allFields'));
      });
    });
  });

  group('ValidationType', () {
    test('should have correct enum values', () {
      expect(ValidationType.values, [
        ValidationType.onSubmit,
        ValidationType.allFields,
        ValidationType.fieldsBeingEdited,
        ValidationType.disabled,
      ]);
    });

    test('should have correct string representation', () {
      expect(ValidationType.onSubmit.toString(), 'ValidationType.onSubmit');
      expect(ValidationType.allFields.toString(), 'ValidationType.allFields');
      expect(
        ValidationType.fieldsBeingEdited.toString(),
        'ValidationType.fieldsBeingEdited',
      );
      expect(ValidationType.disabled.toString(), 'ValidationType.disabled');
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
