// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BootstrapResponseCWProxy {
  BootstrapResponse vehicles(List<Vehicle> vehicles);

  BootstrapResponse telemetry(List<TelemetryPacket> telemetry);

  BootstrapResponse deliveryCursor(String deliveryCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BootstrapResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BootstrapResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BootstrapResponse call({
    List<Vehicle> vehicles,
    List<TelemetryPacket> telemetry,
    String deliveryCursor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBootstrapResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBootstrapResponse.copyWith.fieldName(...)`
class _$BootstrapResponseCWProxyImpl implements _$BootstrapResponseCWProxy {
  const _$BootstrapResponseCWProxyImpl(this._value);

  final BootstrapResponse _value;

  @override
  BootstrapResponse vehicles(List<Vehicle> vehicles) =>
      this(vehicles: vehicles);

  @override
  BootstrapResponse telemetry(List<TelemetryPacket> telemetry) =>
      this(telemetry: telemetry);

  @override
  BootstrapResponse deliveryCursor(String deliveryCursor) =>
      this(deliveryCursor: deliveryCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BootstrapResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BootstrapResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BootstrapResponse call({
    Object? vehicles = const $CopyWithPlaceholder(),
    Object? telemetry = const $CopyWithPlaceholder(),
    Object? deliveryCursor = const $CopyWithPlaceholder(),
  }) {
    return BootstrapResponse(
      vehicles: vehicles == const $CopyWithPlaceholder()
          ? _value.vehicles
          // ignore: cast_nullable_to_non_nullable
          : vehicles as List<Vehicle>,
      telemetry: telemetry == const $CopyWithPlaceholder()
          ? _value.telemetry
          // ignore: cast_nullable_to_non_nullable
          : telemetry as List<TelemetryPacket>,
      deliveryCursor: deliveryCursor == const $CopyWithPlaceholder()
          ? _value.deliveryCursor
          // ignore: cast_nullable_to_non_nullable
          : deliveryCursor as String,
    );
  }
}

extension $BootstrapResponseCopyWith on BootstrapResponse {
  /// Returns a callable class that can be used as follows: `instanceOfBootstrapResponse.copyWith(...)` or like so:`instanceOfBootstrapResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BootstrapResponseCWProxy get copyWith =>
      _$BootstrapResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BootstrapResponse _$BootstrapResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BootstrapResponse', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['vehicles', 'telemetry', 'deliveryCursor'],
      );
      final val = BootstrapResponse(
        vehicles: $checkedConvert(
          'vehicles',
          (v) => (v as List<dynamic>)
              .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        telemetry: $checkedConvert(
          'telemetry',
          (v) => (v as List<dynamic>)
              .map((e) => TelemetryPacket.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        deliveryCursor: $checkedConvert('deliveryCursor', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$BootstrapResponseToJson(BootstrapResponse instance) =>
    <String, dynamic>{
      'vehicles': instance.vehicles.map((e) => e.toJson()).toList(),
      'telemetry': instance.telemetry.map((e) => e.toJson()).toList(),
      'deliveryCursor': instance.deliveryCursor,
    };
