import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Complete example showing FieldWrapper<T> in action
/// This demonstrates the universal form integration capabilities
class FieldWrapperExample extends StatelessWidget {
  const FieldWrapperExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FieldWrapper<T> Example')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (context) => CoreFormCubit(
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
                name: 'subscribe',
                validators: [],
                initialValue: false,
              ),
              TypedFormField<double>(
                name: 'rating',
                validators: [
                  SimpleValidator<double>((value, context) =>
                      value != null && value >= 1.0
                          ? null
                          : 'Rating must be at least 1.0'),
                  SimpleValidator<double>((value, context) =>
                      value != null && value <= 5.0
                          ? null
                          : 'Rating must be at most 5.0'),
                ],
                initialValue: 3.0,
              ),
              TypedFormField<String>(
                name: 'country',
                validators: [
                  CommonValidators.required<String>(),
                ],
                initialValue: '',
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'FieldWrapper<T> Universal Form Integration',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'FieldWrapper works with ANY Flutter widget - TextField, Checkbox, Slider, Dropdown, and even custom widgets!',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                SizedBox(height: 32),

                // 1. TextField with FieldWrapper
                _buildSectionTitle('1. TextField with Email Validation'),
                FieldWrapper<String>(
                  fieldName: 'email',
                  transformValue: (value) => value.toLowerCase().trim(),
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email),
                        errorText: hasError ? error : null,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    );
                  },
                ),

                SizedBox(height: 24),

                // 2. Password field with debouncing
                _buildSectionTitle('2. Password Field with Debouncing'),
                FieldWrapper<String>(
                  fieldName: 'password',
                  debounceTime:
                      Duration(milliseconds: 500), // Debounced validation
                  builder: (context, value, error, hasError, updateValue) {
                    return TextFormField(
                      initialValue: value,
                      onChanged: updateValue,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Minimum 8 characters',
                        prefixIcon: Icon(Icons.lock),
                        errorText: hasError ? error : null,
                        border: OutlineInputBorder(),
                        helperText: 'Validation is debounced by 500ms',
                      ),
                      obscureText: true,
                    );
                  },
                ),

                SizedBox(height: 24),

                // 3. Checkbox with FieldWrapper
                _buildSectionTitle('3. Checkbox Integration'),
                FieldWrapper<bool>(
                  fieldName: 'subscribe',
                  builder: (context, value, error, hasError, updateValue) {
                    return CheckboxListTile(
                      title: Text('Subscribe to newsletter'),
                      subtitle: hasError
                          ? Text(error!, style: TextStyle(color: Colors.red))
                          : null,
                      value: value ?? false,
                      onChanged: updateValue,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),

                SizedBox(height: 24),

                // 4. Slider with FieldWrapper
                _buildSectionTitle('4. Slider with Validation'),
                FieldWrapper<double>(
                  fieldName: 'rating',
                  builder: (context, value, error, hasError, updateValue) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Rating: ${(value ?? 3.0).toStringAsFixed(1)} / 5.0'),
                        Slider(
                          value: value ?? 3.0,
                          min: 0.0,
                          max: 5.0,
                          divisions: 50,
                          onChanged: updateValue,
                        ),
                        if (hasError)
                          Text(
                            error!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 24),

                // 5. Dropdown with FieldWrapper
                _buildSectionTitle('5. Dropdown Integration'),
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
                            value: 'US', child: Text('United States')),
                        DropdownMenuItem(value: 'CA', child: Text('Canada')),
                        DropdownMenuItem(
                            value: 'UK', child: Text('United Kingdom')),
                        DropdownMenuItem(value: 'DE', child: Text('Germany')),
                        DropdownMenuItem(value: 'FR', child: Text('France')),
                      ],
                    );
                  },
                ),

                SizedBox(height: 32),

                // Form status and submit
                BlocBuilder<CoreFormCubit, CoreFormState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        // Form validation status
                        Container(
                          padding: EdgeInsets.all(16),
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
                                      ? 'All fields are valid!'
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

                        // Submit button
                        ElevatedButton(
                          onPressed: state.isValid
                              ? () => _submitForm(context, state)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Submit Form',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Debug info
                        if (state.values.isNotEmpty) ...[
                          ExpansionTile(
                            title: Text('Debug: Form Values'),
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
                                        'Subscribe: ${state.getValue<bool>('subscribe')}'),
                                    Text(
                                        'Rating: ${state.getValue<double>('rating')}'),
                                    Text(
                                        'Country: ${state.getValue<String>('country')}'),
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  void _submitForm(BuildContext context, CoreFormState state) {
    // Type-safe access to form values
    final formData = {
      'email': state.getValue<String>('email'),
      'password': state.getValue<String>('password'),
      'subscribe': state.getValue<bool>('subscribe'),
      'rating': state.getValue<double>('rating'),
      'country': state.getValue<String>('country'),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Form Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Form data (type-safe):'),
            SizedBox(height: 8),
            Text('Email: ${formData['email']}'),
            Text('Password: [hidden]'),
            Text('Subscribe: ${formData['subscribe']}'),
            Text('Rating: ${formData['rating']}'),
            Text('Country: ${formData['country']}'),
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
  }
}

/// Custom widget example with FieldWrapper
class CustomRatingWidget extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String? errorText;

  const CustomRatingWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Custom Rating Widget'),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () => onChanged((index + 1).toDouble()),
              icon: Icon(
                index < value ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
            );
          }),
        ),
        if (errorText != null)
          Text(
            errorText!,
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }
}

/// Example showing FieldWrapper with custom widget
class CustomWidgetExample extends StatelessWidget {
  const CustomWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoreFormCubit(
        fields: [
          TypedFormField<double>(
            name: 'customRating',
            validators: [
              SimpleValidator<double>((value, context) =>
                  value != null && value >= 1.0
                      ? null
                      : 'Rating must be at least 1.0'),
            ],
            initialValue: 0.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text('FieldWrapper with Custom Widget'),
          SizedBox(height: 16),
          FieldWrapper<double>(
            fieldName: 'customRating',
            builder: (context, value, error, hasError, updateValue) {
              return CustomRatingWidget(
                value: value ?? 0.0,
                onChanged: updateValue,
                errorText: hasError ? error : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Usage:
/// 
/// ```dart
/// // Basic FieldWrapper example
/// MaterialApp(home: FieldWrapperExample())
/// 
/// // Custom widget integration
/// MaterialApp(home: CustomWidgetExample())
/// ```
