import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'validator_localizations.dart';

/// A [LocalizationsDelegate] for [ValidatorLocalizations].
///
/// This delegate is responsible for loading the appropriate localizations
/// for the validator error messages based on the current locale.
class ValidatorLocalizationsDelegate
    extends LocalizationsDelegate<ValidatorLocalizations> {
  const ValidatorLocalizationsDelegate();

  /// A static instance of the delegate for convenience.
  static const ValidatorLocalizationsDelegate delegate =
      ValidatorLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Currently supporting English, but can be extended for other languages
    return _supportedLocales.contains(locale.languageCode);
  }

  @override
  Future<ValidatorLocalizations> load(Locale locale) {
    return SynchronousFuture<ValidatorLocalizations>(_getLocalizations(locale));
  }

  @override
  bool shouldReload(ValidatorLocalizationsDelegate old) => false;

  /// List of supported language codes.
  static const List<String> _supportedLocales = [
    'en', // English
    'es', // Spanish
    'fr', // French
    'de', // German
    'it', // Italian
    'pt', // Portuguese
    'ru', // Russian
    'ja', // Japanese
    'ko', // Korean
    'zh', // Chinese
    'ar', // Arabic
  ];

  /// Returns the appropriate localizations for the given [locale].
  ValidatorLocalizations _getLocalizations(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return const DefaultValidatorLocalizations();
      case 'es':
        return const SpanishValidatorLocalizations();
      case 'fr':
        return const FrenchValidatorLocalizations();
      case 'de':
        return const GermanValidatorLocalizations();
      case 'it':
        return const ItalianValidatorLocalizations();
      case 'pt':
        return const PortugueseValidatorLocalizations();
      case 'ru':
        return const RussianValidatorLocalizations();
      case 'ja':
        return const JapaneseValidatorLocalizations();
      case 'ko':
        return const KoreanValidatorLocalizations();
      case 'zh':
        return const ChineseValidatorLocalizations();
      case 'ar':
        return const ArabicValidatorLocalizations();
      default:
        return const DefaultValidatorLocalizations();
    }
  }
}

/// Spanish implementation of [ValidatorLocalizations].
class SpanishValidatorLocalizations extends ValidatorLocalizations {
  const SpanishValidatorLocalizations();

  @override
  Locale get locale => const Locale('es');

  @override
  String get requiredFieldError => 'Este campo es obligatorio.';

  @override
  String get invalidEmailError =>
      'Por favor, introduce una dirección de correo válida.';

  @override
  String minLengthError(int minLength) =>
      'Debe tener al menos $minLength caracteres.';

  @override
  String maxLengthError(int maxLength) =>
      'Debe tener como máximo $maxLength caracteres.';

  @override
  String get invalidNumberError => 'Por favor, introduce un número válido.';

  @override
  String minValueError(num minValue) => 'Debe ser al menos $minValue.';

  @override
  String maxValueError(num maxValue) => 'Debe ser como máximo $maxValue.';

  @override
  String get invalidPatternError => 'Por favor, introduce un formato válido.';

  @override
  String get invalidUrlError => 'Por favor, introduce una URL válida.';

  @override
  String get invalidPhoneError =>
      'Por favor, introduce un número de teléfono válido.';

  @override
  String get invalidCreditCardError =>
      'Por favor, introduce un número de tarjeta de crédito válido.';

  @override
  String get invalidDateError => 'Por favor, introduce una fecha válida.';

  @override
  String get invalidIpError => 'Por favor, introduce una dirección IP válida.';

  @override
  String get invalidUuidError => 'Por favor, introduce un UUID válido.';

  @override
  String get invalidJsonError => 'Por favor, introduce JSON válido.';

  @override
  String get invalidAlphanumericError => 'Solo se permiten letras y números.';

  @override
  String get invalidAlphabeticError => 'Solo se permiten letras.';

  @override
  String get conditionalValidationError =>
      'Este campo es obligatorio según otras selecciones.';

