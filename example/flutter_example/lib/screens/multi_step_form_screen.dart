import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Multi-step form example demonstrating complex form flows
/// with step validation and progress tracking
class MultiStepFormScreen extends StatelessWidget {
  const MultiStepFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MultiStepFormCubit(),
      child: const MultiStepFormView(),
    );
  }
}

/// Custom cubit for multi-step form management
class MultiStepFormCubit extends CoreFormCubit {
  int _currentStep = 0;

  MultiStepFormCubit()
      : super(
          fields: [
            // Step 1: Personal Info
            TypedFormField<String>(
              name: 'firstName',
              validators: [
                CommonValidators.required<String>(),
                CommonValidators.minLength(2),
              ],
              initialValue: '',
            ),
            TypedFormField<String>(
              name: 'lastName',
              validators: [
                CommonValidators.required<String>(),
                CommonValidators.minLength(2),
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

            // Step 2: Address Info
            TypedFormField<String>(
              name: 'address',
              validators: [CommonValidators.required<String>()],
              initialValue: '',
            ),
            TypedFormField<String>(
              name: 'city',
              validators: [CommonValidators.required<String>()],
              initialValue: '',
            ),
            TypedFormField<String>(
              name: 'zipCode',
              validators: [
                CommonValidators.required<String>(),
                CommonValidators.pattern(
                  RegExp(r'^\d{5}(-\d{4})?$'),
                  errorText: 'Enter valid ZIP code (12345 or 12345-6789)',
                ),
              ],
              initialValue: '',
            ),

            // Step 3: Preferences
            const TypedFormField<String>(
              name: 'newsletter',
              validators: [],
              initialValue: 'weekly',
            ),
            const TypedFormField<bool>(
              name: 'notifications',
              validators: [],
              initialValue: true,
            ),
            TypedFormField<bool>(
              name: 'terms',
              validators: [
                SimpleValidator<bool>(
                  (value, context) =>
                      value == true ? null : 'You must accept the terms',
                ),
              ],
              initialValue: false,
            ),
          ],
        );

  int get currentStep => _currentStep;

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      emit(state);
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      emit(state);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      emit(state);
    }
  }

  bool isStepValid(int step) {
    switch (step) {
      case 0: // Personal Info
        return !state.hasError('firstName') &&
            !state.hasError('lastName') &&
            !state.hasError('email') &&
            state.getValue<String>('firstName')?.isNotEmpty == true &&
            state.getValue<String>('lastName')?.isNotEmpty == true &&
            state.getValue<String>('email')?.isNotEmpty == true;
      case 1: // Address Info
        return !state.hasError('address') &&
            !state.hasError('city') &&
            !state.hasError('zipCode') &&
            state.getValue<String>('address')?.isNotEmpty == true &&
            state.getValue<String>('city')?.isNotEmpty == true &&
            state.getValue<String>('zipCode')?.isNotEmpty == true;
      case 2: // Preferences
        return !state.hasError('terms') &&
            state.getValue<bool>('terms') == true;
      default:
        return false;
    }
  }
}

