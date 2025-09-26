import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// FieldWrapper showcase demonstrating universal widget integration
/// and performance optimization features
class FieldWrapperScreen extends StatelessWidget {
  const FieldWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FieldWrapper Showcase'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (context) => CoreFormCubit(
            fields: [
              TypedFormField<String>(
                name: 'textField',
                validators: [CommonValidators.required<String>()],
                initialValue: '',
              ),
              TypedFormField<double>(
                name: 'customSlider',
                validators: [
                  SimpleValidator<double>(
                    (value, context) =>
                        (value ?? 0) >= 50 ? null : 'Value must be at least 50',
                  ),
                ],
                initialValue: 25.0,
              ),
              TypedFormField<String>(
                name: 'customDropdown',
                validators: [CommonValidators.required<String>()],
                initialValue: '',
              ),
              const TypedFormField<bool>(
                name: 'customToggle',
                validators: [],
                initialValue: false,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<CoreFormCubit, CoreFormState>(
                  builder: (context, state) {
                    final cubit = context.read<CoreFormCubit>();
                    return Row(
                      children: [
                        const Icon(Icons.verified_user, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Validation: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<ValidationType>(
                          value: state.validationType,
                          items: const [
                            DropdownMenuItem(
                              value: ValidationType.onSubmit,
                              child: Text('On Submit'),
                            ),
                            DropdownMenuItem(
                              value: ValidationType.allFields,
                              child: Text('All Fields'),
                            ),
                            DropdownMenuItem(
                              value: ValidationType.fieldsBeingEdited,
                              child: Text('Fields Being Edited'),
                            ),
                            DropdownMenuItem(
                              value: ValidationType.disabled,
                              child: Text('Disabled'),
                            ),
                          ],
                          onChanged: (type) {
                            if (type != null) cubit.setValidationType(type);
                          },
                          underline: Container(),
                          style: const TextStyle(color: Colors.blue),
                          dropdownColor: Colors.white,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'FieldWrapper<T> Universal Integration',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Performance optimized with BlocConsumer',
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
                ),
                const SizedBox(height: 32),

                // Performance Features Card
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🚀 Performance Features',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('✅ BlocConsumer with buildWhen/listenWhen'),
                        Text('✅ Field-specific rebuilds only'),
                        Text('✅ Listener support without rebuilds'),
                        Text('✅ Debouncing for rapid input'),
                        Text('✅ Value transformation'),
                        Text('✅ Automatic cleanup'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Example 1: Standard TextField with Performance Monitoring
                const Text(
                  '1. TextField with Performance Monitoring',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _PerformanceMonitorWrapper(
                  child: FieldWrapper<String>(
                    fieldName: 'textField',
                    debounceTime: const Duration(milliseconds: 300),
                    transformValue: (value) => value.trim(),
                    onFieldStateChanged: (value, error, hasError) {
                      // This listener doesn't trigger rebuilds!
                      print('TextField changed: $value (hasError: $hasError)');
                    },
                    builder: (context, value, error, hasError, updateValue) {
                      return TextFormField(
                        initialValue: value,
                        onChanged: updateValue,
                        decoration: InputDecoration(
                          labelText: 'Text Field',
                          hintText: 'Type something...',
                          prefixIcon: const Icon(Icons.text_fields),
                          errorText: hasError ? error : null,
                          border: const OutlineInputBorder(),
                          helperText: 'Debounced validation (300ms)',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Example 2: Custom Slider Widget
                const Text(
                  '2. Custom Slider with FieldWrapper',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _PerformanceMonitorWrapper(
                  child: FieldWrapper<double>(
                    fieldName: 'customSlider',
                    onFieldStateChanged: (value, error, hasError) {
                      print('Slider changed: $value (hasError: $hasError)');
                    },
                    builder: (context, value, error, hasError, updateValue) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tune, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Custom Slider: ${(value ?? 0).round()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: hasError
                                    ? Colors.red
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Slider(
                                  value: value ?? 0,
                                  min: 0,
                                  max: 100,
                                  divisions: 20,
                                  label: '${(value ?? 0).round()}',
                                  onChanged: updateValue,
                                ),
                                if (hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      error!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Example 3: Custom Dropdown
                const Text(
                  '3. Custom Dropdown with FieldWrapper',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _PerformanceMonitorWrapper(
                  child: FieldWrapper<String>(
                    fieldName: 'customDropdown',
                    builder: (context, value, error, hasError, updateValue) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: hasError
                                    ? Colors.red
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: value?.isEmpty == true ? null : value,
                                hint: const Text('Select an option'),
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                items: ['Option 1', 'Option 2', 'Option 3'].map(
                                  (String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item),
                                    );
                                  },
                                ).toList(),
                                onChanged: updateValue,
                              ),
                            ),
                          ),
                          if (hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Text(
                                error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Example 4: Custom Toggle Switch
                const Text(
                  '4. Custom Toggle with FieldWrapper',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _PerformanceMonitorWrapper(
                  child: FieldWrapper<bool>(
                    fieldName: 'customToggle',
                    builder: (context, value, error, hasError, updateValue) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (value ?? false)
                              ? Colors.blue.shade50
                              : Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              (value ?? false)
                                  ? Icons.toggle_on
                                  : Icons.toggle_off,
                              size: 32,
                              color: (value ?? false)
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Custom Toggle Switch',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    (value ?? false) ? 'Enabled' : 'Disabled',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: value ?? false,
                              onChanged: updateValue,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Form Status
                BlocBuilder<CoreFormCubit, CoreFormState>(
                  builder: (context, state) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Form Status: ${state.isValid ? 'Valid ✓' : 'Invalid ✗'}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: state.isValid
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Text Field: ${state.getValue<String>('textField')}',
                            ),
                            Text(
                              'Slider: ${state.getValue<double>('customSlider')?.round()}',
                            ),
                            Text(
                              'Dropdown: ${state.getValue<String>('customDropdown')}',
                            ),
                            Text(
                              'Toggle: ${state.getValue<bool>('customToggle')}',
                            ),
                            if (state.errors.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Errors: ${state.errors.length}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget that monitors rebuild count for performance demonstration
class _PerformanceMonitorWrapper extends StatefulWidget {
  final Widget child;

  const _PerformanceMonitorWrapper({required this.child});

  @override
  State<_PerformanceMonitorWrapper> createState() =>
      _PerformanceMonitorWrapperState();
}

class _PerformanceMonitorWrapperState
    extends State<_PerformanceMonitorWrapper> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount++;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Rebuilds: $_buildCount',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        widget.child,
      ],
    );
  }
}
