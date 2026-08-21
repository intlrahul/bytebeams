//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:bytebeams_api/src/model/telemetry_packet.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'telemetry_delivery.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TelemetryDelivery {
  /// Returns a new [TelemetryDelivery] instance.
  TelemetryDelivery({required this.deliveryId, required this.packet});

  @JsonKey(name: r'deliveryId', required: true, includeIfNull: false)
  final String deliveryId;

  @JsonKey(name: r'packet', required: true, includeIfNull: false)
  final TelemetryPacket packet;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TelemetryDelivery &&
          other.deliveryId == deliveryId &&
          other.packet == packet;

  @override
  int get hashCode => deliveryId.hashCode + packet.hashCode;

  factory TelemetryDelivery.fromJson(Map<String, dynamic> json) =>
      _$TelemetryDeliveryFromJson(json);

  Map<String, dynamic> toJson() => _$TelemetryDeliveryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
