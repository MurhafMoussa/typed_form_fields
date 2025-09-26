import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

// ignore: unintended_html_in_doc_comment
/// BLoC-managed form example with FieldWrapper<T> integration
/// This demonstrates reactive validation with clean architecture
class BlocFormScreen extends StatelessWidget {
  const BlocFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginFormCubit(),
      child: const LoginFormView(),
    );
  }
}

/// Form Cubit extending CoreFormCubit
class LoginFormCubit extends CoreFormCubit {
  LoginFormCubit()
    : super(
        fields: [
          TypedFormField<String>(
            name: 'email',
            validators: [
              CommonValidators.required<String>(),
              CommonValidators.email(),
            ],
            initialValue: '',
          ),
          TypedFormField<String>(
            name: 'password',
            validators: [
              CommonValidators.required<String>(),
              CommonValidators.minLength(8),
            ],
            initialValue: '',
          ),
          const TypedFormField<bool>(
            name: 'rememberMe',
            validators: [],
            initialValue: false,
          ),
        ],
        validationType: ValidationType.fieldsBeingEdited,
      );

  /// Submit the form
  Future<void> submitLogin(BuildContext context) async {
    if (!state.isValid) return;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final email = state.getValue<String>('email');
      final password = state.getValue<String>('password');
      final rememberMe = state.getValue<bool>('rememberMe');

      debugPrint('Login attempt: $email, remember: $rememberMe');

      // Simulate success/failure
      if (email == 'admin@example.com' && password == 'password123') {
        // Success - in real app, navigate to home
        debugPrint('Login successful!');
      } else {
        // Simulate server error
        if (context.mounted) {
          updateError(
            fieldName: 'email',
            errorMessage: 'Invalid email or password',
            context: context,
          );
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
  }

  /// Clear all form data
  void clearForm(BuildContext context) {
    updateField<String>(fieldName: 'email', value: '', context: context);
    updateField<String>(fieldName: 'password', value: '', context: context);
    updateField<bool>(fieldName: 'rememberMe', value: false, context: context);
  }
}

/// Form View Widget
class LoginFormView extends StatelessWidget {
  const LoginFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLoC Form Architecture'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => context.read<LoginFormCubit>().clearForm(context),
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocBuilder<LoginFormCubit, CoreFormState>(
                builder: (context, state) {
                  final cubit = context.read<LoginFormCubit>();
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
                'Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Custom BLoC extending CoreFormCubit',
                style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
              ),
              const SizedBox(height: 32),

              // Email Field with FieldWrapper
              FieldWrapper<String>(
                fieldName: 'email',
                debounceTime: const Duration(milliseconds: 500),
                transformValue: (value) => value.toLowerCase().trim(),
                onFieldStateChanged: (value, error, hasError) {
                  if (value?.isNotEmpty == true) {
                    debugPrint(
                      'User started typing email:  {value?.length} chars',
                    );
                  }
                },
                builder: (context, value, error, hasError, updateValue) {
                  return TextFormField(
                    initialValue: value,
                    onChanged: updateValue,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Try: admin@example.com',
                      prefixIcon: const Icon(Icons.email),
                      errorText: hasError ? error : null,
                      border: const OutlineInputBorder(),
                      helperText: 'Debounced validation (500ms)',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Password Field with FieldWrapper
              FieldWrapper<String>(
                fieldName: 'password',
                builder: (context, value, error, hasError, updateValue) {
                  return TextFormField(
                    initialValue: value,
                    onChanged: updateValue,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Try: password123',
                      prefixIcon: const Icon(Icons.lock),
                      errorText: hasError ? error : null,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Remember Me with FieldWrapper
              FieldWrapper<bool>(
                fieldName: 'rememberMe',
                builder: (context, value, error, hasError, updateValue) {
                  return CheckboxListTile(
                    title: const Text('Remember me'),
                    value: value ?? false,
                    onChanged: updateValue,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),

              const SizedBox(height: 32),

              // Login Button with BLoC State
              BlocBuilder<LoginFormCubit, CoreFormState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: state.isValid
                            ? () => context.read<LoginFormCubit>().submitLogin(
                                context,
                              )
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Form Status
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: state.isValid
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: state.isValid ? Colors.green : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              state.isValid ? Icons.check_circle : Icons.info,
                              color: state.isValid
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.isValid
                                    ? 'Ready to login ✓'
                                    : 'Fill in all required fields',
                                style: TextStyle(
                                  color: state.isValid
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // BLoC Architecture Info
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BLoC Architecture Benefits',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('✅ Custom business logic in LoginFormCubit'),
                              Text(
                                '✅ Extends CoreFormCubit for form management',
                              ),
                              Text('✅ Clean separation of concerns'),
                              Text('✅ Testable architecture'),
                              Text('✅ Reactive state management'),
                              SizedBox(height: 12),
                              Text(
                                'Try the demo:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Email: admin@example.com'),
                              Text('Password: password123'),
                            ],
                          ),
                        ),
                      ),

                      // Debug Info
                      if (state.values.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ExpansionTile(
                          title: const Text('Debug: BLoC State'),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Form Values:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Email: ${state.getValue<String>('email')}',
                                  ),
                                  const Text('Password: [hidden]'),
                                  Text(
                                    'Remember Me: ${state.getValue<bool>('rememberMe')}',
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Form State:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Is Valid: ${state.isValid}'),
                                  Text('Errors: ${state.errors.length}'),
                                  if (state.errors.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('Error Details: ${state.errors}'),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
