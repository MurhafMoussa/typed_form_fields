import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/services/form_validation_service.dart';
import 'package:typed_form_fields/src/validators/typed_cross_field_validator.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('FormValidationService', () {
    late FormValidationService service;
    late MockBuildContext mockContext;
    late MockValidator mockValidator;

    setUp(() {
      service = FormValidationService();
      mockContext = MockBuildContext();
      mockValidator = MockValidator();
    });

    group('validateField', () {
      test('should validate field and return error message', () {
        final result = service.validateField<String>(
          validator: mockValidator,
          value: 'test@example.com',
          context: mockContext,
        );

        expect(result, 'Email error');
        expect(mockValidator.validateCallCount, 1);
      });

      test('should return null when validation passes', () {
        mockValidator.shouldReturnError = false;

        final result = service.validateField<String>(
          validator: mockValidator,
          value: 'valid@example.com',
          context: mockContext,
        );

        expect(result, isNull);
        expect(mockValidator.validateCallCount, 1);
      });

      test('should handle null value', () {
        final result = service.validateField<String>(
          validator: mockValidator,
          context: mockContext,
        );

        expect(result, 'Email error');
        expect(mockValidator.validateCallCount, 1);
      });
    });

    group('validateFieldByName', () {
      test('should validate field by name and return error', () {
        final validators = {'email': mockValidator};
        final values = {'email': 'test@example.com'};

        final result = service.validateFieldByName(
          fieldName: 'email',
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, 'Email error');
        expect(mockValidator.validateCallCount, 1);
      });

      test('should return null when field has no validator', () {
        final validators = <String, Validator>{};
        final values = {'email': 'test@example.com'};

        final result = service.validateFieldByName(
          fieldName: 'email',
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, isNull);
        expect(mockValidator.validateCallCount, 0);
      });

      test('should return null when field value is not in values map', () {
        final validators = {'email': mockValidator};
        final values = <String, Object?>{};

        final result = service.validateFieldByName(
          fieldName: 'email',
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, 'Email error'); // Validator still gets called with null
        expect(mockValidator.validateCallCount, 1);
      });
    });

    group('validateFields', () {
      test('should validate all fields and return errors map', () {
        final validators = {
          'email': MockValidator(),
          'password': MockValidator(),
        };
        final values = {'email': 'test@example.com', 'password': 'password123'};

        final result = service.validateFields(
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, {'email': 'Email error', 'password': 'Email error'});
      });

      test('should return empty map when all validations pass', () {
        final validators = {
          'email': MockValidator(shouldReturnError: false),
          'password': MockValidator(shouldReturnError: false),
        };
        final values = {
          'email': 'valid@example.com',
          'password': 'validpassword',
        };

        final result = service.validateFields(
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, isEmpty);
      });

      test('should only validate fields that have validators', () {
        final validators = {'email': MockValidator()};
        final values = {'email': 'test@example.com', 'password': 'password123'};

        final result = service.validateFields(
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, {'email': 'Email error'});
      });
    });

    group('computeOverallValidity', () {
      test('should return true when all fields are valid and touched', () {
        final validators = {
          'email': MockValidator(shouldReturnError: false),
          'password': MockValidator(shouldReturnError: false),
        };
        final values = {
          'email': 'valid@example.com',
          'password': 'validpassword',
        };
        final touchedFields = {'email': true, 'password': true};

        final result = service.computeOverallValidity(
          values: values,
          validators: validators,
          touchedFields: touchedFields,
          context: mockContext,
        );

        expect(result, isTrue);
      });

      test('should return false when any field is not touched', () {
        final validators = {
          'email': MockValidator(shouldReturnError: false),
          'password': MockValidator(shouldReturnError: false),
        };
        final values = {
          'email': 'valid@example.com',
          'password': 'validpassword',
        };
        final touchedFields = {
          'email': true,
          'password': false, // Not touched
        };

        final result = service.computeOverallValidity(
          values: values,
          validators: validators,
          touchedFields: touchedFields,
          context: mockContext,
        );

        expect(result, isFalse);
      });

      test('should return false when any field has validation error', () {
        final validators = {
          'email': MockValidator(shouldReturnError: false),
          'password': MockValidator(), // Has error
        };
        final values = {
          'email': 'valid@example.com',
          'password': 'invalidpassword',
        };
        final touchedFields = {'email': true, 'password': true};

        final result = service.computeOverallValidity(
          values: values,
          validators: validators,
          touchedFields: touchedFields,
          context: mockContext,
        );

        expect(result, isFalse);
      });
    });

    group('computeOverallValidityWithErrors', () {
      test('should return false when there are errors', () {
        final validators = {
          'email': MockValidator(shouldReturnError: false),
          'password': MockValidator(shouldReturnError: false),
        };
        final values = {
          'email': 'valid@example.com',
          'password': 'validpassword',
        };
        final touchedFields = {'email': true, 'password': true};
        final errors = {'email': 'Email error'};

        final result = service.computeOverallValidityWithErrors(
          values: values,
          errors: errors,
          touchedFields: touchedFields,
          validators: validators,
          context: mockContext,
        );

        expect(result, isFalse);
      });

      test(
        'should return true when no errors and all fields touched and valid',
        () {
          final validators = {
            'email': MockValidator(shouldReturnError: false),
            'password': MockValidator(shouldReturnError: false),
          };
          final values = {
            'email': 'valid@example.com',
            'password': 'validpassword',
          };
          final touchedFields = {'email': true, 'password': true};
          final errors = <String, String>{};

          final result = service.computeOverallValidityWithErrors(
            values: values,
            errors: errors,
            touchedFields: touchedFields,
            validators: validators,
            context: mockContext,
          );

          expect(result, isTrue);
        },
      );

      test('should return false when field is not touched', () {
        final validators = {'email': MockValidator(shouldReturnError: false)};
        final values = {'email': 'valid@example.com'};
        final touchedFields = {
          'email': false, // Not touched
        };
        final errors = <String, String>{};

        final result = service.computeOverallValidityWithErrors(
          values: values,
          errors: errors,
          touchedFields: touchedFields,
          validators: validators,
          context: mockContext,
        );

        expect(result, isFalse);
      });
    });

    group('computeOverallValidityIgnoringTouched', () {
      test(
          'should return true when all fields are valid regardless of touched state',
          () {
        final validators = {
          'email': MockValidator(shouldReturnError: false),
          'password': MockValidator(shouldReturnError: false),
        };
        final values = {
          'email': 'valid@example.com',
          'password': 'validpassword',
        };

        final result = service.computeOverallValidityIgnoringTouched(
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, isTrue);
      });

      test('should return false when any field has validation error', () {
        final validators = {
          'email': MockValidator(shouldReturnError: false),
          'password': MockValidator(), // Has error
        };
        final values = {
          'email': 'valid@example.com',
          'password': 'invalidpassword',
        };

        final result = service.computeOverallValidityIgnoringTouched(
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, isFalse);
      });
    });

    group('validateDependentFields', () {
      test('should validate fields that depend on the changed field', () {
        final mockCrossFieldValidator = MockCrossFieldValidator();
        final validators = <String, Validator>{
          'password': MockValidator(),
          'confirmPassword': mockCrossFieldValidator,
        };
        final values = {
          'password': 'password123',
          'confirmPassword': 'password456',
        };

        final result = service.validateDependentFields(
          changedFieldName: 'password',
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, {'confirmPassword': 'Cross field error'});
        expect(mockCrossFieldValidator.validateCallCount, 1);
      });

      test('should return empty map when no fields depend on changed field',
          () {
        final validators = {
          'email': MockValidator(),
          'password': MockValidator(),
        };
        final values = {
          'email': 'test@example.com',
          'password': 'password123',
        };

        final result = service.validateDependentFields(
          changedFieldName: 'email',
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, isEmpty);
      });

      test('should not validate non-cross-field validators', () {
        final validators = <String, Validator>{
          'password': MockValidator(),
          'confirmPassword': MockValidator(),
        };
        final values = {
          'password': 'password123',
          'confirmPassword': 'password456',
        };

        final result = service.validateDependentFields(
          changedFieldName: 'password',
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, isEmpty);
      });
    });

    group('validateFieldAndDependents', () {
      test('should validate field and its dependents', () {
        final mockCrossFieldValidator = MockCrossFieldValidator();
        final validators = <String, Validator>{
          'password': MockValidator(),
          'confirmPassword': mockCrossFieldValidator,
        };
        final values = {
          'password': 'password123',
          'confirmPassword': 'password456',
        };

        final result = service.validateFieldAndDependents(
          fieldName: 'password',
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, {
          'password': 'Email error',
          'confirmPassword': 'Cross field error',
        });
      });

      test('should only validate field when no dependents', () {
        final validators = <String, Validator>{
          'email': MockValidator(),
          'password': MockValidator(),
        };
        final values = {
          'email': 'test@example.com',
          'password': 'password123',
        };

        final result = service.validateFieldAndDependents(
          fieldName: 'email',
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, {'email': 'Email error'});
      });

      test('should return empty map when field and dependents are valid', () {
        final mockCrossFieldValidator =
            MockCrossFieldValidator(shouldReturnError: false);
        final validators = <String, Validator>{
          'password': MockValidator(shouldReturnError: false),
          'confirmPassword': mockCrossFieldValidator,
        };
        final values = {
          'password': 'password123',
          'confirmPassword': 'password123',
        };

        final result = service.validateFieldAndDependents(
          fieldName: 'password',
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(result, isEmpty);
      });
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockValidator implements Validator {
  int validateCallCount = 0;
  bool shouldReturnError = true;

  MockValidator({this.shouldReturnError = true});

  @override
  String? validate(Object? value, BuildContext context) {
    validateCallCount++;
    return shouldReturnError ? 'Email error' : null;
  }
}

class MockCrossFieldValidator extends TypedCrossFieldValidator<String> {
  int validateCallCount = 0;
  final bool shouldReturnError;

  MockCrossFieldValidator({this.shouldReturnError = true})
      : super(
          dependentFields: ['password'],
          validator: (value, fieldValues, context) => null,
        );

  @override
  String? validate(String? value, BuildContext context) {
    validateCallCount++;
    return shouldReturnError ? 'Cross field error' : null;
  }
}
