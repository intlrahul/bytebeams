//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:bytebeams_api/src/model/signal_value.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'telemetry_packet.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TelemetryPacket {
  /// Returns a new [TelemetryPacket] instance.
  TelemetryPacket({
    required this.packetId,

    required this.vehicleId,

    required this.eventTimestamp,

    required this.signalName,

    required this.value,

    this.serverReceivedAt,
  });

  @JsonKey(name: r'packetId', required: true, includeIfNull: false)
  final String packetId;

  @JsonKey(name: r'vehicleId', required: true, includeIfNull: false)
  final String vehicleId;

  @JsonKey(name: r'eventTimestamp', required: true, includeIfNull: false)
  final DateTime eventTimestamp;

  @JsonKey(name: r'signalName', required: true, includeIfNull: false)
  final String signalName;

  @JsonKey(name: r'value', required: true, includeIfNull: false)
  final SignalValue value;

  @JsonKey(name: r'serverReceivedAt', required: false, includeIfNull: false)
  final DateTime? serverReceivedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TelemetryPacket &&
          other.packetId == packetId &&
          other.vehicleId == vehicleId &&
          other.eventTimestamp == eventTimestamp &&
          other.signalName == signalName &&
          other.value == value &&
          other.serverReceivedAt == serverReceivedAt;

  @override
  int get hashCode =>
      packetId.hashCode +
      vehicleId.hashCode +
      eventTimestamp.hashCode +
      signalName.hashCode +
      value.hashCode +
      (serverReceivedAt == null ? 0 : serverReceivedAt.hashCode);

  factory TelemetryPacket.fromJson(Map<String, dynamic> json) =>
      _$TelemetryPacketFromJson(json);

  Map<String, dynamic> toJson() => _$TelemetryPacketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
