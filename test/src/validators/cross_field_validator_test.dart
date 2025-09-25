import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:typed_form_fields/src/validators/cross_field_validator.dart';

class MockBuildContext extends Mock implements BuildContext {}

class TestCrossFieldValidator extends CrossFieldValidator<String> {
  const TestCrossFieldValidator({
    required super.dependentFields,
    this.validationResult,
  });

  final String? validationResult;

  @override
  String? validateWithDependencies(
    String? value,
    Map<String, dynamic> fieldValues,
    BuildContext context,
  ) {
    return validationResult;
  }
}

void main() {
  group('CrossFieldValidator', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    test('should store dependent fields correctly', () {
      // Arrange
      const dependentFields = ['field1', 'field2'];
      final validator = TestCrossFieldValidator(
        dependentFields: dependentFields,
      );

      // Assert
      expect(validator.dependentFields, dependentFields);
    });

    test('should throw UnsupportedError when validate is called directly', () {
      // Arrange
      final validator = TestCrossFieldValidator(
        dependentFields: ['field1'],
      );

      // Act & Assert
      expect(
        () => validator.validate('test', mockContext),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('should return validation result from validateWithDependencies', () {
      // Arrange
      const expectedError = 'Cross-field validation error';
      final validator = TestCrossFieldValidator(
        dependentFields: ['field1'],
        validationResult: expectedError,
      );

      // Act
      final result = validator.validateWithDependencies(
        'test',
        {'field1': 'value1'},
        mockContext,
      );

      // Assert
      expect(result, expectedError);
    });
  });

  group('FunctionCrossFieldValidator', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    test('should call validator function with correct parameters', () {
      // Arrange
      const testValue = 'test';
      const fieldValues = {'field1': 'value1', 'field2': 'value2'};
      const expectedError = 'Function validation error';

      String? validatorFunction(
        String? value,
        Map<String, dynamic> fieldValues,
        BuildContext context,
      ) {
        expect(value, testValue);
        expect(fieldValues, fieldValues);
        expect(context, mockContext);
        return expectedError;
      }

      final validator = FunctionCrossFieldValidator<String>(
        validator: validatorFunction,
        dependentFields: ['field1', 'field2'],
      );

      // Act
      final result = validator.validateWithDependencies(
        testValue,
        fieldValues,
        mockContext,
      );

      // Assert
      expect(result, expectedError);
    });

    test('should return null when validator function returns null', () {
      // Arrange
      final validator = FunctionCrossFieldValidator<String>(
        validator: (value, fieldValues, context) => null,
        dependentFields: ['field1'],
      );

      // Act
      final result = validator.validateWithDependencies(
        'test',
        {'field1': 'value1'},
        mockContext,
      );

      // Assert
      expect(result, null);
    });
  });

  group('CrossFieldValidators', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    group('matches', () {
      test('should return null when values match', () {
        // Arrange
        final validator =
            CrossFieldValidators.matches<String>('confirmPassword');

        // Act
        final result = validator.validateWithDependencies(
          'password123',
          {'confirmPassword': 'password123'},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return error when values do not match', () {
        // Arrange
        final validator =
            CrossFieldValidators.matches<String>('confirmPassword');

        // Act
        final result = validator.validateWithDependencies(
          'password123',
          {'confirmPassword': 'different'},
          mockContext,
        );

        // Assert
        expect(result, 'Fields do not match.');
      });

      test('should use custom error text', () {
        // Arrange
        const customError = 'Passwords must match';
        final validator = CrossFieldValidators.matches<String>(
          'confirmPassword',
          errorText: customError,
        );

        // Act
        final result = validator.validateWithDependencies(
          'password123',
          {'confirmPassword': 'different'},
          mockContext,
        );

        // Assert
        expect(result, customError);
      });

      test('should handle null values', () {
        // Arrange
        final validator =
            CrossFieldValidators.matches<String>('confirmPassword');

        // Act
        final result = validator.validateWithDependencies(
          null,
          {'confirmPassword': null},
          mockContext,
        );

        // Assert
        expect(result, null);
      });
    });

    group('differentFrom', () {
      test('should return null when values are different', () {
        // Arrange
        final validator =
            CrossFieldValidators.differentFrom<String>('oldPassword');

        // Act
        final result = validator.validateWithDependencies(
          'newPassword123',
          {'oldPassword': 'oldPassword123'},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return error when values are the same', () {
        // Arrange
        final validator =
            CrossFieldValidators.differentFrom<String>('oldPassword');

        // Act
        final result = validator.validateWithDependencies(
          'password123',
          {'oldPassword': 'password123'},
          mockContext,
        );

        // Assert
        expect(result, 'This field must be different from oldPassword.');
      });

      test('should use custom error text', () {
        // Arrange
        const customError = 'New password must be different';
        final validator = CrossFieldValidators.differentFrom<String>(
          'oldPassword',
          errorText: customError,
        );

        // Act
        final result = validator.validateWithDependencies(
          'password123',
          {'oldPassword': 'password123'},
          mockContext,
        );

        // Assert
        expect(result, customError);
      });
    });

    group('requiredWhen', () {
      test(
          'should return null when dependent field does not have required value',
          () {
        // Arrange
        final validator = CrossFieldValidators.requiredWhen<String>(
          'paymentMethod',
          'credit_card',
        );

        // Act
        final result = validator.validateWithDependencies(
          '',
          {'paymentMethod': 'cash'},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test(
          'should return null when dependent field has required value and current field has value',
          () {
        // Arrange
        final validator = CrossFieldValidators.requiredWhen<String>(
          'paymentMethod',
          'credit_card',
        );

        // Act
        final result = validator.validateWithDependencies(
          '1234567890123456',
          {'paymentMethod': 'credit_card'},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test(
          'should return error when dependent field has required value and current field is empty',
          () {
        // Arrange
        final validator = CrossFieldValidators.requiredWhen<String>(
          'paymentMethod',
          'credit_card',
        );

        // Act
        final result = validator.validateWithDependencies(
          '',
          {'paymentMethod': 'credit_card'},
          mockContext,
        );

        // Assert
        expect(result,
            'This field is required when paymentMethod is credit_card.');
      });

      test(
          'should return error when dependent field has required value and current field is null',
          () {
        // Arrange
        final validator = CrossFieldValidators.requiredWhen<String>(
          'paymentMethod',
          'credit_card',
        );

        // Act
        final result = validator.validateWithDependencies(
          null,
          {'paymentMethod': 'credit_card'},
          mockContext,
        );

        // Assert
        expect(result,
            'This field is required when paymentMethod is credit_card.');
      });

      test('should handle list values', () {
        // Arrange
        final validator = CrossFieldValidators.requiredWhen<List<String>>(
          'hasItems',
          true,
        );

        // Act
        final result = validator.validateWithDependencies(
          <String>[],
          {'hasItems': true},
          mockContext,
        );

        // Assert
        expect(result, 'This field is required when hasItems is true.');
      });

      test('should use custom error text', () {
        // Arrange
        const customError = 'Credit card number is required';
        final validator = CrossFieldValidators.requiredWhen<String>(
          'paymentMethod',
          'credit_card',
          errorText: customError,
        );

        // Act
        final result = validator.validateWithDependencies(
          '',
          {'paymentMethod': 'credit_card'},
          mockContext,
        );

        // Assert
        expect(result, customError);
      });
    });

    group('requiredWhenNotEmpty', () {
      test('should return null when dependent field is empty', () {
        // Arrange
        final validator =
            CrossFieldValidators.requiredWhenNotEmpty<String>('firstName');

        // Act
        final result = validator.validateWithDependencies(
          '',
          {'firstName': ''},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return null when dependent field is null', () {
        // Arrange
        final validator =
            CrossFieldValidators.requiredWhenNotEmpty<String>('firstName');

        // Act
        final result = validator.validateWithDependencies(
          '',
          {'firstName': null},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test(
          'should return null when dependent field is not empty and current field has value',
          () {
        // Arrange
        final validator =
            CrossFieldValidators.requiredWhenNotEmpty<String>('firstName');

        // Act
        final result = validator.validateWithDependencies(
          'Doe',
          {'firstName': 'John'},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test(
          'should return error when dependent field is not empty and current field is empty',
          () {
        // Arrange
        final validator =
            CrossFieldValidators.requiredWhenNotEmpty<String>('firstName');

        // Act
        final result = validator.validateWithDependencies(
          '',
          {'firstName': 'John'},
          mockContext,
        );

        // Assert
        expect(result, 'This field is required when firstName is provided.');
      });

      test('should handle list values for dependent field', () {
        // Arrange
        final validator =
            CrossFieldValidators.requiredWhenNotEmpty<String>('items');

        // Act
        final result = validator.validateWithDependencies(
          '',
          {
            'items': ['item1', 'item2']
          },
          mockContext,
        );

        // Assert
        expect(result, 'This field is required when items is provided.');
      });

      test('should use custom error text', () {
        // Arrange
        const customError = 'Last name is required when first name is provided';
        final validator = CrossFieldValidators.requiredWhenNotEmpty<String>(
          'firstName',
          errorText: customError,
        );

        // Act
        final result = validator.validateWithDependencies(
          '',
          {'firstName': 'John'},
          mockContext,
        );

        // Assert
        expect(result, customError);
      });
    });

    group('dateBefore', () {
      test('should return null when start date is before end date', () {
        // Arrange
        final validator = CrossFieldValidators.dateBefore('endDate');
        final startDate = DateTime(2023, 1, 1);
        final endDate = DateTime(2023, 12, 31);

        // Act
        final result = validator.validateWithDependencies(
          startDate,
          {'endDate': endDate},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return null when current date is null', () {
        // Arrange
        final validator = CrossFieldValidators.dateBefore('endDate');
        final endDate = DateTime(2023, 12, 31);

        // Act
        final result = validator.validateWithDependencies(
          null,
          {'endDate': endDate},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return null when end date is null', () {
        // Arrange
        final validator = CrossFieldValidators.dateBefore('endDate');
        final startDate = DateTime(2023, 1, 1);

        // Act
        final result = validator.validateWithDependencies(
          startDate,
          {'endDate': null},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return error when start date is after end date', () {
        // Arrange
        final validator = CrossFieldValidators.dateBefore('endDate');
        final startDate = DateTime(2023, 12, 31);
        final endDate = DateTime(2023, 1, 1);

        // Act
        final result = validator.validateWithDependencies(
          startDate,
          {'endDate': endDate},
          mockContext,
        );

        // Assert
        expect(result, 'Start date must be before end date.');
      });

      test('should return error when dates are the same', () {
        // Arrange
        final validator = CrossFieldValidators.dateBefore('endDate');
        final date = DateTime(2023, 6, 15);

        // Act
        final result = validator.validateWithDependencies(
          date,
          {'endDate': date},
          mockContext,
        );

        // Assert
        expect(result, 'Start date must be before end date.');
      });

      test('should use custom error text', () {
        // Arrange
        const customError = 'Check-in date must be before check-out date';
        final validator = CrossFieldValidators.dateBefore(
          'endDate',
          errorText: customError,
        );
        final startDate = DateTime(2023, 12, 31);
        final endDate = DateTime(2023, 1, 1);

        // Act
        final result = validator.validateWithDependencies(
          startDate,
          {'endDate': endDate},
          mockContext,
        );

        // Assert
        expect(result, customError);
      });
    });

    group('dateAfter', () {
      test('should return null when end date is after start date', () {
        // Arrange
        final validator = CrossFieldValidators.dateAfter('startDate');
        final startDate = DateTime(2023, 1, 1);
        final endDate = DateTime(2023, 12, 31);

        // Act
        final result = validator.validateWithDependencies(
          endDate,
          {'startDate': startDate},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return error when end date is before start date', () {
        // Arrange
        final validator = CrossFieldValidators.dateAfter('startDate');
        final startDate = DateTime(2023, 12, 31);
        final endDate = DateTime(2023, 1, 1);

        // Act
        final result = validator.validateWithDependencies(
          endDate,
          {'startDate': startDate},
          mockContext,
        );

        // Assert
        expect(result, 'End date must be after start date.');
      });

      test('should return error when dates are the same', () {
        // Arrange
        final validator = CrossFieldValidators.dateAfter('startDate');
        final date = DateTime(2023, 6, 15);

        // Act
        final result = validator.validateWithDependencies(
          date,
          {'startDate': date},
          mockContext,
        );

        // Assert
        expect(result, 'End date must be after start date.');
      });
    });

    group('greaterThan', () {
      test('should return null when value is greater than min field', () {
        // Arrange
        final validator = CrossFieldValidators.greaterThan('minValue');

        // Act
        final result = validator.validateWithDependencies(
          10,
          {'minValue': 5},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return null when current value is null', () {
        // Arrange
        final validator = CrossFieldValidators.greaterThan('minValue');

        // Act
        final result = validator.validateWithDependencies(
          null,
          {'minValue': 5},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return null when min value is null', () {
        // Arrange
        final validator = CrossFieldValidators.greaterThan('minValue');

        // Act
        final result = validator.validateWithDependencies(
          10,
          {'minValue': null},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return error when value is less than or equal to min field',
          () {
        // Arrange
        final validator = CrossFieldValidators.greaterThan('minValue');

        // Act
        final result = validator.validateWithDependencies(
          5,
          {'minValue': 5},
          mockContext,
        );

        // Assert
        expect(result, 'Value must be greater than minValue.');
      });

      test('should use custom error text', () {
        // Arrange
        const customError = 'Maximum must be greater than minimum';
        final validator = CrossFieldValidators.greaterThan(
          'minValue',
          errorText: customError,
        );

        // Act
        final result = validator.validateWithDependencies(
          5,
          {'minValue': 10},
          mockContext,
        );

        // Assert
        expect(result, customError);
      });
    });

    group('lessThan', () {
      test('should return null when value is less than max field', () {
        // Arrange
        final validator = CrossFieldValidators.lessThan('maxValue');

        // Act
        final result = validator.validateWithDependencies(
          5,
          {'maxValue': 10},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test(
          'should return error when value is greater than or equal to max field',
          () {
        // Arrange
        final validator = CrossFieldValidators.lessThan('maxValue');

        // Act
        final result = validator.validateWithDependencies(
          10,
          {'maxValue': 10},
          mockContext,
        );

        // Assert
        expect(result, 'Value must be less than maxValue.');
      });
    });

    group('sumCondition', () {
      test('should return null when sum condition is met', () {
        // Arrange
        final validator = CrossFieldValidators.sumCondition(
          ['field1', 'field2'],
          (sum) => sum == 15,
        );

        // Act
        final result = validator.validateWithDependencies(
          5,
          {'field1': 4, 'field2': 6},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return error when sum condition is not met', () {
        // Arrange
        final validator = CrossFieldValidators.sumCondition(
          ['field1', 'field2'],
          (sum) => sum == 20,
        );

        // Act
        final result = validator.validateWithDependencies(
          5,
          {'field1': 4, 'field2': 6},
          mockContext,
        );

        // Assert
        expect(result, 'Sum condition not met.');
      });

      test('should handle null values in other fields', () {
        // Arrange
        final validator = CrossFieldValidators.sumCondition(
          ['field1', 'field2'],
          (sum) => sum == 10,
        );

        // Act
        final result = validator.validateWithDependencies(
          10,
          {'field1': null, 'field2': null},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return null when current value is null', () {
        // Arrange
        final validator = CrossFieldValidators.sumCondition(
          ['field1', 'field2'],
          (sum) => sum == 10,
        );

        // Act
        final result = validator.validateWithDependencies(
          null,
          {'field1': 5, 'field2': 5},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should use custom error text', () {
        // Arrange
        const customError = 'Total must equal 100%';
        final validator = CrossFieldValidators.sumCondition(
          ['field1', 'field2'],
          (sum) => sum == 100,
          errorText: customError,
        );

        // Act
        final result = validator.validateWithDependencies(
          30,
          {'field1': 20, 'field2': 30},
          mockContext,
        );

        // Assert
        expect(result, customError);
      });
    });

    group('atLeastOneRequired', () {
      test('should return null when current field has value', () {
        // Arrange
        final validator = CrossFieldValidators.atLeastOneRequired<String>(
          ['field1', 'field2'],
        );

        // Act
        final result = validator.validateWithDependencies(
          'value',
          {'field1': '', 'field2': ''},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return null when another field has value', () {
        // Arrange
        final validator = CrossFieldValidators.atLeastOneRequired<String>(
          ['field1', 'field2'],
        );

        // Act
        final result = validator.validateWithDependencies(
          '',
          {'field1': 'value', 'field2': ''},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should return error when no fields have values', () {
        // Arrange
        final validator = CrossFieldValidators.atLeastOneRequired<String>(
          ['field1', 'field2'],
        );

        // Act
        final result = validator.validateWithDependencies(
          '',
          {'field1': '', 'field2': ''},
          mockContext,
        );

        // Assert
        expect(result, 'At least one field in this group is required.');
      });

      test('should handle null values', () {
        // Arrange
        final validator = CrossFieldValidators.atLeastOneRequired<String>(
          ['field1', 'field2'],
        );

        // Act
        final result = validator.validateWithDependencies(
          null,
          {'field1': null, 'field2': null},
          mockContext,
        );

        // Assert
        expect(result, 'At least one field in this group is required.');
      });

      test('should handle list values', () {
        // Arrange
        final validator = CrossFieldValidators.atLeastOneRequired<List<String>>(
          ['field1', 'field2'],
        );

        // Act
        final result = validator.validateWithDependencies(
          ['item'],
          {'field1': <String>[], 'field2': <String>[]},
          mockContext,
        );

        // Assert
        expect(result, null);
      });

      test('should use custom error text', () {
        // Arrange
        const customError = 'Please provide at least one contact method';
        final validator = CrossFieldValidators.atLeastOneRequired<String>(
          ['email', 'phone'],
          errorText: customError,
        );

        // Act
        final result = validator.validateWithDependencies(
          '',
          {'email': '', 'phone': ''},
          mockContext,
        );

        // Assert
        expect(result, customError);
      });
    });
  });
}
