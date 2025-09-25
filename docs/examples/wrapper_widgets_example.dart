import 'package:flutter/material.dart';

/// Example showing how wrapper widgets will work (planned feature)
/// This demonstrates the future API design for easier form building
///
/// NOTE: These classes don't exist yet - this is a design proposal
/// showing how the API would look once wrapper widgets are implemented

/// Planned EasyForm widget - declarative form builder
class EasyForm extends StatefulWidget {
  final List<TypedFormField> fields;
  final Widget child;

  const EasyForm({
    super.key,
    required this.fields,
    required this.child,
  });

  @override
  State<EasyForm> createState() => _EasyFormState();
}

class _EasyFormState extends State<EasyForm> {
  @override
  Widget build(BuildContext context) {
    // This would integrate with CoreFormCubit internally
    return widget.child;
  }
}

/// Planned TypedFormField - same as current but with wrapper integration
class TypedFormField<T> {
  final String name;
  final List<dynamic> validators; // Would be List<Validator<T>>
  final T? initialValue;

  const TypedFormField({
    required this.name,
    required this.validators,
    this.initialValue,
  });
}

/// Planned TypedTextField - type-safe text input wrapper
class TypedTextField<T> extends StatelessWidget {
  final String name;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;

  const TypedTextField({
    super.key,
    required this.name,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    // This would integrate with EasyForm's state management
    return TextFormField(
      decoration: decoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      // Would automatically connect to form state and validation
    );
  }
}

/// Planned TypedDropdown - type-safe dropdown wrapper
class TypedDropdown<T> extends StatelessWidget {
  final String name;
  final InputDecoration? decoration;
  final List<DropdownMenuItem<T>> items;

  const TypedDropdown({
    super.key,
    required this.name,
    this.decoration,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: decoration,
      items: items,
      onChanged: (value) {
        // Would automatically update form state
      },
    );
  }
}

/// Planned TypedCheckbox - type-safe checkbox wrapper
class TypedCheckbox<T> extends StatelessWidget {
  final String name;
  final Widget title;
  final Widget? subtitle;

  const TypedCheckbox({
    super.key,
    required this.name,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: title,
      subtitle: subtitle,
      value: false, // Would come from form state
      onChanged: (value) {
        // Would automatically update form state
      },
    );
  }
}

/// Planned EasyFormSubmitButton - automatic form validation and submission
class EasyFormSubmitButton extends StatelessWidget {
  final Widget child;
  final Function(FormData) onPressed;

  const EasyFormSubmitButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Would automatically validate form and call onPressed with type-safe data
        final formData = FormData(); // Mock data
        onPressed(formData);
      },
      child: child,
    );
  }
}

/// Planned FormData - type-safe form data container
class FormData {
  T? getValue<T>(String fieldName) {
    // Would return type-safe values from form state
    return null;
  }
}

/// Planned EasyFormValidationStatus - validation status indicator
class EasyFormValidationStatus extends StatelessWidget {
  final Widget Function(
      BuildContext context, bool isValid, Map<String, String> errors) builder;

  const EasyFormValidationStatus({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Would get validation state from form
    return builder(context, true, {});
  }
}

/// Example showing the planned wrapper widgets API
class WrapperWidgetsExample extends StatelessWidget {
  const WrapperWidgetsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wrapper Widgets Example (Planned)')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: EasyForm(
          // Define form fields declaratively
          fields: [
            TypedFormField<String>(
              name: 'email',
              validators: [
                // CommonValidators.required<String>(),
                // CommonValidators.email(),
              ],
              initialValue: '',
            ),
            TypedFormField<String>(
              name: 'password',
              validators: [
                // CommonValidators.required<String>(),
                // CommonValidators.minLength(8),
              ],
              initialValue: '',
            ),
            TypedFormField<String>(
              name: 'confirmPassword',
              validators: [
                // CommonValidators.required<String>(),
                // CrossFieldValidators.matches<String>('password'),
              ],
              initialValue: '',
            ),
            TypedFormField<bool>(
              name: 'agreeToTerms',
              validators: [
                // CommonValidators.required<bool>(),
              ],
              initialValue: false,
            ),
            TypedFormField<String>(
              name: 'country',
              validators: [
                // CommonValidators.required<String>(),
              ],
              initialValue: '',
            ),
            TypedFormField<int>(
              name: 'age',
              validators: [
                // CommonValidators.required<int>(),
                // CommonValidators.min(18),
                // CommonValidators.max(120),
              ],
              initialValue: null,
            ),
          ],
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type-safe text field wrapper
                TypedTextField<String>(
                  name: 'email',
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),

