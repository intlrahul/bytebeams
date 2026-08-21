//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:bytebeams_api/src/model/vehicle.dart';
import 'package:bytebeams_api/src/model/telemetry_packet.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bootstrap_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BootstrapResponse {
  /// Returns a new [BootstrapResponse] instance.
  BootstrapResponse({
    required this.vehicles,

    required this.telemetry,

    required this.deliveryCursor,
  });

  @JsonKey(name: r'vehicles', required: true, includeIfNull: false)
  final List<Vehicle> vehicles;

  @JsonKey(name: r'telemetry', required: true, includeIfNull: false)
  final List<TelemetryPacket> telemetry;

  @JsonKey(name: r'deliveryCursor', required: true, includeIfNull: false)
  final String deliveryCursor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BootstrapResponse &&
          other.vehicles == vehicles &&
          other.telemetry == telemetry &&
          other.deliveryCursor == deliveryCursor;

  @override
  int get hashCode =>
      vehicles.hashCode + telemetry.hashCode + deliveryCursor.hashCode;

  factory BootstrapResponse.fromJson(Map<String, dynamic> json) =>
      _$BootstrapResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BootstrapResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
