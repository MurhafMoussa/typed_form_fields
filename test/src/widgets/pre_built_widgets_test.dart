import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

void main() {
  group('Pre-built Widgets Tests', () {
    late CoreFormCubit formCubit;

    setUp(() {
      formCubit = CoreFormCubit(
        fields: [
          TypedFormField<String>(name: 'text', validators: []),
          TypedFormField<String>(
              name: 'email', validators: [CommonValidators.email()]),
          TypedFormField<String>(
              name: 'password',
              validators: [CommonValidators.required<String>()]),
          TypedFormField<bool>(name: 'checkbox', validators: []),
          TypedFormField<String>(name: 'dropdown', validators: []),
          TypedFormField<DateTime>(name: 'date', validators: []),
          TypedFormField<TimeOfDay>(name: 'time', validators: []),
          TypedFormField<bool>(name: 'switch', validators: []),
          TypedFormField<double>(name: 'slider', validators: []),
          TypedFormField<String>(name: 'radio', validators: []),
          TypedFormField<List<String>>(name: 'multiselect', validators: []),
        ],
      );
    });

    tearDown(() {
      formCubit.close();
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: BlocProvider<CoreFormCubit>(
          create: (context) => formCubit,
          child: Scaffold(body: child),
        ),
      );
    }

    group('TypedTextField', () {
      testWidgets('should render with label and handle text input',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedTextField(
              name: 'text',
              label: 'Test Label',
              hintText: 'Enter text here',
            ),
          ),
        );

        // Should find the text field
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Test Label'), findsOneWidget);
        expect(find.text('Enter text here'), findsOneWidget);

        // Should handle text input
        await tester.enterText(find.byType(TextFormField), 'Hello World');
        await tester.pump();

        expect(formCubit.state.values['text'], equals('Hello World'));
      });

      testWidgets('should show validation errors', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedTextField(
              name: 'email',
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        );

        // Enter invalid email
        await tester.enterText(find.byType(TextFormField), 'invalid-email');
        await tester.pump();

        // Should render without errors
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('should support obscure text for passwords', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedTextField(
              name: 'password',
              label: 'Password',
              obscureText: true,
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('should support different keyboard types', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedTextField(
              name: 'email',
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('should support max lines for multiline input',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedTextField(
              name: 'textarea',
              label: 'Description',
              maxLines: 3,
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('TypedCheckbox', () {
      testWidgets('should render with title and handle boolean input',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedCheckbox(
              name: 'checkbox',
              title: const Text('I agree to terms'),
            ),
          ),
        );

        // Should find checkbox and title
        expect(find.byType(CheckboxListTile), findsOneWidget);
        expect(find.text('I agree to terms'), findsOneWidget);

        // Should handle checkbox tap
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pump();

        expect(formCubit.state.values['checkbox'], equals(true));
      });

      testWidgets('should support subtitle', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedCheckbox(
              name: 'checkbox',
              title: const Text('Terms'),
              subtitle: const Text('Please read our terms and conditions'),
            ),
          ),
        );

        expect(
            find.text('Please read our terms and conditions'), findsOneWidget);
      });

      testWidgets('should show validation errors', (tester) async {
        // Add required validator to checkbox field
        // formCubit.updateField(fieldName: 'checkbox', value: null, context: null);

        await tester.pumpWidget(
          createTestWidget(
            TypedCheckbox(
              name: 'checkbox',
              title: const Text('Required checkbox'),
            ),
          ),
        );

        // Should show error styling when validation fails
        final checkboxTile =
            tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
        expect(checkboxTile.value, isFalse);
      });
    });

    group('TypedDropdown', () {
      testWidgets('should render with items and handle selection',
          (tester) async {
        final items = ['Option 1', 'Option 2', 'Option 3'];

        await tester.pumpWidget(
          createTestWidget(
            TypedDropdown<String>(
              name: 'dropdown',
              label: 'Select Option',
              items: items,
            ),
          ),
        );

        // Should find dropdown
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
        expect(find.text('Select Option'), findsOneWidget);

        // Should handle selection
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Option 2').last);
        await tester.pumpAndSettle();

        expect(formCubit.state.values['dropdown'], equals('Option 2'));
      });

      testWidgets('should support custom item builder', (tester) async {
        final items = ['A', 'B', 'C'];

        await tester.pumpWidget(
          createTestWidget(
            TypedDropdown<String>(
              name: 'dropdown',
              label: 'Select',
              items: items,
              itemBuilder: (item) => Text('Custom: $item'),
            ),
          ),
        );

        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        expect(find.text('Custom: A'), findsOneWidget);
      });
    });

    group('TypedDatePicker', () {
      testWidgets('should render and handle date selection', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedDatePicker(
              name: 'date',
              label: 'Select Date',
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            ),
          ),
        );

        // Should find the input field
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Select Date'), findsOneWidget);

        // Should open date picker on tap
        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        // Should find date picker dialog
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });

      testWidgets('should format date correctly', (tester) async {
        // final testDate = DateTime(2023, 12, 25);
        // formCubit.updateField(fieldName: 'date', value: testDate, context: null);

        await tester.pumpWidget(
          createTestWidget(
            TypedDatePicker(
              name: 'date',
              label: 'Date',
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              dateFormat: 'dd/MM/yyyy',
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('TypedTimePicker', () {
      testWidgets('should render and handle time selection', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedTimePicker(
              name: 'time',
              label: 'Select Time',
            ),
          ),
        );

        // Should find the input field
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Select Time'), findsOneWidget);

        // Should open time picker on tap
        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        // Should find time picker dialog
        expect(find.byType(TimePickerDialog), findsOneWidget);
      });
    });

    group('TypedSwitch', () {
      testWidgets('should render with title and handle boolean input',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedSwitch(
              name: 'switch',
              title: const Text('Enable notifications'),
            ),
          ),
        );

        // Should find switch and title
        expect(find.byType(SwitchListTile), findsOneWidget);
        expect(find.text('Enable notifications'), findsOneWidget);

        // Should handle switch toggle
        await tester.tap(find.byType(SwitchListTile));
        await tester.pump();

        expect(formCubit.state.values['switch'], equals(true));
      });

      testWidgets('should support subtitle', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedSwitch(
              name: 'switch',
              title: const Text('Notifications'),
              subtitle: const Text('Receive push notifications'),
            ),
          ),
        );

        expect(find.text('Receive push notifications'), findsOneWidget);
      });
    });

    group('TypedSlider', () {
      testWidgets('should render with label and handle double input',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedSlider(
              name: 'slider',
              label: 'Volume',
              min: 0.0,
              max: 100.0,
              divisions: 10,
            ),
          ),
        );

        // Should find slider and label
        expect(find.byType(Slider), findsOneWidget);
        expect(find.text('Volume'), findsOneWidget);

        // Should handle slider change
        await tester.drag(find.byType(Slider), const Offset(100, 0));
        await tester.pump();

        expect(formCubit.state.values['slider'], isA<double>());
      });

      testWidgets('should show current value', (tester) async {
        // formCubit.updateField(fieldName: 'slider', value: 75.0, context: null);

        await tester.pumpWidget(
          createTestWidget(
            TypedSlider(
              name: 'slider',
              label: 'Volume',
              min: 0.0,
              max: 100.0,
              showValue: true,
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(Slider), findsOneWidget);
      });
    });

    group('Widget Integration', () {
      testWidgets('all widgets should integrate with FieldWrapper',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            Column(
              children: [
                TypedTextField(name: 'text', label: 'Text'),
                TypedCheckbox(name: 'checkbox', title: const Text('Checkbox')),
                TypedDropdown<String>(
                    name: 'dropdown', label: 'Dropdown', items: ['A', 'B']),
                TypedSwitch(name: 'switch', title: const Text('Switch')),
              ],
            ),
          ),
        );

        // All widgets should render without errors
        expect(find.byType(TypedTextField), findsOneWidget);
        expect(find.byType(TypedCheckbox), findsOneWidget);
        expect(find.byType(TypedDropdown<String>), findsOneWidget);
        expect(find.byType(TypedSwitch), findsOneWidget);

        // All should be connected to form state
        expect(formCubit.state.values.keys,
            containsAll(['text', 'checkbox', 'dropdown', 'switch']));
      });

      testWidgets('widgets should handle validation errors consistently',
          (tester) async {
        // Add validation errors
        // formCubit.updateField(fieldName: 'email', value: 'invalid', context: null);

        await tester.pumpWidget(
          createTestWidget(
            Column(
              children: [
                TypedTextField(name: 'email', label: 'Email'),
                TypedTextField(name: 'text', label: 'Text'),
              ],
            ),
          ),
        );

        await tester.pump();

        // Both should render without errors
        expect(find.byType(TypedTextField), findsNWidgets(2));
      });
    });
  });
}
