import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// BLoC-managed form example with FieldWrapper<T> integration
/// This demonstrates reactive validation with clean architecture
class BlocFormExample extends StatelessWidget {
  const BlocFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginFormCubit(),
      child: LoginFormView(),
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
            TypedFormField<bool>(
              name: 'rememberMe',
              validators: [],
              initialValue: false,
            ),
          ],
          validationType: ValidationType.fieldsBeingEdited,
        );

  /// Submit the form
  void submitForm(BuildContext context) {
    validateForm(
      context,
      onValidationPass: () {
        final email = state.getValue<String>('email');
        final password = state.getValue<String>('password');
        final rememberMe = state.getValue<bool>('rememberMe');

        // TODO: Call your authentication service
        print('Login attempt: $email, Remember: $rememberMe');

        // Simulate API call
        _performLogin(email!, password!, context);
      },
      onValidationFail: () {
        // Validation failed - errors are already shown in UI
        print('Form validation failed');
      },
    );
  }

  void _performLogin(
      String email, String password, BuildContext context) async {
    // Show loading state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logging in...')),
    );

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    // Simulate server validation error
    if (email == 'taken@example.com') {
      updateError(
        fieldName: 'email',
        errorMessage: 'Invalid email or password',
        context: context,
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Success
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
      print('Login successful!');
    }
  }
}

