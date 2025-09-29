import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:typed_form_fields/src/validators/composite_validator.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

part 'form_field_definition.freezed.dart';

@freezed
abstract class FormFieldDefinition<T> with _$FormFieldDefinition<T> {
  const factory FormFieldDefinition({
    required String name,
    required List<Validator<T>> validators,
    T? initialValue,
  }) = _FormFieldDefinition<T>;

  const FormFieldDefinition._();

  /// Get the runtime type of the field value
  Type get valueType => T;

  /// Create a validator for this field
  Validator<T> createValidator() => CompositeValidator<T>(validators);
}
