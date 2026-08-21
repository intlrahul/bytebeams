// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_delivery.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TelemetryDeliveryCWProxy {
  TelemetryDelivery deliveryId(String deliveryId);

  TelemetryDelivery packet(TelemetryPacket packet);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TelemetryDelivery(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TelemetryDelivery(...).copyWith(id: 12, name: "My name")
  /// ````
  TelemetryDelivery call({String deliveryId, TelemetryPacket packet});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTelemetryDelivery.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTelemetryDelivery.copyWith.fieldName(...)`
class _$TelemetryDeliveryCWProxyImpl implements _$TelemetryDeliveryCWProxy {
  const _$TelemetryDeliveryCWProxyImpl(this._value);

  final TelemetryDelivery _value;

  @override
  TelemetryDelivery deliveryId(String deliveryId) =>
      this(deliveryId: deliveryId);

  @override
  TelemetryDelivery packet(TelemetryPacket packet) => this(packet: packet);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TelemetryDelivery(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TelemetryDelivery(...).copyWith(id: 12, name: "My name")
  /// ````
  TelemetryDelivery call({
    Object? deliveryId = const $CopyWithPlaceholder(),
    Object? packet = const $CopyWithPlaceholder(),
  }) {
    return TelemetryDelivery(
      deliveryId: deliveryId == const $CopyWithPlaceholder()
          ? _value.deliveryId
          // ignore: cast_nullable_to_non_nullable
          : deliveryId as String,
      packet: packet == const $CopyWithPlaceholder()
          ? _value.packet
          // ignore: cast_nullable_to_non_nullable
          : packet as TelemetryPacket,
    );
  }
}

extension $TelemetryDeliveryCopyWith on TelemetryDelivery {
  /// Returns a callable class that can be used as follows: `instanceOfTelemetryDelivery.copyWith(...)` or like so:`instanceOfTelemetryDelivery.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TelemetryDeliveryCWProxy get copyWith =>
      _$TelemetryDeliveryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelemetryDelivery _$TelemetryDeliveryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TelemetryDelivery', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['deliveryId', 'packet']);
      final val = TelemetryDelivery(
        deliveryId: $checkedConvert('deliveryId', (v) => v as String),
        packet: $checkedConvert(
          'packet',
          (v) => TelemetryPacket.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TelemetryDeliveryToJson(TelemetryDelivery instance) =>
    <String, dynamic>{
      'deliveryId': instance.deliveryId,
      'packet': instance.packet.toJson(),
    };
