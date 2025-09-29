// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'typed_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TypedFormState {
  Map<String, Object?> get values;
  Map<String, String> get errors;
  bool get isValid;
  ValidationType get validationType;
  Map<String, Type> get fieldTypes;

  /// Create a copy of TypedFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TypedFormStateCopyWith<TypedFormState> get copyWith =>
      _$TypedFormStateCopyWithImpl<TypedFormState>(
          this as TypedFormState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TypedFormState &&
            const DeepCollectionEquality().equals(other.values, values) &&
            const DeepCollectionEquality().equals(other.errors, errors) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.validationType, validationType) ||
                other.validationType == validationType) &&
            const DeepCollectionEquality()
                .equals(other.fieldTypes, fieldTypes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(values),
      const DeepCollectionEquality().hash(errors),
      isValid,
      validationType,
      const DeepCollectionEquality().hash(fieldTypes));

  @override
  String toString() {
    return 'TypedFormState(values: $values, errors: $errors, isValid: $isValid, validationType: $validationType, fieldTypes: $fieldTypes)';
  }
}

/// @nodoc
abstract mixin class $TypedFormStateCopyWith<$Res> {
  factory $TypedFormStateCopyWith(
          TypedFormState value, $Res Function(TypedFormState) _then) =
      _$TypedFormStateCopyWithImpl;
  @useResult
  $Res call(
      {Map<String, Object?> values,
      Map<String, String> errors,
      bool isValid,
      ValidationType validationType,
      Map<String, Type> fieldTypes});
}

/// @nodoc
class _$TypedFormStateCopyWithImpl<$Res>
    implements $TypedFormStateCopyWith<$Res> {
  _$TypedFormStateCopyWithImpl(this._self, this._then);

  final TypedFormState _self;
  final $Res Function(TypedFormState) _then;

  /// Create a copy of TypedFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? values = null,
    Object? errors = null,
    Object? isValid = null,
    Object? validationType = null,
    Object? fieldTypes = null,
  }) {
    return _then(_self.copyWith(
      values: null == values
          ? _self.values
          : values // ignore: cast_nullable_to_non_nullable
              as Map<String, Object?>,
      errors: null == errors
          ? _self.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      isValid: null == isValid
          ? _self.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      validationType: null == validationType
          ? _self.validationType
          : validationType // ignore: cast_nullable_to_non_nullable
              as ValidationType,
      fieldTypes: null == fieldTypes
          ? _self.fieldTypes
          : fieldTypes // ignore: cast_nullable_to_non_nullable
              as Map<String, Type>,
    ));
  }
}

/// Adds pattern-matching-related methods to [TypedFormState].
extension TypedFormStatePatterns on TypedFormState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TypedFormState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TypedFormState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TypedFormState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypedFormState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TypedFormState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypedFormState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            Map<String, Object?> values,
            Map<String, String> errors,
            bool isValid,
            ValidationType validationType,
            Map<String, Type> fieldTypes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TypedFormState() when $default != null:
        return $default(_that.values, _that.errors, _that.isValid,
            _that.validationType, _that.fieldTypes);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            Map<String, Object?> values,
            Map<String, String> errors,
            bool isValid,
            ValidationType validationType,
            Map<String, Type> fieldTypes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypedFormState():
        return $default(_that.values, _that.errors, _that.isValid,
            _that.validationType, _that.fieldTypes);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            Map<String, Object?> values,
            Map<String, String> errors,
            bool isValid,
            ValidationType validationType,
            Map<String, Type> fieldTypes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypedFormState() when $default != null:
        return $default(_that.values, _that.errors, _that.isValid,
            _that.validationType, _that.fieldTypes);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TypedFormState extends TypedFormState {
  const _TypedFormState(
      {required final Map<String, Object?> values,
      required final Map<String, String> errors,
      required this.isValid,
      this.validationType = ValidationType.fieldsBeingEdited,
      required final Map<String, Type> fieldTypes})
      : _values = values,
        _errors = errors,
        _fieldTypes = fieldTypes,
        super._();

  final Map<String, Object?> _values;
  @override
  Map<String, Object?> get values {
    if (_values is EqualUnmodifiableMapView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_values);
  }

  final Map<String, String> _errors;
  @override
  Map<String, String> get errors {
    if (_errors is EqualUnmodifiableMapView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_errors);
  }

  @override
  final bool isValid;
  @override
  @JsonKey()
  final ValidationType validationType;
  final Map<String, Type> _fieldTypes;
  @override
  Map<String, Type> get fieldTypes {
    if (_fieldTypes is EqualUnmodifiableMapView) return _fieldTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fieldTypes);
  }

  /// Create a copy of TypedFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TypedFormStateCopyWith<_TypedFormState> get copyWith =>
      __$TypedFormStateCopyWithImpl<_TypedFormState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TypedFormState &&
            const DeepCollectionEquality().equals(other._values, _values) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.validationType, validationType) ||
                other.validationType == validationType) &&
            const DeepCollectionEquality()
                .equals(other._fieldTypes, _fieldTypes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_values),
      const DeepCollectionEquality().hash(_errors),
      isValid,
      validationType,
      const DeepCollectionEquality().hash(_fieldTypes));

  @override
  String toString() {
    return 'TypedFormState(values: $values, errors: $errors, isValid: $isValid, validationType: $validationType, fieldTypes: $fieldTypes)';
  }
}

/// @nodoc
abstract mixin class _$TypedFormStateCopyWith<$Res>
    implements $TypedFormStateCopyWith<$Res> {
  factory _$TypedFormStateCopyWith(
          _TypedFormState value, $Res Function(_TypedFormState) _then) =
      __$TypedFormStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Map<String, Object?> values,
      Map<String, String> errors,
      bool isValid,
      ValidationType validationType,
      Map<String, Type> fieldTypes});
}

/// @nodoc
class __$TypedFormStateCopyWithImpl<$Res>
    implements _$TypedFormStateCopyWith<$Res> {
  __$TypedFormStateCopyWithImpl(this._self, this._then);

  final _TypedFormState _self;
  final $Res Function(_TypedFormState) _then;

  /// Create a copy of TypedFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? values = null,
    Object? errors = null,
    Object? isValid = null,
    Object? validationType = null,
    Object? fieldTypes = null,
  }) {
    return _then(_TypedFormState(
      values: null == values
          ? _self._values
          : values // ignore: cast_nullable_to_non_nullable
              as Map<String, Object?>,
      errors: null == errors
          ? _self._errors
          : errors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      isValid: null == isValid
          ? _self.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      validationType: null == validationType
          ? _self.validationType
          : validationType // ignore: cast_nullable_to_non_nullable
              as ValidationType,
      fieldTypes: null == fieldTypes
          ? _self._fieldTypes
          : fieldTypes // ignore: cast_nullable_to_non_nullable
              as Map<String, Type>,
    ));
  }
}

// dart format on