  @override
  String get fieldsMismatchError => 'Los campos no coinciden.';

  @override
  String get asyncValidationError => 'La validación falló.';
}

/// French implementation of [ValidatorLocalizations].
class FrenchValidatorLocalizations extends ValidatorLocalizations {
  const FrenchValidatorLocalizations();

  @override
  Locale get locale => const Locale('fr');

  @override
  String get requiredFieldError => 'Ce champ est obligatoire.';

  @override
  String get invalidEmailError => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String minLengthError(int minLength) =>
      'Doit contenir au moins $minLength caractères.';

  @override
  String maxLengthError(int maxLength) =>
      'Doit contenir au maximum $maxLength caractères.';

  @override
  String get invalidNumberError => 'Veuillez saisir un nombre valide.';

  @override
  String minValueError(num minValue) => 'Doit être au moins $minValue.';

  @override
  String maxValueError(num maxValue) => 'Doit être au maximum $maxValue.';

  @override
  String get invalidPatternError => 'Veuillez saisir un format valide.';

  @override
  String get invalidUrlError => 'Veuillez saisir une URL valide.';

  @override
  String get invalidPhoneError =>
      'Veuillez saisir un numéro de téléphone valide.';

  @override
  String get invalidCreditCardError =>
      'Veuillez saisir un numéro de carte de crédit valide.';

  @override
  String get invalidDateError => 'Veuillez saisir une date valide.';

  @override
  String get invalidIpError => 'Veuillez saisir une adresse IP valide.';

  @override
  String get invalidUuidError => 'Veuillez saisir un UUID valide.';

  @override
  String get invalidJsonError => 'Veuillez saisir du JSON valide.';

  @override
  String get invalidAlphanumericError =>
      'Seules les lettres et les chiffres sont autorisés.';

  @override
  String get invalidAlphabeticError => 'Seules les lettres sont autorisées.';

  @override
  String get conditionalValidationError =>
      'Ce champ est obligatoire selon d\'autres sélections.';

  @override
  String get fieldsMismatchError => 'Les champs ne correspondent pas.';

  @override
  String get asyncValidationError => 'La validation a échoué.';
}

/// German implementation of [ValidatorLocalizations].
class GermanValidatorLocalizations extends ValidatorLocalizations {
  const GermanValidatorLocalizations();

  @override
  Locale get locale => const Locale('de');

  @override
  String get requiredFieldError => 'Dieses Feld ist erforderlich.';

  @override
  String get invalidEmailError =>
      'Bitte geben Sie eine gültige E-Mail-Adresse ein.';

  @override
  String minLengthError(int minLength) =>
      'Muss mindestens $minLength Zeichen lang sein.';

  @override
  String maxLengthError(int maxLength) =>
      'Darf höchstens $maxLength Zeichen lang sein.';

  @override
  String get invalidNumberError => 'Bitte geben Sie eine gültige Zahl ein.';

  @override
  String minValueError(num minValue) => 'Muss mindestens $minValue sein.';

  @override
  String maxValueError(num maxValue) => 'Darf höchstens $maxValue sein.';

  @override
  String get invalidPatternError => 'Bitte geben Sie ein gültiges Format ein.';

  @override
  String get invalidUrlError => 'Bitte geben Sie eine gültige URL ein.';

  @override
  String get invalidPhoneError =>
      'Bitte geben Sie eine gültige Telefonnummer ein.';

  @override
  String get invalidCreditCardError =>
      'Bitte geben Sie eine gültige Kreditkartennummer ein.';

  @override
  String get invalidDateError => 'Bitte geben Sie ein gültiges Datum ein.';

  @override
  String get invalidIpError => 'Bitte geben Sie eine gültige IP-Adresse ein.';

  @override
  String get invalidUuidError => 'Bitte geben Sie eine gültige UUID ein.';

  @override
  String get invalidJsonError => 'Bitte geben Sie gültiges JSON ein.';

