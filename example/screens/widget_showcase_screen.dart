import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Comprehensive showcase of all 7 pre-built widgets
/// demonstrating their features and capabilities
class WidgetShowcaseScreen extends StatelessWidget {
  const WidgetShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Showcase'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (context) => CoreFormCubit(
            fields: [
              // Text Field
              TypedFormField<String>(
                name: 'textField',
                validators: [
                  CommonValidators.required<String>(),
                  CommonValidators.minLength(3),
                ],
                initialValue: '',
              ),

              // Checkbox
              TypedFormField<bool>(
                name: 'checkbox',
                validators: [
                  SimpleValidator<bool>((value, context) =>
                      value == true ? null : 'Please check this box'),
                ],
                initialValue: false,
              ),

              // Switch
              TypedFormField<bool>(
                name: 'switch',
                validators: [],
                initialValue: false,
              ),

              // Dropdown
              TypedFormField<String>(
                name: 'dropdown',
                validators: [CommonValidators.required<String>()],
                initialValue: '',
              ),

              // Slider
              TypedFormField<double>(
                name: 'slider',
                validators: [
                  SimpleValidator<double>((value, context) =>
                      (value ?? 0) >= 30 ? null : 'Value must be at least 30'),
                ],
                initialValue: 50.0,
              ),

              // Date Picker
              TypedFormField<DateTime>(
                name: 'datePicker',
                validators: [
                  SimpleValidator<DateTime>((value, context) =>
                      value != null ? null : 'Please select a date'),
                ],
                initialValue: null,
              ),

              // Time Picker
              TypedFormField<TimeOfDay>(
                name: 'timePicker',
                validators: [
                  SimpleValidator<TimeOfDay>((value, context) =>
                      value != null ? null : 'Please select a time'),
                ],
                initialValue: null,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'All 7 Pre-built Widgets',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Production-ready widgets with comprehensive validation',
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
                ),
                const SizedBox(height: 32),

                // 1. TypedTextField
                _buildWidgetSection(
                  title: '1. TypedTextField',
                  description:
                      'Universal text input with all TextFormField parameters',
                  child: TypedTextField(
                    name: 'textField',
                    label: 'Text Field',
                    hintText: 'Enter some text...',
                    prefixIcon: const Icon(Icons.text_fields),
                    helperText: 'Minimum 3 characters required',
                  ),
                ),

                // 2. TypedCheckbox
                _buildWidgetSection(
                  title: '2. TypedCheckbox',
                  description:
                      'Checkbox with title, subtitle, and error handling',
                  child: TypedCheckbox(
                    name: 'checkbox',
                    title: const Text('I agree to the terms'),
                    subtitle: const Text('This checkbox is required'),
                  ),
                ),

                // 3. TypedSwitch
                _buildWidgetSection(
                  title: '3. TypedSwitch',
                  description: 'Switch with title, subtitle, and error display',
                  child: TypedSwitch(
                    name: 'switch',
                    title: const Text('Enable notifications'),
                    subtitle: const Text('Receive push notifications'),
                  ),
                ),

                // 4. TypedDropdown
                _buildWidgetSection(
                  title: '4. TypedDropdown',
                  description: 'Dropdown with custom items and validation',
                  child: TypedDropdown<String>(
                    name: 'dropdown',
                    label: 'Select Option',
                    items: const ['Option 1', 'Option 2', 'Option 3'],
                    itemBuilder: (item) => Text(item),
                    hintText: 'Choose an option...',
                  ),
                ),

                // 5. TypedSlider
                _buildWidgetSection(
                  title: '5. TypedSlider',
                  description:
                      'Slider with labels, divisions, and value display',
                  child: TypedSlider(
                    name: 'slider',
                    label: 'Volume Level',
                    min: 0.0,
                    max: 100.0,
                    divisions: 10,
                    showValue: true,
                    activeColor: Colors.blue,
                  ),
                ),

                // 6. TypedDatePicker
                _buildWidgetSection(
                  title: '6. TypedDatePicker',
                  description:
                      'Date picker with custom formatting and validation',
                  child: TypedDatePicker(
                    name: 'datePicker',
                    label: 'Select Date',
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    dateFormat: 'MMM dd, yyyy',
                    onDateSubmitted: (date) {
                      print('Date selected: $date');
                    },
                  ),
                ),

                // 7. TypedTimePicker
                _buildWidgetSection(
                  title: '7. TypedTimePicker',
                  description:
                      'Time picker with custom decoration and callbacks',
                  child: TypedTimePicker(
                    name: 'timePicker',
                    label: 'Select Time',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTimeSubmitted: (time) {
                      print('Time selected: $time');
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Form Status Summary
                BlocBuilder<CoreFormCubit, CoreFormState>(
                  builder: (context, state) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  state.isValid
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color:
                                      state.isValid ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Form Status: ${state.isValid ? 'Valid' : 'Invalid'}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: state.isValid
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Current Values:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildValueRow('Text Field',
                                state.getValue<String>('textField')),
                            _buildValueRow(
                                'Checkbox', state.getValue<bool>('checkbox')),
                            _buildValueRow(
                                'Switch', state.getValue<bool>('switch')),
                            _buildValueRow(
                                'Dropdown', state.getValue<String>('dropdown')),
                            _buildValueRow('Slider',
                                state.getValue<double>('slider')?.round()),
                            _buildValueRow(
                                'Date',
                                state
                                    .getValue<DateTime>('datePicker')
                                    ?.toString()
                                    .split(' ')[0]),
                            _buildValueRow(
                                'Time',
                                state
                                    .getValue<TimeOfDay>('timePicker')
                                    ?.format(context)),
                            if (state.errors.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Validation Errors: ${state.errors.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...state.errors.entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• ${entry.key}: ${entry.value}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: state.isValid
                                  ? () => _showFormData(context, state)
                                  : null,
                              child: const Text('Submit All Data'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Features Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🚀 Widget Features',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('✅ Type-safe form integration'),
                        const Text('✅ Automatic validation'),
                        const Text('✅ Error handling and display'),
                        const Text('✅ Reactive state management'),
                        const Text('✅ Customizable styling'),
                        const Text('✅ Accessibility support'),
                        const Text('✅ Performance optimized'),
                        const Text('✅ Production ready'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildValueRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'null',
              style: TextStyle(
                color: value != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFormData(BuildContext context, CoreFormState state) {
    final formData = {
      'textField': state.getValue<String>('textField'),
      'checkbox': state.getValue<bool>('checkbox'),
      'switch': state.getValue<bool>('switch'),
      'dropdown': state.getValue<String>('dropdown'),
      'slider': state.getValue<double>('slider'),
      'datePicker': state.getValue<DateTime>('datePicker'),
      'timePicker': state.getValue<TimeOfDay>('timePicker'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Data Submitted!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('All widget data has been collected:'),
              const SizedBox(height: 12),
              ...formData.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${entry.key}: ${entry.value}'),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    print('Widget showcase data: $formData');
  }
}
