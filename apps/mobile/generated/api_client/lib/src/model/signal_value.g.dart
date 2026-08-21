// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_value.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SignalValueCWProxy {
  SignalValue kind(SignalValueKindEnum kind);

  SignalValue numberValue(double? numberValue);

  SignalValue booleanValue(bool? booleanValue);

  SignalValue stringValue(String? stringValue);

  SignalValue locationValue(LocationValue? locationValue);

  SignalValue jsonValue(Map<String, Object>? jsonValue);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SignalValue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SignalValue(...).copyWith(id: 12, name: "My name")
  /// ````
  SignalValue call({
    SignalValueKindEnum kind,
    double? numberValue,
    bool? booleanValue,
    String? stringValue,
    LocationValue? locationValue,
    Map<String, Object>? jsonValue,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSignalValue.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSignalValue.copyWith.fieldName(...)`
class _$SignalValueCWProxyImpl implements _$SignalValueCWProxy {
  const _$SignalValueCWProxyImpl(this._value);

  final SignalValue _value;

  @override
  SignalValue kind(SignalValueKindEnum kind) => this(kind: kind);

  @override
  SignalValue numberValue(double? numberValue) =>
      this(numberValue: numberValue);

  @override
  SignalValue booleanValue(bool? booleanValue) =>
      this(booleanValue: booleanValue);

  @override
  SignalValue stringValue(String? stringValue) =>
      this(stringValue: stringValue);

  @override
  SignalValue locationValue(LocationValue? locationValue) =>
      this(locationValue: locationValue);

  @override
  SignalValue jsonValue(Map<String, Object>? jsonValue) =>
      this(jsonValue: jsonValue);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SignalValue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SignalValue(...).copyWith(id: 12, name: "My name")
  /// ````
  SignalValue call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? numberValue = const $CopyWithPlaceholder(),
    Object? booleanValue = const $CopyWithPlaceholder(),
    Object? stringValue = const $CopyWithPlaceholder(),
    Object? locationValue = const $CopyWithPlaceholder(),
    Object? jsonValue = const $CopyWithPlaceholder(),
  }) {
    return SignalValue(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as SignalValueKindEnum,
      numberValue: numberValue == const $CopyWithPlaceholder()
          ? _value.numberValue
          // ignore: cast_nullable_to_non_nullable
          : numberValue as double?,
      booleanValue: booleanValue == const $CopyWithPlaceholder()
          ? _value.booleanValue
          // ignore: cast_nullable_to_non_nullable
          : booleanValue as bool?,
      stringValue: stringValue == const $CopyWithPlaceholder()
          ? _value.stringValue
          // ignore: cast_nullable_to_non_nullable
          : stringValue as String?,
      locationValue: locationValue == const $CopyWithPlaceholder()
          ? _value.locationValue
          // ignore: cast_nullable_to_non_nullable
          : locationValue as LocationValue?,
      jsonValue: jsonValue == const $CopyWithPlaceholder()
          ? _value.jsonValue
          // ignore: cast_nullable_to_non_nullable
          : jsonValue as Map<String, Object>?,
    );
  }
}

extension $SignalValueCopyWith on SignalValue {
  /// Returns a callable class that can be used as follows: `instanceOfSignalValue.copyWith(...)` or like so:`instanceOfSignalValue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SignalValueCWProxy get copyWith => _$SignalValueCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignalValue _$SignalValueFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SignalValue', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['kind']);
  final val = SignalValue(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(_$SignalValueKindEnumEnumMap, v),
    ),
    numberValue: $checkedConvert('numberValue', (v) => (v as num?)?.toDouble()),
    booleanValue: $checkedConvert('booleanValue', (v) => v as bool?),
    stringValue: $checkedConvert('stringValue', (v) => v as String?),
    locationValue: $checkedConvert(
      'locationValue',
      (v) =>
          v == null ? null : LocationValue.fromJson(v as Map<String, dynamic>),
    ),
    jsonValue: $checkedConvert(
      'jsonValue',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$SignalValueToJson(SignalValue instance) =>
    <String, dynamic>{
      'kind': _$SignalValueKindEnumEnumMap[instance.kind]!,
      'numberValue': ?instance.numberValue,
      'booleanValue': ?instance.booleanValue,
      'stringValue': ?instance.stringValue,
      'locationValue': ?instance.locationValue?.toJson(),
      'jsonValue': ?instance.jsonValue,
    };

const _$SignalValueKindEnumEnumMap = {
  SignalValueKindEnum.number: 'number',
  SignalValueKindEnum.boolean: 'boolean',
  SignalValueKindEnum.string: 'string',
  SignalValueKindEnum.location: 'location',
  SignalValueKindEnum.null_: 'null',
  SignalValueKindEnum.json: 'json',
};
