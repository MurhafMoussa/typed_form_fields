import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

// ignore: unintended_html_in_doc_comment
/// Complete registration form example using FieldWrapper<T>
/// This demonstrates the clean, universal integration approach
class RegistrationFormScreen extends StatelessWidget {
  const RegistrationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Form'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  CrossFieldValidators.matches<String>('password'),
                ],
                initialValue: '',
              ),
              TypedFormField<bool>(
                name: 'agreeToTerms',
                validators: [
                  SimpleValidator<bool>(
                    (value, context) =>
                        value == true ? null : 'You must agree to the terms',
                  ),
                ],
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
                  'Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Using FieldWrapper<T> for Universal Integration',
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
                ),
                const SizedBox(height: 32),

                // First Name with FieldWrapper
                FieldWrapper<String>(
                  fieldName: 'firstName',
                  transformValue: (value) => value.trim(),
                  onFieldStateChanged: (value, error, hasError) {
                    // Example of listener without rebuild
                    if (hasError) {
                      debugPrint('First name error: $error');
                    }
                  },
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                        prefixIcon: const Icon(Icons.person),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                const SizedBox(height: 16),

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
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Email with FieldWrapper and debouncing
                FieldWrapper<String>(
                  fieldName: 'email',
                  debounceTime: const Duration(milliseconds: 300),
                  transformValue: (value) => value.toLowerCase().trim(),
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: const Icon(Icons.email),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                        helperText: 'Validation debounced by 300ms',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                const SizedBox(height: 16),

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
                        prefixIcon: const Icon(Icons.phone),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                const SizedBox(height: 16),

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
                        prefixIcon: const Icon(Icons.lock),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                    );
                  },
                ),
                const SizedBox(height: 16),

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
                        prefixIcon: const Icon(Icons.lock_outline),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Terms Agreement with FieldWrapper
                FieldWrapper<bool>(
                  fieldName: 'agreeToTerms',
                  builder: (context, value, error, hasError, updateValue) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: const Text(
                            'I agree to the Terms and Conditions',
                          ),
                          value: value ?? false,
                          onChanged: updateValue,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (hasError)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
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

                const SizedBox(height: 32),

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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Form status indicator
                        Container(
                          padding: const EdgeInsets.all(12),
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
                                color: state.isValid
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
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

                        const SizedBox(height: 16),

                        // Debug info (expandable)
                        if (state.values.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ExpansionTile(
                            title: const Text('Debug: Form State'),
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
                                      'Values:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'First Name: ${state.getValue<String>('firstName')}',
                                    ),
                                    Text(
                                      'Last Name: ${state.getValue<String>('lastName')}',
                                    ),
                                    Text(
                                      'Email: ${state.getValue<String>('email')}',
                                    ),
                                    Text(
                                      'Phone: ${state.getValue<String>('phone')}',
                                    ),
                                    const Text('Password: [hidden]'),
                                    const Text('Confirm Password: [hidden]'),
                                    Text(
                                      'Agree to Terms: ${state.getValue<bool>('agreeToTerms')}',
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Errors:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
        title: const Text('Account Created!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome ${userData['firstName']} ${userData['lastName']}!'),
            const SizedBox(height: 8),
            Text('Email: ${userData['email']}'),
            Text('Phone: ${userData['phone']}'),
            const SizedBox(height: 8),
            const Text('Your account has been successfully created.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // TODO: Send data to your backend
    debugPrint('Registration data: $userData');
  }
}
