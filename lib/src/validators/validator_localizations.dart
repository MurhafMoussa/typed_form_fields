import 'package:flutter/widgets.dart';

/// Abstract class that defines the interface for validator localizations.
///
/// This class provides localized error messages for form validators.
/// Implementations should provide translations for all required messages.
abstract class ValidatorLocalizations {
  const ValidatorLocalizations();

  /// The current locale for these localizations.
  Locale get locale;

  /// Retrieves the [ValidatorLocalizations] from the given [context].
  ///
  /// Returns the localized validator messages for the current locale.
  /// If no localizations are found, returns [DefaultValidatorLocalizations].
  static ValidatorLocalizations of(BuildContext context) {
    final localizations = Localizations.of(context, ValidatorLocalizations);
    return localizations ?? const DefaultValidatorLocalizations();
  }

  // Required field validation messages
  String get requiredFieldError => 'This field is required.';

  // Email validation messages
  String get invalidEmailError => 'Please enter a valid email address.';

  // Length validation messages
  String minLengthError(int minLength) =>
      'Must be at least $minLength characters long.';
  String maxLengthError(int maxLength) =>
      'Must be at most $maxLength characters long.';

  // Numeric validation messages
  String get invalidNumberError => 'Please enter a valid number.';
  String minValueError(num minValue) => 'Must be at least $minValue.';
  String maxValueError(num maxValue) => 'Must be at most $maxValue.';

  // Pattern validation messages
  String get invalidPatternError => 'Please enter a valid format.';

  // URL validation messages
  String get invalidUrlError => 'Please enter a valid URL.';

  // Phone validation messages
  String get invalidPhoneError => 'Please enter a valid phone number.';

  // Credit card validation messages
  String get invalidCreditCardError =>
      'Please enter a valid credit card number.';

  // Date validation messages
  String get invalidDateError => 'Please enter a valid date.';

  // IP address validation messages
  String get invalidIpError => 'Please enter a valid IP address.';

  // UUID validation messages
  String get invalidUuidError => 'Please enter a valid UUID.';

  // JSON validation messages
  String get invalidJsonError => 'Please enter valid JSON.';

  // Alphanumeric validation messages
  String get invalidAlphanumericError =>
      'Only letters and numbers are allowed.';

  // Alphabetic validation messages
  String get invalidAlphabeticError => 'Only letters are allowed.';

  // Conditional validation messages
  String get conditionalValidationError =>
      'This field is required based on other selections.';

  // Cross-field validation messages
  String get fieldsMismatchError => 'Fields do not match.';

  // Async validation messages
  String get asyncValidationError => 'Validation failed.';
}

/// Default English implementation of [ValidatorLocalizations].
///
/// This class provides English error messages for all validators.
/// It serves as the fallback when no other localizations are available.
class DefaultValidatorLocalizations extends ValidatorLocalizations {
  const DefaultValidatorLocalizations();

  @override
  Locale get locale => const Locale('en');

  @override
  String get requiredFieldError => 'This field is required.';

  @override
  String get invalidEmailError => 'Please enter a valid email address.';

  @override
  String minLengthError(int minLength) =>
      'Must be at least $minLength characters long.';

  @override
  String maxLengthError(int maxLength) =>
      'Must be at most $maxLength characters long.';

  @override
  String get invalidNumberError => 'Please enter a valid number.';

  @override
  String minValueError(num minValue) => 'Must be at least $minValue.';

  @override
  String maxValueError(num maxValue) => 'Must be at most $maxValue.';

  @override
  String get invalidPatternError => 'Please enter a valid format.';

  @override
  String get invalidUrlError => 'Please enter a valid URL.';

  @override
  String get invalidPhoneError => 'Please enter a valid phone number.';

  @override
  String get invalidCreditCardError =>
      'Please enter a valid credit card number.';

  @override
  String get invalidDateError => 'Please enter a valid date.';

  @override
  String get invalidIpError => 'Please enter a valid IP address.';

  @override
  String get invalidUuidError => 'Please enter a valid UUID.';

  @override
  String get invalidJsonError => 'Please enter valid JSON.';

  @override
  String get invalidAlphanumericError =>
      'Only letters and numbers are allowed.';

  @override
  String get invalidAlphabeticError => 'Only letters are allowed.';

  @override
  String get conditionalValidationError =>
      'This field is required based on other selections.';

  @override
  String get fieldsMismatchError => 'Fields do not match.';

  @override
  String get asyncValidationError => 'Validation failed.';
}