/// Form View Widget using FieldWrapper<T>
class LoginFormView extends StatelessWidget {
  const LoginFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login with FieldWrapper')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'BLoC + FieldWrapper Integration',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Reactive form validation with clean architecture',
                style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
              ),
              SizedBox(height: 32),

              // Email Field with FieldWrapper
              FieldWrapper<String>(
                fieldName: 'email',
                debounceTime: Duration(milliseconds: 400),
                transformValue: (value) => value.toLowerCase().trim(),
                builder: (context, value, error, hasError, updateValue) {
                  return TextFormField(
                    initialValue: value,
                    onChanged: updateValue,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email),
                      errorText: hasError ? error : null,
                      border: OutlineInputBorder(),
                      helperText: 'Try "taken@example.com" to see server error',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  );
                },
              ),

              SizedBox(height: 16),

              // Password Field with FieldWrapper
              FieldWrapper<String>(
                fieldName: 'password',
                builder: (context, value, error, hasError, updateValue) {
                  return TextFormField(
                    initialValue: value,
                    onChanged: updateValue,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock),
                      errorText: hasError ? error : null,
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                  );
                },
              ),

              SizedBox(height: 16),

              // Remember Me Checkbox with FieldWrapper
              FieldWrapper<bool>(
                fieldName: 'rememberMe',
                builder: (context, value, error, hasError, updateValue) {
                  return CheckboxListTile(
                    title: Text('Remember me'),
                    value: value ?? false,
                    onChanged: updateValue,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),

              SizedBox(height: 32),

              // Submit Button with BLoC state
              BlocBuilder<LoginFormCubit, CoreFormState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: state.isValid
                            ? () {
                                context
                                    .read<LoginFormCubit>()
                                    .submitForm(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Form Status
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: state.isValid
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: state.isValid ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              state.isValid ? Icons.check_circle : Icons.error,
                              color: state.isValid ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.isValid
                                    ? 'Form is valid - ready to submit!'
                                    : 'Please fix ${state.errors.length} error(s)',
                                style: TextStyle(
                                  color: state.isValid
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Debug Info (remove in production)
                      if (kDebugMode) ...[
                        ExpansionTile(
                          title: Text('Debug: BLoC State'),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Email: ${state.getValue<String>('email')}'),
                                  Text(
                                      'Password: ${state.getValue<String>('password')}'),
                                  Text(
                                      'Remember Me: ${state.getValue<bool>('rememberMe')}'),
                                  Text('Is Valid: ${state.isValid}'),
                                  Text(
                                      'Validation Type: ${state.validationType}'),
                                  SizedBox(height: 8),
                                  Text('Errors: ${state.errors}'),
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

/// Advanced BLoC Form with Dynamic Validation using FieldWrapper
class AdvancedFormExample extends StatelessWidget {
  const AdvancedFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvancedFormCubit(),
      child: AdvancedFormView(),
    );
  }
}

class AdvancedFormCubit extends CoreFormCubit {
  AdvancedFormCubit()
      : super(
          fields: [
            TypedFormField<String>(
              name: 'username',
              validators: [CommonValidators.required<String>()],
              initialValue: '',
            ),
            TypedFormField<String>(
              name: 'email',
              validators: [CommonValidators.email()], // Initially optional
              initialValue: '',
            ),
            TypedFormField<bool>(
              name: 'isAdmin',
              validators: [],
              initialValue: false,
            ),
            TypedFormField<String>(
              name: 'adminCode',
              validators: [], // Conditionally required
              initialValue: '',
            ),
          ],
        );

  /// Toggle admin mode and update validation rules dynamically
  void toggleAdminMode(BuildContext context) {
    final isAdmin = state.getValue<bool>('isAdmin') ?? false;

    // Update the admin flag
    updateField<bool>(
      fieldName: 'isAdmin',
      value: !isAdmin,
      context: context,
    );

    // Update validation rules based on admin status
    if (!isAdmin) {
      // Becoming admin - make email required and add admin code requirement
      updateFieldValidators<String>(
        name: 'email',
        validators: [
          CommonValidators.required<String>(),
          CommonValidators.email(),
        ],
        context: context,
      );

      updateFieldValidators<String>(
        name: 'adminCode',
        validators: [
          CommonValidators.required<String>(),
          CommonValidators.minLength(6),
        ],
        context: context,
      );
    } else {
      // No longer admin - email is optional, admin code not required
      updateFieldValidators<String>(
        name: 'email',
        validators: [CommonValidators.email()],
        context: context,
      );

      updateFieldValidators<String>(
        name: 'adminCode',
        validators: [],
        context: context,
      );

      // Clear admin code value
      updateField<String>(
        fieldName: 'adminCode',
        value: '',
        context: context,
      );
    }
  }
}

class AdvancedFormView extends StatelessWidget {
  const AdvancedFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Advanced BLoC Form')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dynamic Validation with FieldWrapper',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Validation rules change based on form state',
                style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
              ),
              SizedBox(height: 32),

              // Username Field
              FieldWrapper<String>(
                fieldName: 'username',
                transformValue: (value) => value.trim(),
                builder: (context, value, error, hasError, updateValue) {
                  return TextFormField(
                    initialValue: value,
                    onChanged: updateValue,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      errorText: hasError ? error : null,
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),

              SizedBox(height: 16),

              // Email Field (validation changes based on admin status)
              FieldWrapper<String>(
                fieldName: 'email',
                transformValue: (value) => value.toLowerCase().trim(),
                builder: (context, value, error, hasError, updateValue) {
                  return BlocBuilder<AdvancedFormCubit, CoreFormState>(
                    builder: (context, state) {
                      final isAdmin = state.getValue<bool>('isAdmin') ?? false;
                      return TextFormField(
                        initialValue: value,
                        onChanged: updateValue,
                        decoration: InputDecoration(
                          labelText:
                              isAdmin ? 'Email (Required)' : 'Email (Optional)',
                          prefixIcon: Icon(Icons.email),
                          errorText: hasError ? error : null,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 16),

              // Admin Toggle
              FieldWrapper<bool>(
                fieldName: 'isAdmin',
                builder: (context, value, error, hasError, updateValue) {
                  return CheckboxListTile(
                    title: Text('Admin User'),
                    subtitle: Text('Requires email and admin code'),
                    value: value ?? false,
                    onChanged: (newValue) {
                      updateValue(newValue);
                      // Trigger validation rule changes
                      context
                          .read<AdvancedFormCubit>()
                          .toggleAdminMode(context);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),

              // Admin Code Field (conditionally shown)
              BlocBuilder<AdvancedFormCubit, CoreFormState>(
                builder: (context, state) {
                  final isAdmin = state.getValue<bool>('isAdmin') ?? false;
                  if (!isAdmin) return SizedBox.shrink();

                  return Column(
                    children: [
                      SizedBox(height: 16),
                      FieldWrapper<String>(
                        fieldName: 'adminCode',
                        builder:
                            (context, value, error, hasError, updateValue) {
                          return TextFormField(
                            initialValue: value,
                            onChanged: updateValue,
                            decoration: InputDecoration(
                              labelText: 'Admin Code',
                              hintText: 'Enter 6+ character admin code',
                              prefixIcon: Icon(Icons.security),
                              errorText: hasError ? error : null,
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 32),

              // Submit Button
              BlocBuilder<AdvancedFormCubit, CoreFormState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: state.isValid
                            ? () {
                                // Handle form submission
                                final formData = {
                                  'username':
                                      state.getValue<String>('username'),
                                  'email': state.getValue<String>('email'),
                                  'isAdmin': state.getValue<bool>('isAdmin'),
                                  'adminCode':
                                      state.getValue<String>('adminCode'),
                                };

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Form Submitted'),
                                    content: Text('Data: $formData'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Submit'),
                      ),

                      SizedBox(height: 16),

                      // Form Status
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: state.isValid
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: state.isValid ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          state.isValid
                              ? 'All validation rules satisfied!'
                              : 'Fix ${state.errors.length} error(s)',
                          style: TextStyle(
                            color: state.isValid
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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

/// Key Benefits of BLoC + FieldWrapper Integration:
/// 
/// 1. **Reactive State Management**: Form state changes trigger UI updates automatically
/// 2. **Clean Architecture**: Separation of business logic (Cubit) and UI (View)
/// 3. **Dynamic Validation**: Rules can change based on form state
/// 4. **Type Safety**: Compile-time type checking for form fields
/// 5. **Testable**: BLoC pattern makes unit testing easy
/// 6. **Reusable**: Form logic can be shared across different UI implementations
/// 7. **Performance**: FieldWrapper handles debouncing and efficient updates
/// 8. **Scalable**: Easy to add new fields and validation rules

/// Usage:
/// 
/// ```dart
/// // Basic BLoC form
/// MaterialApp(home: BlocFormExample())
/// 
/// // Advanced dynamic validation
/// MaterialApp(home: AdvancedFormExample())
/// ```