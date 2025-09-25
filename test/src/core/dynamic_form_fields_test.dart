import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

void main() {
  group('Dynamic Form Fields', () {
    late BuildContext context;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('should add a new field to existing form', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: '',
          ),
        ],
      );

      // Initial state should have only email field
      expect(formCubit.state.values.keys, contains('email'));
      expect(formCubit.state.values.keys, hasLength(1));

      // Add a new field dynamically
      formCubit.addField<String>(
        field: TypedFormField<String>(
          name: 'phone',
          validators: [CommonValidators.required<String>()],
          initialValue: '',
        ),
        context: context,
      );

      // Should now have both fields
      expect(formCubit.state.values.keys, containsAll(['email', 'phone']));
      expect(formCubit.state.values.keys, hasLength(2));
      expect(formCubit.state.fieldTypes['phone'], equals(String));

      formCubit.close();
    });

    testWidgets('should add multiple fields at once', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: '',
          ),
        ],
      );

      // Add multiple fields at once
      formCubit.addFields(
        fields: [
          TypedFormField<String>(
            name: 'phone',
            validators: [CommonValidators.required<String>()],
            initialValue: '',
          ),
          TypedFormField<int>(
            name: 'age',
            validators: [CommonValidators.required<int>()],
            initialValue: 0,
          ),
          TypedFormField<bool>(
            name: 'subscribe',
            validators: [],
            initialValue: false,
          ),
        ],
        context: context,
      );

      // Should have all fields
      expect(formCubit.state.values.keys,
          containsAll(['email', 'phone', 'age', 'subscribe']));
      expect(formCubit.state.values.keys, hasLength(4));
      expect(formCubit.state.fieldTypes['phone'], equals(String));
      expect(formCubit.state.fieldTypes['age'], equals(int));
      expect(formCubit.state.fieldTypes['subscribe'], equals(bool));

      formCubit.close();
    });

    testWidgets('should handle adding field with existing name',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: 'original@example.com',
          ),
        ],
      );

      // Try to add field with existing name
      try {
        formCubit.addField<String>(
          field: TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.email()],
            initialValue: 'new@example.com',
          ),
          context: context,
        );
        fail('Expected FormFieldError to be thrown');
      } catch (e) {
        expect(e, isA<FormFieldError>());
        final error = e as FormFieldError;
        expect(error.fieldName, equals('email'));
        expect(error.message, contains('already exists'));
        expect(error.suggestion, contains('Use updateFieldValidators'));
      }

      formCubit.close();
    });

    testWidgets('should remove an existing field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: '',
          ),
          TypedFormField<String>(
            name: 'phone',
            validators: [CommonValidators.required<String>()],
            initialValue: '',
          ),
        ],
      );

      // Initial state should have both fields
      expect(formCubit.state.values.keys, containsAll(['email', 'phone']));
      expect(formCubit.state.values.keys, hasLength(2));

      // Remove phone field
      formCubit.removeField('phone', context: context);

      // Should only have email field
      expect(formCubit.state.values.keys, contains('email'));
      expect(formCubit.state.values.keys, isNot(contains('phone')));
      expect(formCubit.state.values.keys, hasLength(1));
      expect(formCubit.state.fieldTypes.keys, isNot(contains('phone')));

      formCubit.close();
    });

    testWidgets('should handle removing non-existent field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: '',
          ),
        ],
      );

      // Try to remove non-existent field
      try {
        formCubit.removeField('nonexistent', context: context);
        fail('Expected FormFieldError to be thrown');
      } catch (e) {
        expect(e, isA<FormFieldError>());
        final error = e as FormFieldError;
        expect(error.fieldName, equals('nonexistent'));
        expect(error.message, contains('does not exist'));
        expect(error.suggestion, contains('Available fields:'));
      }

      formCubit.close();
    });

    testWidgets('should maintain form validity when adding/removing fields',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: 'test@example.com',
          ),
        ],
      );

      // Update the field to trigger validation (simulate user interaction)
      formCubit.updateField<String>(
        fieldName: 'email',
        value: 'test@example.com',
        context: context,
      );

      // Form should be valid after user interaction
      expect(formCubit.state.isValid, isTrue);

      // Add required field without value
      formCubit.addField<String>(
        field: TypedFormField<String>(
          name: 'phone',
          validators: [CommonValidators.required<String>()],
          initialValue: '',
        ),
        context: context,
      );

      // Form should now be invalid
      expect(formCubit.state.isValid, isFalse);

      // Remove the required field
      formCubit.removeField('phone', context: context);

      // Form should be valid again
      expect(formCubit.state.isValid, isTrue);

      formCubit.close();
    });

    testWidgets('should preserve existing field values when adding new fields',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: '',
          ),
        ],
      );

      // Set email value
      formCubit.updateField<String>(
        fieldName: 'email',
        value: 'test@example.com',
        context: context,
      );

      expect(formCubit.state.values['email'], equals('test@example.com'));

      // Add new field
      formCubit.addField<String>(
        field: TypedFormField<String>(
          name: 'phone',
          validators: [CommonValidators.required<String>()],
          initialValue: '',
        ),
        context: context,
      );

      // Email value should be preserved
      expect(formCubit.state.values['email'], equals('test@example.com'));
      expect(formCubit.state.values['phone'], equals(''));

      formCubit.close();
    });
  });

  group('Bulk Dynamic Form Fields', () {
    testWidgets('should add multiple fields at once', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: 'test@example.com',
          ),
        ],
      );

      final context = tester.element(find.byType(Container));

      // Add multiple fields
      formCubit.addFields(
        fields: [
          TypedFormField<String>(
            name: 'phone',
            validators: [CommonValidators.required<String>()],
            initialValue: '123-456-7890',
          ),
          TypedFormField<int>(
            name: 'age',
            validators: [CommonValidators.required<int>()],
            initialValue: 25,
          ),
        ],
        context: context,
      );

      // Verify all fields exist
      expect(formCubit.getValue<String>('email'), 'test@example.com');
      expect(formCubit.getValue<String>('phone'), '123-456-7890');
      expect(formCubit.getValue<int>('age'), 25);

      formCubit.close();
    });

    testWidgets(
        'should throw FormFieldError when adding fields with existing names',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: 'test@example.com',
          ),
        ],
      );

      final context = tester.element(find.byType(Container));

      // Try to add fields with existing name - This covers line 492
      try {
        formCubit.addFields(
          fields: [
            TypedFormField<String>(
              name: 'email', // This already exists
              validators: [CommonValidators.required<String>()],
              initialValue: 'new@example.com',
            ),
            TypedFormField<String>(
              name: 'phone',
              validators: [CommonValidators.required<String>()],
              initialValue: '123-456-7890',
            ),
          ],
          context: context,
        );
        fail('Expected FormFieldError to be thrown');
      } catch (e) {
        expect(e, isA<FormFieldError>());
        final error = e as FormFieldError;
        expect(error.fieldName, equals('email'));
        expect(error.message, contains('already exists'));
      }

      formCubit.close();
    });

    testWidgets('should remove multiple fields at once', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: 'test@example.com',
          ),
          TypedFormField<String>(
            name: 'phone',
            validators: [CommonValidators.required<String>()],
            initialValue: '123-456-7890',
          ),
          TypedFormField<int>(
            name: 'age',
            validators: [CommonValidators.required<int>()],
            initialValue: 25,
          ),
        ],
      );

      final context = tester.element(find.byType(Container));

      // Update fields to trigger validation
      formCubit.updateField<String>(
        fieldName: 'email',
        value: 'test@example.com',
        context: context,
      );

      // Remove multiple fields - This covers lines 595-624
      formCubit.removeFields(['phone', 'age'], context: context);

      // Verify fields are removed
      expect(() => formCubit.getValue<String>('phone'),
          throwsA(isA<FormFieldError>()));
      expect(
          () => formCubit.getValue<int>('age'), throwsA(isA<FormFieldError>()));

      // Verify remaining field still exists
      expect(formCubit.getValue<String>('email'), 'test@example.com');

      formCubit.close();
    });

    testWidgets('should throw FormFieldError when removing non-existent fields',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Container();
            },
          ),
        ),
      );

      final formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [CommonValidators.required<String>()],
            initialValue: 'test@example.com',
          ),
        ],
      );

      final context = tester.element(find.byType(Container));

      // Try to remove non-existent fields - This covers lines 581-589
      try {
        formCubit
            .removeFields(['nonexistent1', 'nonexistent2'], context: context);
        fail('Expected FormFieldError to be thrown');
      } catch (e) {
        expect(e, isA<FormFieldError>());
        final error = e as FormFieldError;
        expect(error.fieldName, equals('nonexistent1'));
        expect(error.message, contains('does not exist'));
      }

      formCubit.close();
    });
  });
}

// FormFieldError is now exported from the main library

// Dynamic form field methods are now part of CoreFormCubit class
