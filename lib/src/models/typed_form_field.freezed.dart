// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'typed_form_field.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TypedFormField<T> {
  String get name;
  List<Validator<T>> get validators;
  T? get initialValue;

  /// Create a copy of TypedFormField
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TypedFormFieldCopyWith<T, TypedFormField<T>> get copyWith =>
      _$TypedFormFieldCopyWithImpl<T, TypedFormField<T>>(
          this as TypedFormField<T>, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TypedFormField<T> &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other.validators, validators) &&
            const DeepCollectionEquality()
                .equals(other.initialValue, initialValue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      const DeepCollectionEquality().hash(validators),
      const DeepCollectionEquality().hash(initialValue));

  @override
  String toString() {
    return 'TypedFormField<$T>(name: $name, validators: $validators, initialValue: $initialValue)';
  }
}

/// @nodoc
abstract mixin class $TypedFormFieldCopyWith<T, $Res> {
  factory $TypedFormFieldCopyWith(
          TypedFormField<T> value, $Res Function(TypedFormField<T>) _then) =
      _$TypedFormFieldCopyWithImpl;
  @useResult
  $Res call({String name, List<Validator<T>> validators, T? initialValue});
}

/// @nodoc
class _$TypedFormFieldCopyWithImpl<T, $Res>
    implements $TypedFormFieldCopyWith<T, $Res> {
  _$TypedFormFieldCopyWithImpl(this._self, this._then);

  final TypedFormField<T> _self;
  final $Res Function(TypedFormField<T>) _then;

  /// Create a copy of TypedFormField
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? validators = null,
    Object? initialValue = freezed,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      validators: null == validators
          ? _self.validators
          : validators // ignore: cast_nullable_to_non_nullable
              as List<Validator<T>>,
      initialValue: freezed == initialValue
          ? _self.initialValue
          : initialValue // ignore: cast_nullable_to_non_nullable
              as T?,
    ));
  }
}

/// Adds pattern-matching-related methods to [TypedFormField].
extension TypedFormFieldPatterns<T> on TypedFormField<T> {
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
    TResult Function(_TypedFormField<T> value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TypedFormField() when $default != null:
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
    TResult Function(_TypedFormField<T> value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypedFormField():
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
    TResult? Function(_TypedFormField<T> value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypedFormField() when $default != null:
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
            String name, List<Validator<T>> validators, T? initialValue)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TypedFormField() when $default != null:
        return $default(_that.name, _that.validators, _that.initialValue);
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
            String name, List<Validator<T>> validators, T? initialValue)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypedFormField():
        return $default(_that.name, _that.validators, _that.initialValue);
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
            String name, List<Validator<T>> validators, T? initialValue)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypedFormField() when $default != null:
        return $default(_that.name, _that.validators, _that.initialValue);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TypedFormField<T> extends TypedFormField<T> {
  const _TypedFormField(
      {required this.name,
      required final List<Validator<T>> validators,
      this.initialValue})
      : _validators = validators,
        super._();

  @override
  final String name;
  final List<Validator<T>> _validators;
  @override
  List<Validator<T>> get validators {
    if (_validators is EqualUnmodifiableListView) return _validators;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_validators);
  }

  @override
  final T? initialValue;

  /// Create a copy of TypedFormField
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TypedFormFieldCopyWith<T, _TypedFormField<T>> get copyWith =>
      __$TypedFormFieldCopyWithImpl<T, _TypedFormField<T>>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TypedFormField<T> &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._validators, _validators) &&
            const DeepCollectionEquality()
                .equals(other.initialValue, initialValue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      const DeepCollectionEquality().hash(_validators),
      const DeepCollectionEquality().hash(initialValue));

  @override
  String toString() {
    return 'TypedFormField<$T>(name: $name, validators: $validators, initialValue: $initialValue)';
  }
}

/// @nodoc
abstract mixin class _$TypedFormFieldCopyWith<T, $Res>
    implements $TypedFormFieldCopyWith<T, $Res> {
  factory _$TypedFormFieldCopyWith(
          _TypedFormField<T> value, $Res Function(_TypedFormField<T>) _then) =
      __$TypedFormFieldCopyWithImpl;
  @override
  @useResult
  $Res call({String name, List<Validator<T>> validators, T? initialValue});
}

/// @nodoc
class __$TypedFormFieldCopyWithImpl<T, $Res>
    implements _$TypedFormFieldCopyWith<T, $Res> {
  __$TypedFormFieldCopyWithImpl(this._self, this._then);

  final _TypedFormField<T> _self;
  final $Res Function(_TypedFormField<T>) _then;

  /// Create a copy of TypedFormField
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? validators = null,
    Object? initialValue = freezed,
  }) {
    return _then(_TypedFormField<T>(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      validators: null == validators
          ? _self._validators
          : validators // ignore: cast_nullable_to_non_nullable
              as List<Validator<T>>,
      initialValue: freezed == initialValue
          ? _self.initialValue
          : initialValue // ignore: cast_nullable_to_non_nullable
              as T?,
    ));
  }
}

// dart format on
