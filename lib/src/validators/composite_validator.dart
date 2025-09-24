import 'package:flutter/material.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

/// A composite validator that combines multiple validators and runs them in sequence.
/// It stops at the first validation error encountered.
class CompositeValidator<T> implements Validator<T> {
  /// Creates a composite validator with the given list of validators.
  CompositeValidator(this.validators);

  /// The list of validators to run in sequence.
  final List<Validator<T>> validators;

  @override
  String? validate(T? value, BuildContext context) {
    for (final validator in validators) {
      final result = validator.validate(value, context);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
