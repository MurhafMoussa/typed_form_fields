import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Complete registration form example using FieldWrapper<T>
/// This demonstrates the clean, universal integration approach
class RegistrationForm extends StatelessWidget {
  const RegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (context) => CoreFormCubit(
            fields: [
              TypedFormField<String>(
                name: 'firstName',
                validators: [
                  CommonValidators.required<String>(),
                  CommonValidators.minLength(2),
                  CommonValidators.alphabetic(),
                ],
                initialValue: '',
              ),
              TypedFormField<String>(
                name: 'lastName',
                validators: [
                  CommonValidators.required<String>(),
                  CommonValidators.minLength(2),
                  CommonValidators.alphabetic(),
                ],
                initialValue: '',
              ),
              TypedFormField<String>(
                name: 'email',
                validators: [
                  CommonValidators.required<String>(),
                  CommonValidators.email(),
                ],
                initialValue: '',
              ),
              TypedFormField<String>(
                name: 'phone',
                validators: [
                  CommonValidators.required<String>(),
                  CommonValidators.phoneNumber(),
                ],
                initialValue: '',
              ),
              TypedFormField<String>(
                name: 'password',
                validators: [
                  CommonValidators.required<String>(),
                  CommonValidators.minLength(8),
                  CommonValidators.pattern(
                    RegExp(r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)'),
                    errorText: 'Must contain uppercase, lowercase, and number',
                  ),
                ],
                initialValue: '',
              ),
              TypedFormField<String>(
                name: 'confirmPassword',
                validators: [
                  CommonValidators.required<String>(),
                  // Cross-field validation will be handled in the cubit
                ],
                initialValue: '',
              ),
              TypedFormField<bool>(
                name: 'agreeToTerms',
                validators: [
                  SimpleValidator<bool>((value, context) =>
                      value == true ? null : 'You must agree to the terms'),
                ],
                initialValue: false,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Using FieldWrapper<T> for Universal Integration',
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
                ),
                SizedBox(height: 32),

                // First Name with FieldWrapper
                FieldWrapper<String>(
                  fieldName: 'firstName',
                  transformValue: (value) => value.trim(),
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                        prefixIcon: Icon(Icons.person),
                        errorText: hasError ? error : null,
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                SizedBox(height: 16),

                // Last Name with FieldWrapper
                FieldWrapper<String>(
                  fieldName: 'lastName',
                  transformValue: (value) => value.trim(),
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Enter your last name',
                        prefixIcon: Icon(Icons.person_outline),
                        errorText: hasError ? error : null,
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                SizedBox(height: 16),

                // Email with FieldWrapper and debouncing
                FieldWrapper<String>(
                  fieldName: 'email',
                  debounceTime: Duration(milliseconds: 300),
                  transformValue: (value) => value.toLowerCase().trim(),
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(Icons.email),
                        errorText: hasError ? error : null,
                        border: OutlineInputBorder(),
                        helperText: 'Validation debounced by 300ms',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                SizedBox(height: 16),

                // Phone with FieldWrapper
                FieldWrapper<String>(
                  fieldName: 'phone',
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        prefixIcon: Icon(Icons.phone),
                        errorText: hasError ? error : null,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                SizedBox(height: 16),

                // Password with FieldWrapper
                FieldWrapper<String>(
                  fieldName: 'password',
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Create a strong password',
                        prefixIcon: Icon(Icons.lock),
                        errorText: hasError ? error : null,
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                SizedBox(height: 16),

                // Confirm Password with FieldWrapper
                FieldWrapper<String>(
                  fieldName: 'confirmPassword',
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icon(Icons.lock_outline),
                        errorText: hasError ? error : null,
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    );
                  },
                ),
                SizedBox(height: 16),

                // Terms Agreement with FieldWrapper
                FieldWrapper<bool>(
                  fieldName: 'agreeToTerms',
                  builder: (context, value, error, hasError, updateValue) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: Text('I agree to the Terms and Conditions'),
                          value: value ?? false,
                          onChanged: updateValue,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (hasError)
                          Padding(
                            padding: EdgeInsets.only(left: 16, top: 4),
                            child: Text(
                              error!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 32),

                // Submit button with form status
                BlocBuilder<CoreFormCubit, CoreFormState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: state.isValid
                              ? () => _submitForm(context, state)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Form status indicator
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
                                state.isValid
                                    ? Icons.check_circle
                                    : Icons.error,
                                color:
                                    state.isValid ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.isValid
                                      ? 'Form is valid! Ready to submit ✓'
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

                        // Login Link
                        TextButton(
                          onPressed: () {
                            // Navigate to login
                          },
                          child: Text('Already have an account? Sign in'),
                        ),

                        // Debug info (expandable)
                        if (state.values.isNotEmpty) ...[
                          SizedBox(height: 16),
                          ExpansionTile(
                            title: Text('Debug: Form State'),
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
                                    Text('Values:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        'First Name: ${state.getValue<String>('firstName')}'),
                                    Text(
                                        'Last Name: ${state.getValue<String>('lastName')}'),
                                    Text(
                                        'Email: ${state.getValue<String>('email')}'),
                                    Text(
                                        'Phone: ${state.getValue<String>('phone')}'),
                                    Text('Password: [hidden]'),
                                    Text('Confirm Password: [hidden]'),
                                    Text(
                                        'Agree to Terms: ${state.getValue<bool>('agreeToTerms')}'),
                                    SizedBox(height: 8),
                                    Text('Errors:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('${state.errors}'),
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
      ),
    );
  }

  void _submitForm(BuildContext context, CoreFormState state) {
    // Type-safe access to form values
    final userData = {
      'firstName': state.getValue<String>('firstName'),
      'lastName': state.getValue<String>('lastName'),
      'email': state.getValue<String>('email'),
      'phone': state.getValue<String>('phone'),
      'password': state.getValue<String>('password'),
      'agreeToTerms': state.getValue<bool>('agreeToTerms'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Created!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome ${userData['firstName']} ${userData['lastName']}!'),
            SizedBox(height: 8),
            Text('Email: ${userData['email']}'),
            Text('Phone: ${userData['phone']}'),
            SizedBox(height: 8),
            Text('Your account has been successfully created.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // TODO: Send data to your backend
    print('Registration data: $userData');
  }
}

/// Comparison: Manual Integration vs FieldWrapper
/// 
/// This example shows the power of FieldWrapper<T>:
/// 
/// **Before (Manual Integration):**
/// ```dart
/// TextFormField(
///   controller: _controller,
///   onChanged: (value) => context.read<CoreFormCubit>().updateField<String>(
///     fieldName: 'email',
///     value: value,
///     context: context,
///   ),
///   validator: (value) => _emailValidator.validate(value, context),
///   // ... lots of boilerplate
/// )
/// ```
/// 
/// **After (FieldWrapper):**
/// ```dart
/// FieldWrapper<String>(
///   fieldName: 'email',
///   debounceTime: Duration(milliseconds: 300),
///   transformValue: (value) => value.toLowerCase().trim(),
///   builder: (context, value, error, hasError, updateValue) {
///     return TextFormField(
///       initialValue: value,
///       onChanged: updateValue,
///       decoration: InputDecoration(
///         errorText: hasError ? error : null,
///       ),
///     );
///   },
/// )
/// ```
/// 
/// **Key Benefits:**
/// - No TextEditingController management
/// - Automatic validation integration
/// - Built-in debouncing support
/// - Value transformation
/// - Type-safe form state access
/// - Works with ANY Flutter widget
/// - Reactive state management
/// - Cross-field validation support

/// Usage:
/// 
/// ```dart
/// MaterialApp(home: RegistrationForm())
/// ```