  @override
  String get invalidAlphanumericError =>
      'Nur Buchstaben und Zahlen sind erlaubt.';

  @override
  String get invalidAlphabeticError => 'Nur Buchstaben sind erlaubt.';

  @override
  String get conditionalValidationError =>
      'Dieses Feld ist basierend auf anderen Auswahlen erforderlich.';

  @override
  String get fieldsMismatchError => 'Die Felder stimmen nicht überein.';

  @override
  String get asyncValidationError => 'Validierung fehlgeschlagen.';
}

// Placeholder implementations for other languages
// These can be expanded with proper translations later

class ItalianValidatorLocalizations extends DefaultValidatorLocalizations {
  const ItalianValidatorLocalizations();
  @override
  Locale get locale => const Locale('it');
}

class PortugueseValidatorLocalizations extends DefaultValidatorLocalizations {
  const PortugueseValidatorLocalizations();
  @override
  Locale get locale => const Locale('pt');
}

class RussianValidatorLocalizations extends DefaultValidatorLocalizations {
  const RussianValidatorLocalizations();
  @override
  Locale get locale => const Locale('ru');
}

class JapaneseValidatorLocalizations extends DefaultValidatorLocalizations {
  const JapaneseValidatorLocalizations();
  @override
  Locale get locale => const Locale('ja');
}

class KoreanValidatorLocalizations extends DefaultValidatorLocalizations {
  const KoreanValidatorLocalizations();
  @override
  Locale get locale => const Locale('ko');
}

class ChineseValidatorLocalizations extends DefaultValidatorLocalizations {
  const ChineseValidatorLocalizations();
  @override
  Locale get locale => const Locale('zh');
}

/// Arabic implementation of [ValidatorLocalizations].
class ArabicValidatorLocalizations extends ValidatorLocalizations {
  const ArabicValidatorLocalizations();

  @override
  Locale get locale => const Locale('ar');

  @override
  String get requiredFieldError => 'هذا الحقل مطلوب.';

  @override
  String get invalidEmailError => 'يرجى إدخال عنوان بريد إلكتروني صحيح.';

  @override
  String minLengthError(int minLength) =>
      'يجب أن يكون على الأقل $minLength حرفاً.';

  @override
  String maxLengthError(int maxLength) =>
      'يجب أن يكون على الأكثر $maxLength حرفاً.';

  @override
  String get invalidNumberError => 'يرجى إدخال رقم صحيح.';

  @override
  String minValueError(num minValue) => 'يجب أن يكون على الأقل $minValue.';

  @override
  String maxValueError(num maxValue) => 'يجب أن يكون على الأكثر $maxValue.';

  @override
  String get invalidPatternError => 'يرجى إدخال تنسيق صحيح.';

  @override
  String get invalidUrlError => 'يرجى إدخال رابط صحيح.';

  @override
  String get invalidPhoneError => 'يرجى إدخال رقم هاتف صحيح.';

  @override
  String get invalidCreditCardError => 'يرجى إدخال رقم بطاقة ائتمان صحيح.';

  @override
  String get invalidDateError => 'يرجى إدخال تاريخ صحيح.';

  @override
  String get invalidIpError => 'يرجى إدخال عنوان IP صحيح.';

  @override
  String get invalidUuidError => 'يرجى إدخال UUID صحيح.';

  @override
  String get invalidJsonError => 'يرجى إدخال JSON صحيح.';

  @override
  String get invalidAlphanumericError => 'يُسمح بالأحرف والأرقام فقط.';

  @override
  String get invalidAlphabeticError => 'يُسمح بالأحرف فقط.';

  @override
  String get conditionalValidationError =>
      'هذا الحقل مطلوب بناءً على اختيارات أخرى.';

  @override
  String get fieldsMismatchError => 'الحقول غير متطابقة.';

  @override
  String get asyncValidationError => 'فشل في التحقق.';
}
