import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Multi-step form using FieldWrapper<T> and BLoC for state management
/// This demonstrates complex form flows with cross-field validation
class MultiStepForm extends StatelessWidget {
  const MultiStepForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MultiStepFormCubit(),
      child: MultiStepFormView(),
    );
  }
}

/// Form Cubit managing all steps and validation
class MultiStepFormCubit extends CoreFormCubit {
  MultiStepFormCubit()
      : super(
          fields: [
            // Step 1: Personal Information
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

            // Step 2: Security
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
              ],
              initialValue: '',
            ),

            // Step 3: Address
            TypedFormField<String>(
              name: 'address',
              validators: [
                CommonValidators.required<String>(),
                CommonValidators.minLength(5),
              ],
              initialValue: '',
            ),
            TypedFormField<String>(
              name: 'city',
              validators: [
                CommonValidators.required<String>(),
                CommonValidators.minLength(2),
              ],
              initialValue: '',
            ),
            TypedFormField<String>(
              name: 'zipCode',
              validators: [
                CommonValidators.required<String>(),
                CommonValidators.pattern(
                  RegExp(r'^\d{5}(-\d{4})?$'),
                  errorText: 'Invalid ZIP code format',
                ),
              ],
              initialValue: '',
            ),
            TypedFormField<String>(
              name: 'country',
              validators: [
                CommonValidators.required<String>(),
              ],
              initialValue: 'United States',
            ),
          ],
          validationType: ValidationType.fieldsBeingEdited,
        );

  /// Validate specific step fields
  bool validateStep(int step, BuildContext context) {
    final stepFields = _getStepFields(step);
    bool isStepValid = true;

    for (final fieldName in stepFields) {
      final value = state.values[fieldName];

      // For password confirmation, do cross-field validation
      if (fieldName == 'confirmPassword') {
        final password = state.values['password'] as String?;
        final confirmPassword = value as String?;

        if (confirmPassword != null && confirmPassword.isNotEmpty) {
          if (password != confirmPassword) {
            updateError(
              fieldName: fieldName,
              errorMessage: 'Passwords do not match',
              context: context,
            );
            isStepValid = false;
            continue;
          }
        }
      }

      // Trigger normal field validation by updating the field
      updateField(fieldName: fieldName, value: value, context: context);

      // Check if field has error after validation
      if (state.hasError(fieldName)) {
        isStepValid = false;
      }
    }

    return isStepValid;
  }

  List<String> _getStepFields(int step) {
    switch (step) {
      case 0:
        return ['firstName', 'lastName', 'email', 'phone'];
      case 1:
        return ['password', 'confirmPassword'];
      case 2:
        return ['address', 'city', 'zipCode', 'country'];
      default:
        return [];
    }
  }

  /// Get validation status for a specific step
  bool isStepValid(int step) {
    final stepFields = _getStepFields(step);
    return stepFields.every((fieldName) => !state.hasError(fieldName));
  }

  /// Submit the complete form
  void submitForm(BuildContext context) {
    validateForm(
      context,
      onValidationPass: () {
        final userData = {
          'firstName': state.getValue<String>('firstName'),
          'lastName': state.getValue<String>('lastName'),
          'email': state.getValue<String>('email'),
          'phone': state.getValue<String>('phone'),
          'password': state.getValue<String>('password'),
          'address': state.getValue<String>('address'),
          'city': state.getValue<String>('city'),
          'zipCode': state.getValue<String>('zipCode'),
          'country': state.getValue<String>('country'),
        };

        _performRegistration(userData, context);
      },
      onValidationFail: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fix all errors before submitting'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _performRegistration(
      Map<String, dynamic> userData, BuildContext context) {
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome ${userData['firstName']} ${userData['lastName']}!'),
            SizedBox(height: 8),
            Text('Your account has been created successfully.'),
            SizedBox(height: 8),
            Text('Email: ${userData['email']}'),
            Text('Phone: ${userData['phone']}'),
            Text(
                'Address: ${userData['address']}, ${userData['city']} ${userData['zipCode']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );

    // TODO: Send data to your backend
    print('Registration data: $userData');
  }
}

/// Multi-step form view with FieldWrapper integration
class MultiStepFormView extends StatefulWidget {
  const MultiStepFormView({super.key});

  @override
  _MultiStepFormViewState createState() => _MultiStepFormViewState();
}

class _MultiStepFormViewState extends State<MultiStepFormView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Step Registration'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: BlocBuilder<MultiStepFormCubit, CoreFormState>(
            builder: (context, state) {
              return LinearProgressIndicator(
                value: (_currentStep + 1) / _totalSteps,
                backgroundColor: Colors.grey[300],
              );
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: List.generate(_totalSteps, (index) {
                return Expanded(
                  child: BlocBuilder<MultiStepFormCubit, CoreFormState>(
                    builder: (context, state) {
                      final cubit = context.read<MultiStepFormCubit>();
                      final isCompleted = index < _currentStep;
                      final isCurrent = index == _currentStep;
                      final isValid = cubit.isStepValid(index);

                      Color backgroundColor;
                      Color textColor;
                      IconData? icon;

                      if (isCompleted && isValid) {
                        backgroundColor = Colors.green;
                        textColor = Colors.white;
                        icon = Icons.check;
                      } else if (isCurrent) {
                        backgroundColor = Colors.blue;
                        textColor = Colors.white;
                      } else if (isCompleted && !isValid) {
                        backgroundColor = Colors.red;
                        textColor = Colors.white;
                        icon = Icons.error;
                      } else {
                        backgroundColor = Colors.grey[300]!;
                        textColor = Colors.grey[600]!;
                      }

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, color: textColor, size: 16),
                              SizedBox(width: 4),
                            ],
                            Text(
                              'Step ${index + 1}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),

          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: EdgeInsets.all(16),
            child: BlocBuilder<MultiStepFormCubit, CoreFormState>(
              builder: (context, state) {
                final cubit = context.read<MultiStepFormCubit>();
                final canProceed = cubit.isStepValid(_currentStep);

                return Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          child: Text('Previous'),
                        ),
                      ),
                    if (_currentStep > 0) SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canProceed
                            ? (_currentStep == _totalSteps - 1
                                ? _submitForm
                                : _nextStep)
                            : null,
                        child: Text(_currentStep == _totalSteps - 1
                            ? 'Submit'
                            : 'Next'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Step 1 of 3 - Tell us about yourself',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 24),

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
              debounceTime: Duration(milliseconds: 500),
              transformValue: (value) => value.toLowerCase().trim(),
              builder: (context, value, error, hasError, updateValue) {
                return TextFormField(
                  initialValue: value,
                  onChanged: updateValue,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    errorText: hasError ? error : null,
                    border: OutlineInputBorder(),
                    helperText: 'We\'ll use this to send you updates',
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
                    prefixIcon: Icon(Icons.phone),
                    errorText: hasError ? error : null,
                    border: OutlineInputBorder(),
                    hintText: '(555) 123-4567',
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Step 2 of 3 - Create a secure password',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 24),

            // Password with FieldWrapper
            FieldWrapper<String>(
              fieldName: 'password',
              builder: (context, value, error, hasError, updateValue) {
                return TextFormField(
                  initialValue: value,
                  onChanged: updateValue,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                    prefixIcon: Icon(Icons.lock_outline),
                    errorText: hasError ? error : null,
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                );
              },
            ),

            SizedBox(height: 24),

            // Password Requirements
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Password Requirements',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('• At least 8 characters'),
                  Text('• One uppercase letter (A-Z)'),
                  Text('• One lowercase letter (a-z)'),
                  Text('• One number (0-9)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Step 3 of 3 - Where should we send your information?',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 24),

            // Address with FieldWrapper
            FieldWrapper<String>(
              fieldName: 'address',
              transformValue: (value) => value.trim(),
              builder: (context, value, error, hasError, updateValue) {
                return TextFormField(
                  initialValue: value,
                  onChanged: updateValue,
                  decoration: InputDecoration(
                    labelText: 'Street Address',
                    prefixIcon: Icon(Icons.home),
                    errorText: hasError ? error : null,
                    border: OutlineInputBorder(),
                    hintText: '123 Main Street',
                  ),
                  textInputAction: TextInputAction.next,
                );
              },
            ),

            SizedBox(height: 16),

            // City and ZIP Code row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FieldWrapper<String>(
                    fieldName: 'city',
                    transformValue: (value) => value.trim(),
                    builder: (context, value, error, hasError, updateValue) {
                      return TextFormField(
                        initialValue: value,
                        onChanged: updateValue,
                        decoration: InputDecoration(
                          labelText: 'City',
                          prefixIcon: Icon(Icons.location_city),
                          errorText: hasError ? error : null,
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: FieldWrapper<String>(
                    fieldName: 'zipCode',
                    builder: (context, value, error, hasError, updateValue) {
                      return TextFormField(
                        initialValue: value,
                        onChanged: updateValue,
                        decoration: InputDecoration(
                          labelText: 'ZIP Code',
                          prefixIcon: Icon(Icons.markunread_mailbox),
                          errorText: hasError ? error : null,
                          border: OutlineInputBorder(),
                          hintText: '12345',
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Country Dropdown with FieldWrapper
            FieldWrapper<String>(
              fieldName: 'country',
              builder: (context, value, error, hasError, updateValue) {
                return DropdownButtonFormField<String>(
                  initialValue: value?.isEmpty == true ? null : value,
                  onChanged: updateValue,
                  decoration: InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.public),
                    errorText: hasError ? error : null,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'United States', child: Text('United States')),
                    DropdownMenuItem(value: 'Canada', child: Text('Canada')),
                    DropdownMenuItem(
                        value: 'United Kingdom', child: Text('United Kingdom')),
                    DropdownMenuItem(value: 'Germany', child: Text('Germany')),
                    DropdownMenuItem(value: 'France', child: Text('France')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                );
              },
            ),

            SizedBox(height: 24),

            // Summary with BLoC state
            BlocBuilder<MultiStepFormCubit, CoreFormState>(
              builder: (context, state) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Review Your Information',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                          'Name: ${state.getValue<String>('firstName')} ${state.getValue<String>('lastName')}'),
                      Text('Email: ${state.getValue<String>('email')}'),
                      Text('Phone: ${state.getValue<String>('phone')}'),
                      Text(
                          'Address: ${state.getValue<String>('address')}, ${state.getValue<String>('city')} ${state.getValue<String>('zipCode')}'),
                      Text('Country: ${state.getValue<String>('country')}'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    final cubit = context.read<MultiStepFormCubit>();

    if (cubit.validateStep(_currentStep, context) &&
        _currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() {
    final cubit = context.read<MultiStepFormCubit>();
    cubit.submitForm(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// Key Benefits of Multi-Step Forms with FieldWrapper:
/// 
/// 1. **Step-by-Step Validation**: Each step validates independently
/// 2. **Visual Progress**: Users see their progress and validation status
/// 3. **Cross-Field Validation**: Password confirmation works across steps
/// 4. **State Persistence**: Form data persists when navigating between steps
/// 5. **Type Safety**: All form values are type-safe and accessible
/// 6. **Reactive UI**: Step indicators update based on validation status
/// 7. **Clean Architecture**: BLoC manages complex form state
/// 8. **User Experience**: Clear feedback and intuitive navigation

/// Usage:
/// 
/// ```dart
/// MaterialApp(home: MultiStepForm())
/// ```