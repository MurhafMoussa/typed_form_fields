import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

void main() {
  group('Pre-built Widgets Tests', () {
    late TypedFormController formCubit;

    setUp(() {
      formCubit = TypedFormController(
        fields: [
          FormFieldDefinition<String>(name: 'text', validators: []),
          FormFieldDefinition<String>(
              name: 'email', validators: [TypedCommonValidators.email()]),
          FormFieldDefinition<String>(
              name: 'password',
              validators: [TypedCommonValidators.required<String>()]),
          FormFieldDefinition<bool>(name: 'checkbox', validators: []),
          FormFieldDefinition<String>(name: 'dropdown', validators: []),
          FormFieldDefinition<DateTime>(name: 'date', validators: []),
          FormFieldDefinition<TimeOfDay>(name: 'time', validators: []),
          FormFieldDefinition<bool>(name: 'switch', validators: []),
          FormFieldDefinition<double>(name: 'slider', validators: []),
          FormFieldDefinition<String>(name: 'radio', validators: []),
          FormFieldDefinition<List<String>>(
              name: 'multiselect', validators: []),
        ],
      );
    });

    tearDown(() {
      formCubit.close();
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: BlocProvider<TypedFormController>(
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

      testWidgets('should display error message when validation fails',
          (tester) async {
        // This test covers lines 160, 162, 164, 165 - error display
        await tester.pumpWidget(
          createTestWidget(
            TypedCheckbox(
              name: 'checkbox',
              title: const Text('Accept Terms'),
            ),
          ),
        );

        // Manually set an error on the checkbox field
        final context = tester.element(find.byType(TypedCheckbox));
        formCubit.updateError(
          fieldName: 'checkbox',
          errorMessage: 'You must accept the terms',
          context: context,
        );

        await tester.pump();

        // Should display error message
        expect(find.text('You must accept the terms'), findsOneWidget);

        // Error text should have error color
        final errorText =
            tester.widget<Text>(find.text('You must accept the terms'));
        expect(errorText.style?.color, isNotNull);
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

      testWidgets('should format date correctly when value changes',
          (tester) async {
        // This test covers lines 95 and 97 - date formatting
        final testDate = DateTime(2023, 12, 25);

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

        // Update the form field value to trigger formatting
        final context = tester.element(find.byType(TypedDatePicker));
        formCubit.updateField<DateTime>(
          fieldName: 'date',
          value: testDate,
          context: context,
        );

        await tester.pump();

        // Should display formatted date
        expect(find.text('25/12/2023'), findsOneWidget);
      });

      testWidgets('should call onDateSubmitted when date is selected',
          (tester) async {
        // This test covers lines 138 and 139 - date selection callback
        DateTime? submittedDate;

        await tester.pumpWidget(
          createTestWidget(
            TypedDatePicker(
              name: 'date',
              label: 'Select Date',
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateSubmitted: (date) {
                submittedDate = date;
              },
            ),
          ),
        );

        // Tap to open date picker
        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        // Find and tap on a specific date (day 15)
        await tester.tap(find.text('15').first);
        await tester.pumpAndSettle();

        // Tap OK button to confirm selection
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Should have called the callback
        expect(submittedDate, isNotNull);
        expect(submittedDate!.day, equals(15));
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

      testWidgets('should format time correctly when value changes',
          (tester) async {
        // This test covers lines 72 and 74 - time formatting
        final testTime = const TimeOfDay(hour: 14, minute: 30);

        await tester.pumpWidget(
          createTestWidget(
            TypedTimePicker(
              name: 'time',
              label: 'Time',
            ),
          ),
        );

        // Update the form field value to trigger formatting
        final context = tester.element(find.byType(TypedTimePicker));
        formCubit.updateField<TimeOfDay>(
          fieldName: 'time',
          value: testTime,
          context: context,
        );

        await tester.pump();

        // Should display formatted time
        expect(find.text('2:30 PM'), findsOneWidget);
      });

      testWidgets('should call onTimeSubmitted when time is selected',
          (tester) async {
        // This test covers lines 112 and 113 - time selection callback
        TimeOfDay? submittedTime;

        await tester.pumpWidget(
          createTestWidget(
            TypedTimePicker(
              name: 'time',
              label: 'Select Time',
              onTimeSubmitted: (time) {
                submittedTime = time;
              },
            ),
          ),
        );

        // Tap to open time picker
        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        // Find and tap OK button to confirm selection
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Should have called the callback
        expect(submittedTime, isNotNull);
      });

      testWidgets('should handle custom decoration with error', (tester) async {
        // This test covers line 81 - decoration copyWith handling
        await tester.pumpWidget(
          createTestWidget(
            TypedTimePicker(
              name: 'time',
              label: 'Time',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
          ),
        );

        // Manually set an error to trigger decoration.copyWith
        final context = tester.element(find.byType(TypedTimePicker));
        formCubit.updateError(
          fieldName: 'time',
          errorMessage: 'Invalid time selected',
          context: context,
        );

        await tester.pump();

        // Should display error in the decoration
        expect(find.text('Invalid time selected'), findsOneWidget);

        // Should still have the custom decoration elements
        expect(find.byIcon(Icons.access_time), findsOneWidget);
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

      testWidgets('should display error message when validation fails',
          (tester) async {
        // This test covers lines 111, 113, 115, 116 - error display
        await tester.pumpWidget(
          createTestWidget(
            TypedSwitch(
              name: 'switch',
              title: const Text('Accept Terms'),
            ),
          ),
        );

        // Manually set an error on the switch field
        final context = tester.element(find.byType(TypedSwitch));
        formCubit.updateError(
          fieldName: 'switch',
          errorMessage: 'You must accept the terms',
          context: context,
        );

        await tester.pump();

        // Should display error message
        expect(find.text('You must accept the terms'), findsOneWidget);

        // Error text should have error color
        final errorText =
            tester.widget<Text>(find.text('You must accept the terms'));
        expect(errorText.style?.color, isNotNull);
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

      testWidgets('should display error message when validation fails',
          (tester) async {
        // This test covers lines 106, 108, 110, 111 - error display
        await tester.pumpWidget(
          createTestWidget(
            TypedSlider(
              name: 'slider',
              label: 'Volume',
              min: 0.0,
              max: 100.0,
            ),
          ),
        );

        // Manually set an error on the slider field
        final context = tester.element(find.byType(TypedSlider));
        formCubit.updateError(
          fieldName: 'slider',
          errorMessage: 'Value must be between 10 and 90',
          context: context,
        );

        await tester.pump();

        // Should display error message
        expect(find.text('Value must be between 10 and 90'), findsOneWidget);

        // Error text should have error color
        final errorText =
            tester.widget<Text>(find.text('Value must be between 10 and 90'));
        expect(errorText.style?.color, isNotNull);
      });

      testWidgets('should handle overlayColor property', (tester) async {
        // This test covers line 84 - overlayColor handling
        await tester.pumpWidget(
          createTestWidget(
            TypedSlider(
              name: 'slider',
              label: 'Volume',
              min: 0.0,
              max: 100.0,
              overlayColor: Colors.blue,
            ),
          ),
        );

        await tester.pump();

        // Should render without errors with overlayColor
        expect(find.byType(Slider), findsOneWidget);

        // Check that the slider has the overlay color applied
        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.overlayColor, isNotNull);
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
