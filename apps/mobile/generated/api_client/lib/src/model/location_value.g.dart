// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_value.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LocationValueCWProxy {
  LocationValue latitude(double latitude);

  LocationValue longitude(double longitude);

  LocationValue accuracyMeters(double accuracyMeters);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LocationValue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LocationValue(...).copyWith(id: 12, name: "My name")
  /// ````
  LocationValue call({
    double latitude,
    double longitude,
    double accuracyMeters,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLocationValue.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLocationValue.copyWith.fieldName(...)`
class _$LocationValueCWProxyImpl implements _$LocationValueCWProxy {
  const _$LocationValueCWProxyImpl(this._value);

  final LocationValue _value;

  @override
  LocationValue latitude(double latitude) => this(latitude: latitude);

  @override
  LocationValue longitude(double longitude) => this(longitude: longitude);

  @override
  LocationValue accuracyMeters(double accuracyMeters) =>
      this(accuracyMeters: accuracyMeters);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LocationValue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LocationValue(...).copyWith(id: 12, name: "My name")
  /// ````
  LocationValue call({
    Object? latitude = const $CopyWithPlaceholder(),
    Object? longitude = const $CopyWithPlaceholder(),
    Object? accuracyMeters = const $CopyWithPlaceholder(),
  }) {
    return LocationValue(
      latitude: latitude == const $CopyWithPlaceholder()
          ? _value.latitude
          // ignore: cast_nullable_to_non_nullable
          : latitude as double,
      longitude: longitude == const $CopyWithPlaceholder()
          ? _value.longitude
          // ignore: cast_nullable_to_non_nullable
          : longitude as double,
      accuracyMeters: accuracyMeters == const $CopyWithPlaceholder()
          ? _value.accuracyMeters
          // ignore: cast_nullable_to_non_nullable
          : accuracyMeters as double,
    );
  }
}

extension $LocationValueCopyWith on LocationValue {
  /// Returns a callable class that can be used as follows: `instanceOfLocationValue.copyWith(...)` or like so:`instanceOfLocationValue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LocationValueCWProxy get copyWith => _$LocationValueCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationValue _$LocationValueFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LocationValue', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['latitude', 'longitude', 'accuracyMeters'],
      );
      final val = LocationValue(
        latitude: $checkedConvert('latitude', (v) => (v as num).toDouble()),
        longitude: $checkedConvert('longitude', (v) => (v as num).toDouble()),
        accuracyMeters: $checkedConvert(
          'accuracyMeters',
          (v) => (v as num).toDouble(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LocationValueToJson(LocationValue instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracyMeters': instance.accuracyMeters,
    };
