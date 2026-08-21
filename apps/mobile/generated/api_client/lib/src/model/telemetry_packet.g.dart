// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_packet.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TelemetryPacketCWProxy {
  TelemetryPacket packetId(String packetId);

  TelemetryPacket vehicleId(String vehicleId);

  TelemetryPacket eventTimestamp(DateTime eventTimestamp);

  TelemetryPacket signalName(String signalName);

  TelemetryPacket value(SignalValue value);

  TelemetryPacket serverReceivedAt(DateTime? serverReceivedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TelemetryPacket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TelemetryPacket(...).copyWith(id: 12, name: "My name")
  /// ````
  TelemetryPacket call({
    String packetId,
    String vehicleId,
    DateTime eventTimestamp,
    String signalName,
    SignalValue value,
    DateTime? serverReceivedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTelemetryPacket.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTelemetryPacket.copyWith.fieldName(...)`
class _$TelemetryPacketCWProxyImpl implements _$TelemetryPacketCWProxy {
  const _$TelemetryPacketCWProxyImpl(this._value);

  final TelemetryPacket _value;

  @override
  TelemetryPacket packetId(String packetId) => this(packetId: packetId);

  @override
  TelemetryPacket vehicleId(String vehicleId) => this(vehicleId: vehicleId);

  @override
  TelemetryPacket eventTimestamp(DateTime eventTimestamp) =>
      this(eventTimestamp: eventTimestamp);

  @override
  TelemetryPacket signalName(String signalName) => this(signalName: signalName);

  @override
  TelemetryPacket value(SignalValue value) => this(value: value);

  @override
  TelemetryPacket serverReceivedAt(DateTime? serverReceivedAt) =>
      this(serverReceivedAt: serverReceivedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TelemetryPacket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TelemetryPacket(...).copyWith(id: 12, name: "My name")
  /// ````
  TelemetryPacket call({
    Object? packetId = const $CopyWithPlaceholder(),
    Object? vehicleId = const $CopyWithPlaceholder(),
    Object? eventTimestamp = const $CopyWithPlaceholder(),
    Object? signalName = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
    Object? serverReceivedAt = const $CopyWithPlaceholder(),
  }) {
    return TelemetryPacket(
      packetId: packetId == const $CopyWithPlaceholder()
          ? _value.packetId
          // ignore: cast_nullable_to_non_nullable
          : packetId as String,
      vehicleId: vehicleId == const $CopyWithPlaceholder()
          ? _value.vehicleId
          // ignore: cast_nullable_to_non_nullable
          : vehicleId as String,
      eventTimestamp: eventTimestamp == const $CopyWithPlaceholder()
          ? _value.eventTimestamp
          // ignore: cast_nullable_to_non_nullable
          : eventTimestamp as DateTime,
      signalName: signalName == const $CopyWithPlaceholder()
          ? _value.signalName
          // ignore: cast_nullable_to_non_nullable
          : signalName as String,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as SignalValue,
      serverReceivedAt: serverReceivedAt == const $CopyWithPlaceholder()
          ? _value.serverReceivedAt
          // ignore: cast_nullable_to_non_nullable
          : serverReceivedAt as DateTime?,
    );
  }
}

extension $TelemetryPacketCopyWith on TelemetryPacket {
  /// Returns a callable class that can be used as follows: `instanceOfTelemetryPacket.copyWith(...)` or like so:`instanceOfTelemetryPacket.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TelemetryPacketCWProxy get copyWith => _$TelemetryPacketCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelemetryPacket _$TelemetryPacketFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TelemetryPacket', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'packetId',
          'vehicleId',
          'eventTimestamp',
          'signalName',
          'value',
        ],
      );
      final val = TelemetryPacket(
        packetId: $checkedConvert('packetId', (v) => v as String),
        vehicleId: $checkedConvert('vehicleId', (v) => v as String),
        eventTimestamp: $checkedConvert(
          'eventTimestamp',
          (v) => DateTime.parse(v as String),
        ),
        signalName: $checkedConvert('signalName', (v) => v as String),
        value: $checkedConvert(
          'value',
          (v) => SignalValue.fromJson(v as Map<String, dynamic>),
        ),
        serverReceivedAt: $checkedConvert(
          'serverReceivedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$TelemetryPacketToJson(TelemetryPacket instance) =>
    <String, dynamic>{
      'packetId': instance.packetId,
      'vehicleId': instance.vehicleId,
      'eventTimestamp': instance.eventTimestamp.toIso8601String(),
      'signalName': instance.signalName,
      'value': instance.value.toJson(),
      'serverReceivedAt': ?instance.serverReceivedAt?.toIso8601String(),
    };
