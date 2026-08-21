//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Vehicle {
  /// Returns a new [Vehicle] instance.
  Vehicle({
    required this.vehicleId,

    required this.registrationNumber,

    required this.model,
  });

  @JsonKey(name: r'vehicleId', required: true, includeIfNull: false)
  final String vehicleId;

  @JsonKey(name: r'registrationNumber', required: true, includeIfNull: false)
  final String registrationNumber;

  @JsonKey(name: r'model', required: true, includeIfNull: false)
  final String model;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          other.vehicleId == vehicleId &&
          other.registrationNumber == registrationNumber &&
          other.model == model;

  @override
  int get hashCode =>
      vehicleId.hashCode + registrationNumber.hashCode + model.hashCode;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