/// Multi-step form view
class MultiStepFormView extends StatelessWidget {
  const MultiStepFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Step Form'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<MultiStepFormCubit, CoreFormState>(
        builder: (context, state) {
          final cubit = context.read<MultiStepFormCubit>();

          return Column(
            children: [
              // Progress Indicator
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          _buildStepIndicator(
                            context,
                            stepNumber: i + 1,
                            isActive: cubit.currentStep == i,
                            isCompleted:
                                cubit.isStepValid(i) && cubit.currentStep > i,
                            onTap: () => cubit.goToStep(i),
                          ),
                          if (i < 2)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: cubit.currentStep > i
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStepTitle(cubit.currentStep),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Step Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildStepContent(context, cubit.currentStep),
                ),
              ),

              // Navigation Buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (cubit.currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: cubit.previousStep,
                          child: const Text('Previous'),
                        ),
                      ),
                    if (cubit.currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: cubit.currentStep < 2
                            ? (cubit.isStepValid(cubit.currentStep)
                                ? cubit.nextStep
                                : null)
                            : (cubit.isStepValid(2)
                                ? () => _submitForm(context, state)
                                : null),
                        child: Text(cubit.currentStep < 2 ? 'Next' : 'Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context, {
    required int stepNumber,
    required bool isActive,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted
              ? Colors.green
              : isActive
                  ? Colors.blue
                  : Colors.grey.shade300,
        ),
        child: Center(
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Personal Information';
      case 1:
        return 'Address Information';
      case 2:
        return 'Preferences';
      default:
        return '';
    }
  }

  Widget _buildStepContent(BuildContext context, int step) {
    switch (step) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildAddressInfoStep();
      case 2:
        return _buildPreferencesStep();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          FieldWrapper<String>(
            fieldName: 'firstName',
            transformValue: (value) => value.trim(),
            builder: (context, value, error, hasError, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: const Icon(Icons.person),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              );
            },
          ),
          const SizedBox(height: 16),
          FieldWrapper<String>(
            fieldName: 'lastName',
            transformValue: (value) => value.trim(),
            builder: (context, value, error, hasError, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              );
            },
          ),
          const SizedBox(height: 16),
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
                  prefixIcon: const Icon(Icons.email),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Where are you located?',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          FieldWrapper<String>(
            fieldName: 'address',
            builder: (context, value, error, hasError, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Street Address',
                  prefixIcon: const Icon(Icons.home),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FieldWrapper<String>(
                  fieldName: 'city',
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'City',
                        prefixIcon: const Icon(Icons.location_city),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FieldWrapper<String>(
                  fieldName: 'zipCode',
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'ZIP Code',
                        prefixIcon: const Icon(Icons.local_post_office),
                        errorText: hasError ? error : null,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Set your preferences',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Newsletter Frequency',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FieldWrapper<String>(
            fieldName: 'newsletter',
            builder: (context, value, error, hasError, updateValue) {
              return Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Daily'),
                    value: 'daily',
                    groupValue: value,
                    onChanged: updateValue,
                  ),
                  RadioListTile<String>(
                    title: const Text('Weekly'),
                    value: 'weekly',
                    groupValue: value,
                    onChanged: updateValue,
                  ),
                  RadioListTile<String>(
                    title: const Text('Monthly'),
                    value: 'monthly',
                    groupValue: value,
                    onChanged: updateValue,
                  ),
                  RadioListTile<String>(
                    title: const Text('Never'),
                    value: 'never',
                    groupValue: value,
                    onChanged: updateValue,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          FieldWrapper<bool>(
            fieldName: 'notifications',
            builder: (context, value, error, hasError, updateValue) {
              return SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive important updates'),
                value: value ?? false,
                onChanged: updateValue,
              );
            },
          ),
          const SizedBox(height: 16),
          FieldWrapper<bool>(
            fieldName: 'terms',
            builder: (context, value, error, hasError, updateValue) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: const Text('I agree to the Terms and Conditions'),
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
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _submitForm(BuildContext context, CoreFormState state) {
    final formData = {
      'firstName': state.getValue<String>('firstName'),
      'lastName': state.getValue<String>('lastName'),
      'email': state.getValue<String>('email'),
      'address': state.getValue<String>('address'),
      'city': state.getValue<String>('city'),
      'zipCode': state.getValue<String>('zipCode'),
      'newsletter': state.getValue<String>('newsletter'),
      'notifications': state.getValue<bool>('notifications'),
      'terms': state.getValue<bool>('terms'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thank you, ${formData['firstName']} ${formData['lastName']}!',
            ),
            const SizedBox(height: 8),
            const Text('Your multi-step form has been successfully submitted.'),
            const SizedBox(height: 8),
            Text('Email: ${formData['email']}'),
            Text(
              'Address: ${formData['address']}, ${formData['city']} ${formData['zipCode']}',
            ),
            Text('Newsletter: ${formData['newsletter']}'),
            Text('Notifications: ${formData['notifications']}'),
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

    print('Multi-step form data: $formData');
  }
}