                SizedBox(height: 16),

                // Password field with built-in validation display
                TypedTextField<String>(
                  name: 'password',
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a strong password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),

                SizedBox(height: 16),

                // Confirm password with automatic cross-field validation
                TypedTextField<String>(
                  name: 'confirmPassword',
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),

                SizedBox(height: 16),

                // Type-safe dropdown wrapper
                TypedDropdown<String>(
                  name: 'country',
                  decoration: InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.public),
                  ),
                  items: [
                    DropdownMenuItem(value: 'US', child: Text('United States')),
                    DropdownMenuItem(value: 'CA', child: Text('Canada')),
                    DropdownMenuItem(
                        value: 'UK', child: Text('United Kingdom')),
                    DropdownMenuItem(value: 'DE', child: Text('Germany')),
                    DropdownMenuItem(value: 'FR', child: Text('France')),
                  ],
                ),

                SizedBox(height: 16),

                // Type-safe number field
                TypedTextField<int>(
                  name: 'age',
                  decoration: InputDecoration(
                    labelText: 'Age',
                    hintText: 'Enter your age',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),

                SizedBox(height: 16),

                // Type-safe checkbox wrapper
                TypedCheckbox<bool>(
                  name: 'agreeToTerms',
                  title: Text('I agree to the Terms and Conditions'),
                  subtitle: Text('You must agree to continue'),
                ),

                SizedBox(height: 32),

                // Form submit button with automatic validation
                EasyFormSubmitButton(
                  onPressed: (formData) {
                    // formData is type-safe and contains all field values
                    print('Form submitted with data: $formData');

                    // Access type-safe values
                    final email = formData.getValue<String>('email');
                    final age = formData.getValue<int>('age');
                    final agreeToTerms =
                        formData.getValue<bool>('agreeToTerms');

                    // Handle form submission
                    _handleSubmit(email, age, agreeToTerms);
                  },
                  child: Text('Create Account'),
                ),

                SizedBox(height: 16),

                // Form validation status indicator
                EasyFormValidationStatus(
                  builder: (context, isValid, errors) {
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isValid ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isValid ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isValid ? Icons.check_circle : Icons.error,
                            color: isValid ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isValid
                                  ? 'All fields are valid!'
                                  : 'Please fix ${errors.length} error(s)',
                              style: TextStyle(
                                color: isValid
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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

  void _handleSubmit(String? email, int? age, bool? agreeToTerms) {
    // Handle the form submission with type-safe data
    print('Email: $email');
    print('Age: $age');
    print('Agreed to terms: $agreeToTerms');
  }
}

/// Usage examples:
/// 
/// ```dart
/// // This shows how the API would work once wrapper widgets are implemented
/// MaterialApp(home: WrapperWidgetsExample())
/// ```
/// 
/// Key benefits of the planned wrapper widgets:
/// 
/// 1. **Declarative**: Define fields once, use everywhere
/// 2. **Type-safe**: Generic widgets ensure compile-time safety
/// 3. **Automatic validation**: Built-in error display and validation
/// 4. **No boilerplate**: No controllers, no manual state management
/// 5. **Cross-field validation**: Automatic password confirmation, etc.
/// 6. **Consistent API**: All widgets follow the same pattern