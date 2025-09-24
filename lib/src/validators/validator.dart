import 'package:flutter/material.dart';

/// Base validator interface with generic type support
abstract class Validator<T> {
  const Validator();

  /// Validates a value of type T and returns an error message if validation fails,
  /// or null if validation passes.
  String? validate(T? value, BuildContext context);
}

/// A simple validator implementation for testing purposes
class SimpleValidator<T> extends Validator<T> {
  final String? Function(T? value, BuildContext context) _validator;

  const SimpleValidator(this._validator);

  @override
  String? validate(T? value, BuildContext context) {
    return _validator(value, context);
  }
}
