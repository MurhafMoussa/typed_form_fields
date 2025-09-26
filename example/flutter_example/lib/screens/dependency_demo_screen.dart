import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Demonstrates how dependentFields optimization works
class DependencyDemoScreen extends StatelessWidget {
  const DependencyDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dependency Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (context) => CoreFormCubit(
            fields: [
              TypedFormField<String>(
                name: 'password',
                validators: [
                  CommonValidators.required<String>(),
                  CommonValidators.minLength(6),
                ],
                initialValue: '',
              ),
              TypedFormField<String>(
                name: 'confirmPassword',
                validators: [
                  CommonValidators.required<String>(),
                  CrossFieldValidators.matches<String>(
                    'password',
                    errorText: 'Passwords do not match',
                  ),
                ],
                initialValue: '',
              ),
              TypedFormField<String>(
                name: 'unrelatedField',
                validators: [CommonValidators.required<String>()],
                initialValue: '',
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Dependency Optimization Demo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Watch how changing the password field triggers validation '
                  'of the confirm password field (its dependent), but not the unrelated field.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Password:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FieldWrapper<String>(
                  fieldName: 'password',
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                        helperText:
                            'Changing this will validate confirm password',
                      ),
                      obscureText: true,
                    );
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'Confirm Password (depends on password):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FieldWrapper<String>(
                  fieldName: 'confirmPassword',
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                        helperText: 'This field depends on password field',
                      ),
                      obscureText: true,
                    );
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'Unrelated Field (no dependencies):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FieldWrapper<String>(
                  fieldName: 'unrelatedField',
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Unrelated Field',
                        prefixIcon: const Icon(Icons.text_fields),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                        helperText: 'This field is independent',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                BlocBuilder<CoreFormCubit, CoreFormState>(
                  builder: (context, state) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dependency Information:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text('• Password field: No dependencies'),
                            const Text(
                              '• Confirm Password: Depends on [password]',
                            ),
                            const Text('• Unrelated Field: No dependencies'),
                            const SizedBox(height: 16),
                            const Text(
                              'How it works:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '1. When password changes, the system knows to re-validate confirmPassword\n'
                              '2. When confirmPassword changes, only its own validation runs\n'
                              '3. When unrelatedField changes, no other fields are affected\n'
                              '4. This prevents unnecessary validation cycles',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Current Form State: ${state.isValid ? "Valid" : "Invalid"}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: state.isValid
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            if (state.errors.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Errors:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ...state.errors.entries.map(
                                (entry) =>
                                    Text('• ${entry.key}: ${entry.value}'),
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
