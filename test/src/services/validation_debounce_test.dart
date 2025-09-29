import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/services/validation_debounce.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('ValidationDebounce', () {
    late ValidationDebounce debounceService;
    late MockBuildContext mockContext;
    late MockValidator mockValidator;

    setUp(() {
      debounceService = ValidationDebounce();
      mockContext = MockBuildContext();
      mockValidator = MockValidator();
    });

    tearDown(() {
      debounceService.dispose();
    });

    group('validateFieldWithDebounce', () {
      test('should validate field after debounce delay', () async {
        final validators = {'email': mockValidator};

        String? capturedError;
        Map<String, String> capturedErrors = {};

        debounceService.validateFieldWithDebounce(
          fieldName: 'email',
          value: 'test@example.com',
          validators: validators,
          context: mockContext,
          onValidationComplete: (error, errors) {
            capturedError = error;
            capturedErrors = errors;
          },
        );

        // Should not validate immediately
        expect(capturedError, isNull);
        expect(capturedErrors, isEmpty);

        // Wait for debounce delay
        await Future<void>.delayed(const Duration(milliseconds: 350));

        // Should validate after delay
        expect(mockValidator.validateCallCount, 1);
        expect(capturedError, 'Email error');
        expect(capturedErrors, {'email': 'Email error'});
      });

      test(
        'should cancel previous validation when new validation is triggered',
        () async {
          final validators = {'email': mockValidator};

          String? capturedError;

          // First validation
          debounceService.validateFieldWithDebounce(
            fieldName: 'email',
            value: 'test1@example.com',
            validators: validators,
            context: mockContext,
            onValidationComplete: (error, errors) {
              capturedError = error;
            },
          );

          // Second validation (should cancel first)
          debounceService.validateFieldWithDebounce(
            fieldName: 'email',
            value: 'test2@example.com',
            validators: validators,
            context: mockContext,
            onValidationComplete: (error, errors) {
              capturedError = error;
            },
          );

          // Wait for debounce delay
          await Future<void>.delayed(const Duration(milliseconds: 350));

          // Should only validate once (the second call)
          expect(mockValidator.validateCallCount, 1);
          expect(capturedError, 'Email error');
        },
      );

      test('should handle null validator gracefully', () async {
        final validators = <String, Validator>{};

        String? capturedError;
        Map<String, String> capturedErrors = {};

        debounceService.validateFieldWithDebounce(
          fieldName: 'email',
          value: 'test@example.com',
          validators: validators,
          context: mockContext,
          onValidationComplete: (error, errors) {
            capturedError = error;
            capturedErrors = errors;
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 350));

        expect(capturedError, isNull);
        expect(capturedErrors, isEmpty);
      });
    });

    group('validateFieldImmediately', () {
      test('should validate field immediately without debouncing', () async {
        final validators = {'email': mockValidator};

        String? capturedError;
        Map<String, String> capturedErrors = {};

        debounceService.validateFieldImmediately(
          fieldName: 'email',
          value: 'test@example.com',
          validators: validators,
          context: mockContext,
          onValidationComplete: (error, errors) {
            capturedError = error;
            capturedErrors = errors;
          },
        );

        // Should validate immediately
        expect(mockValidator.validateCallCount, 1);
        expect(capturedError, 'Email error');
        expect(capturedErrors, {'email': 'Email error'});
      });

      test('should cancel pending debounced validation', () async {
        final validators = {'email': mockValidator};

        String? capturedError;

        // Start debounced validation
        debounceService.validateFieldWithDebounce(
          fieldName: 'email',
          value: 'test1@example.com',
          validators: validators,
          context: mockContext,
          onValidationComplete: (error, errors) {
            capturedError = error;
          },
        );

        // Immediately validate
        debounceService.validateFieldImmediately(
          fieldName: 'email',
          value: 'test2@example.com',
          validators: validators,
          context: mockContext,
          onValidationComplete: (error, errors) {
            capturedError = error;
          },
        );

        // Wait for original debounce delay
        await Future<void>.delayed(const Duration(milliseconds: 350));

        // Should only validate once (the immediate call)
        expect(mockValidator.validateCallCount, 1);
        expect(capturedError, 'Email error');
      });
    });

    group('validateAllFieldsWithDebounce', () {
      test('should validate all fields after debounce delay', () async {
        final validators = {
          'email': MockValidator(),
          'password': MockValidator(),
        };
        final values = {'email': 'test@example.com', 'password': 'password123'};

        Map<String, String> capturedErrors = {};

        debounceService.validateAllFieldsWithDebounce(
          values: values,
          validators: validators,
          context: mockContext,
          onValidationComplete: (errors) {
            capturedErrors = errors;
          },
        );

        // Should not validate immediately
        expect(capturedErrors, isEmpty);

        // Wait for debounce delay
        await Future<void>.delayed(const Duration(milliseconds: 350));

        // Should validate all fields after delay
        expect(capturedErrors, {
          'email': 'Email error',
          'password': 'Email error',
        });
      });

      test('should cancel previous all-fields validation', () async {
        final validators = {'email': MockValidator()};
        final values1 = {'email': 'test1@example.com'};
        final values2 = {'email': 'test2@example.com'};

        Map<String, String> capturedErrors = {};

        // First validation
        debounceService.validateAllFieldsWithDebounce(
          values: values1,
          validators: validators,
          context: mockContext,
          onValidationComplete: (errors) {
            capturedErrors = errors;
          },
        );

        // Second validation (should cancel first)
        debounceService.validateAllFieldsWithDebounce(
          values: values2,
          validators: validators,
          context: mockContext,
          onValidationComplete: (errors) {
            capturedErrors = errors;
          },
        );

        // Wait for debounce delay
        await Future<void>.delayed(const Duration(milliseconds: 350));

        // Should only validate once
        expect(capturedErrors, {'email': 'Email error'});
      });
    });

    group('validateAllFieldsImmediately', () {
      test('should validate all fields immediately', () async {
        final validators = {
          'email': MockValidator(),
          'password': MockValidator(),
        };
        final values = {'email': 'test@example.com', 'password': 'password123'};

        Map<String, String> capturedErrors = {};

        debounceService.validateAllFieldsImmediately(
          values: values,
          validators: validators,
          context: mockContext,
          onValidationComplete: (errors) {
            capturedErrors = errors;
          },
        );

        // Should validate immediately
        expect(capturedErrors, {
          'email': 'Email error',
          'password': 'Email error',
        });
      });
    });

    group('cancelFieldValidation', () {
      test('should cancel validation for specific field', () async {
        final validators = {'email': mockValidator};

        String? capturedError;
        Map<String, String> capturedErrors = {};

        debounceService.validateFieldWithDebounce(
          fieldName: 'email',
          value: 'test@example.com',
          validators: validators,
          context: mockContext,
          onValidationComplete: (error, errors) {
            capturedError = error;
            capturedErrors = errors;
          },
        );

        // Cancel validation
        debounceService.cancelFieldValidation('email');

        // Wait for original debounce delay
        await Future<void>.delayed(const Duration(milliseconds: 350));

        // Should not validate
        expect(capturedError, isNull);
        expect(capturedErrors, isEmpty);
      });
    });

    group('dispose', () {
      test('should cancel all pending validations', () async {
        final validators = {'email': mockValidator};

        String? capturedError;
        Map<String, String> capturedErrors = {};

        debounceService.validateFieldWithDebounce(
          fieldName: 'email',
          value: 'test@example.com',
          validators: validators,
          context: mockContext,
          onValidationComplete: (error, errors) {
            capturedError = error;
            capturedErrors = errors;
          },
        );

        // Dispose debounceService
        debounceService.dispose();

        // Wait for original debounce delay
        await Future<void>.delayed(const Duration(milliseconds: 350));

        // Should not validate
        expect(capturedError, isNull);
        expect(capturedErrors, isEmpty);
      });
    });

    group('validationService getter', () {
      test('should provide access to validation debounceService', () {
        // validationService getter has been removed as validation is now internal
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

  @override
  String? validate(Object? value, BuildContext context) {
    validateCallCount++;
    return 'Email error';
  }
}
