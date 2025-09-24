import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('Validator', () {
    late MockValidator<String> validator;
    late MockBuildContext mockContext;

    setUp(() {
      validator = MockValidator<String>();
      mockContext = MockBuildContext();
    });

    test('should validate value and return error message', () {
      validator.mockValidate = (value, context) => 'Test error';

      final result = validator.validate('test', mockContext);

      expect(result, 'Test error');
    });

    test('should validate value and return null for valid input', () {
      validator.mockValidate = (value, context) => null;

      final result = validator.validate('valid', mockContext);

      expect(result, isNull);
    });

    test('should handle null value', () {
      validator.mockValidate =
          (value, context) => value == null ? 'Required field' : null;

      final result = validator.validate(null, mockContext);

      expect(result, 'Required field');
    });

    test('should create validator instance', () {
      // This test covers the constructor line that was missing coverage
      const validator = ConcreteValidator();
      expect(validator, isA<Validator<String>>());

      // Also test the validate method to ensure it works
      final result = validator.validate('test', mockContext);
      expect(result, isNull);
    });

    test('should create different types of validators', () {
      // Create multiple validators to ensure constructor coverage
      const stringValidator = ConcreteValidator();
      const intValidator = AnotherValidator();

      expect(stringValidator, isA<Validator<String>>());
      expect(intValidator, isA<Validator<int>>());

      // Test their functionality
      expect(stringValidator.validate('test', mockContext), isNull);
      expect(intValidator.validate(null, mockContext), 'Required');
      expect(intValidator.validate(42, mockContext), isNull);
    });

    test('should work with SimpleValidator implementation', () {
      final validator = SimpleValidator<String>((value, context) {
        return value == null || value.isEmpty ? 'Required' : null;
      });

      expect(validator, isA<Validator<String>>());
      expect(validator.validate(null, mockContext), 'Required');
      expect(validator.validate('', mockContext), 'Required');
      expect(validator.validate('test', mockContext), isNull);
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockValidator<T> implements Validator<T> {
  String? Function(T? value, BuildContext context)? mockValidate;

  @override
  String? validate(T? value, BuildContext context) {
    return mockValidate?.call(value, context);
  }
}

class ConcreteValidator extends Validator<String> {
  const ConcreteValidator();

  @override
  String? validate(String? value, BuildContext context) {
    return null;
  }
}

class AnotherValidator extends Validator<int> {
  const AnotherValidator();

  @override
  String? validate(int? value, BuildContext context) {
    return value == null ? 'Required' : null;
  }
}
