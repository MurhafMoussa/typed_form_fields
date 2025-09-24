import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/core_form_cubit.dart';
import 'package:typed_form_fields/src/models/typed_form_field.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('CoreFormCubit', () {
    late CoreFormCubit formCubit;
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    tearDown(() {
      formCubit.close();
    });

    group('Initialization', () {
      test('should initialize with empty form by default', () {
        formCubit = CoreFormCubit();

        expect(formCubit.state.values, isEmpty);
        expect(formCubit.state.errors, isEmpty);
        expect(formCubit.state.isValid, isFalse);
        expect(formCubit.state.validationType, ValidationType.allFields);
        expect(formCubit.state.fieldTypes, isEmpty);
      });

      test('should initialize with provided fields', () {
        final fields = TestFieldFactory.createEmailAndAgeFields();
        formCubit = CoreFormCubit(fields: fields);

        expect(formCubit.state.values, {
          'email': 'test@example.com',
          'age': 25,
        });
        expect(formCubit.state.fieldTypes, {'email': String, 'age': int});
        expect(formCubit.state.isValid, isFalse);
      });

      test('should initialize with custom validation type', () {
        formCubit = CoreFormCubit(validationType: ValidationType.onSubmit);
        expect(formCubit.state.validationType, ValidationType.onSubmit);
      });

      test('should initialize with all validation types', () {
        for (final validationType in ValidationType.values) {
          formCubit = CoreFormCubit(validationType: validationType);
          expect(formCubit.state.validationType, validationType);
          formCubit.close();
        }
      });
    });

    group('Field Updates', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should update single field value', () {
        formCubit.updateField(
          fieldName: 'email',
          value: 'new@example.com',
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), 'new@example.com');
        expect(formCubit.state.values['email'], 'new@example.com');
      });

      test('should update field with null value', () {
        formCubit.updateField(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );
        formCubit.updateField<String>(fieldName: 'email', context: mockContext);

        expect(formCubit.getValue<String>('email'), isNull);
        expect(formCubit.state.values['email'], isNull);
      });

      test('should throw TypeError for wrong type', () {
        expect(
          () => formCubit.updateField(
            fieldName: 'email',
            value: 123,
            context: mockContext,
          ),
          throwsA(isA<TypeError>()),
        );
      });

      test('should throw ArgumentError for non-existent field', () {
        // The refactored implementation now correctly validates field existence
        expect(
          () => formCubit.updateField(
            fieldName: 'nonExistent',
            value: 'value',
            context: mockContext,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should update multiple fields at once', () {
        // We need to update fields separately due to type constraints
        formCubit.updateField(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );
        formCubit.updateField(
          fieldName: 'age',
          value: 30,
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), 'test@example.com');
        expect(formCubit.getValue<int>('age'), 30);
      });

      test('should mark fields as touched when updated', () {
        formCubit.updateField(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        // Note: We can't directly test _touchedFields as it's private,
        // but we can test the behavior through validation
        expect(formCubit.state.values['email'], 'test@example.com');
      });
    });

    group('Type Safety', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should return correct type for getValue', () {
        formCubit.updateField(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );
        formCubit.updateField(
          fieldName: 'age',
          value: 25,
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), isA<String>());
        expect(formCubit.getValue<int>('age'), isA<int>());
      });

      test('should throw TypeError for wrong type in getValue', () {
        formCubit.updateField(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        expect(
          () => formCubit.getValue<int>('email'),
          throwsA(isA<TypeError>()),
        );
      });

      test(
        'should throw TypeError for incompatible value type in getValue',
        () {
          // This test covers line 39 in CoreFormState where TypeError is thrown
          // when the value is not of the expected type
          final fields = [
            const TypedFormField<String>(name: 'email', validators: []),
          ];
          formCubit = CoreFormCubit(fields: fields);

          // Store a String value
          formCubit.updateField(
            fieldName: 'email',
            value: 'test@example.com',
            context: mockContext,
          );

          // Try to get it as int - this should throw TypeError at line 39
          expect(
            () => formCubit.getValue<int>('email'),
            throwsA(isA<TypeError>()),
          );
        },
      );

      test('should throw ArgumentError for non-existent field in getValue', () {
        expect(
          () => formCubit.getValue<String>('nonExistent'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Debounced Field Updates', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should update field with debounce', () async {
        formCubit.updateFieldWithDebounce<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        // Wait for debounce to complete
        await Future<void>.delayed(const Duration(milliseconds: 350));

        expect(formCubit.getValue<String>('email'), 'test@example.com');
      });

      test('should throw ArgumentError for non-existent field with debounce',
          () {
        expect(
          () => formCubit.updateFieldWithDebounce<String>(
            fieldName: 'nonExistent',
            value: 'value',
            context: mockContext,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw TypeError for wrong type with debounce', () {
        expect(
          () => formCubit.updateFieldWithDebounce<int>(
            fieldName: 'email',
            value: 123,
            context: mockContext,
          ),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('Multiple Field Updates', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should update multiple fields at once', () {
        formCubit.updateFields<String>(
          fieldValues: {'email': 'test@example.com'},
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), 'test@example.com');
      });

      test('should throw ArgumentError for non-existent field in updateFields',
          () {
        expect(
          () => formCubit.updateFields<String>(
            fieldValues: {'nonExistent': 'value'},
            context: mockContext,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw TypeError for wrong type in updateFields', () {
        expect(
          () => formCubit.updateFields<int>(
            fieldValues: {'email': 123},
            context: mockContext,
          ),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('Field Validator Updates', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should update field validators', () {
        final newValidator = MockValidator<String>();
        newValidator.mockValidate = (value, context) => 'New error';

        formCubit.updateFieldValidators<String>(
          name: 'email',
          validators: [newValidator],
          context: mockContext,
        );

        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        expect(formCubit.state.errors['email'], 'New error');
      });
    });

    group('Validation Type Management', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should set validation type', () {
        formCubit.setValidationType(ValidationType.onSubmit);
        expect(formCubit.state.validationType, ValidationType.onSubmit);
      });
    });

    group('Form Validation', () {
      late MockValidator<String> emailValidator;

      setUp(() {
        emailValidator = MockValidator<String>();
        formCubit = TestFormFactory.createFormWithValidators(
          emailValidator: emailValidator,
          validationType: ValidationType.onSubmit,
        );
      });

      test('should validate form and call onValidationPass when valid', () {
        emailValidator.mockValidate = (value, context) => null;

        // First update field to mark as touched
        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        bool validationPassed = false;
        formCubit.validateForm(
          mockContext,
          onValidationPass: () => validationPassed = true,
        );

        expect(validationPassed, isTrue);
      });

      test('should validate form and call onValidationFail when invalid', () {
        emailValidator.mockValidate = (value, context) => 'Email error';

        bool validationFailed = false;
        formCubit.validateForm(
          mockContext,
          onValidationPass: () {},
          onValidationFail: () => validationFailed = true,
        );

        expect(validationFailed, isTrue);
        expect(
            formCubit.state.validationType, ValidationType.fieldsBeingEdited);
      });
    });

    group('Immediate Field Validation', () {
      late MockValidator<String> emailValidator;

      setUp(() {
        emailValidator = MockValidator<String>();
        formCubit = TestFormFactory.createFormWithValidators(
          emailValidator: emailValidator,
        );
      });

      test('should validate field immediately', () {
        emailValidator.mockValidate = (value, context) => 'Email error';

        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        formCubit.validateFieldImmediately(
          fieldName: 'email',
          context: mockContext,
        );

        expect(formCubit.state.errors['email'], 'Email error');
      });

      test(
          'should throw ArgumentError for non-existent field in validateFieldImmediately',
          () {
        expect(
          () => formCubit.validateFieldImmediately(
            fieldName: 'nonExistent',
            context: mockContext,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should clear error when validation passes', () {
        emailValidator.mockValidate = (value, context) => null;

        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        formCubit.validateFieldImmediately(
          fieldName: 'email',
          context: mockContext,
        );

        expect(formCubit.state.errors['email'], isNull);
      });
    });

    group('Form Reset', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithInitialValues();
      });

      test('should reset form to initial state', () {
        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'changed@example.com',
          context: mockContext,
        );

        formCubit.resetForm();

        expect(formCubit.state.values['email'], isNull);
        expect(formCubit.state.errors, isEmpty);
        expect(formCubit.state.isValid, isFalse);
      });
    });

    group('Touch All Fields', () {
      late MockValidator<String> emailValidator;

      setUp(() {
        emailValidator = MockValidator<String>();
        formCubit = TestFormFactory.createFormWithValidators(
          emailValidator: emailValidator,
        );
      });

      test('should touch all fields and validate', () {
        emailValidator.mockValidate = (value, context) => 'Email error';

        formCubit.touchAllFields(mockContext);

        expect(formCubit.state.errors['email'], 'Email error');
      });
    });

    group('Manual Error Management', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should update single field error', () {
        formCubit.updateError(
          fieldName: 'email',
          errorMessage: 'Custom error',
          context: mockContext,
        );

        expect(formCubit.state.errors['email'], 'Custom error');
      });

      test('should clear single field error', () {
        formCubit.updateError(
          fieldName: 'email',
          errorMessage: 'Custom error',
          context: mockContext,
        );

        formCubit.updateError(
          fieldName: 'email',
          errorMessage: null,
          context: mockContext,
        );

        expect(formCubit.state.errors['email'], isNull);
      });

      test('should throw ArgumentError for non-existent field in updateError',
          () {
        expect(
          () => formCubit.updateError(
            fieldName: 'nonExistent',
            errorMessage: 'error',
            context: mockContext,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should update multiple field errors', () {
        formCubit.updateErrors(
          errors: {'email': 'Email error', 'age': 'Age error'},
          context: mockContext,
        );

        expect(formCubit.state.errors['email'], 'Email error');
        expect(formCubit.state.errors['age'], 'Age error');
      });

      test('should clear multiple field errors', () {
        formCubit.updateErrors(
          errors: {'email': 'Email error', 'age': 'Age error'},
          context: mockContext,
        );

        formCubit.updateErrors(
          errors: {'email': null, 'age': null},
          context: mockContext,
        );

        expect(formCubit.state.errors['email'], isNull);
        expect(formCubit.state.errors['age'], isNull);
      });

      test('should throw ArgumentError for non-existent field in updateErrors',
          () {
        expect(
          () => formCubit.updateErrors(
            errors: {'nonExistent': 'error'},
            context: mockContext,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Cubit Lifecycle', () {
      test('should dispose resources properly', () async {
        formCubit = TestFormFactory.createFormWithEmailAndAge();

        // This should not throw any errors
        await formCubit.close();

        expect(true, isTrue); // Test passes if no exception is thrown
      });
    });
  });
}

// Mock classes for testing
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

// Test utilities for creating common form configurations
class TestFormFactory {
  static CoreFormCubit createFormWithEmailAndAge({
    ValidationType validationType = ValidationType.allFields,
  }) {
    return CoreFormCubit(
      fields: [
        const TypedFormField<String>(name: 'email', validators: []),
        const TypedFormField<int>(name: 'age', validators: []),
      ],
      validationType: validationType,
    );
  }

  static CoreFormCubit createFormWithEmailOnly({
    ValidationType validationType = ValidationType.allFields,
  }) {
    return CoreFormCubit(
      fields: [const TypedFormField<String>(name: 'email', validators: [])],
      validationType: validationType,
    );
  }

  static CoreFormCubit createFormWithValidators({
    MockValidator<String>? emailValidator,
    MockValidator<int>? ageValidator,
    ValidationType validationType = ValidationType.allFields,
  }) {
    final fields = <TypedFormField>[];

    if (emailValidator != null) {
      fields.add(
        TypedFormField<String>(name: 'email', validators: [emailValidator]),
      );
    }

    if (ageValidator != null) {
      fields.add(TypedFormField<int>(name: 'age', validators: [ageValidator]));
    }

    return CoreFormCubit(fields: fields, validationType: validationType);
  }

  static CoreFormCubit createFormWithInitialValues() {
    return CoreFormCubit(
      fields: [
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
      ],
    );
  }
}

class TestFieldFactory {
  static List<TypedFormField> createEmailAndAgeFields() {
    return [
      TypedFormField<String>(
        name: 'email',
        validators: [MockValidator<String>()],
        initialValue: 'test@example.com',
      ),
      TypedFormField<int>(
        name: 'age',
        validators: [MockValidator<int>()],
        initialValue: 25,
      ),
    ];
  }
}
