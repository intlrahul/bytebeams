//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_value.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocationValue {
  /// Returns a new [LocationValue] instance.
  LocationValue({
    required this.latitude,

    required this.longitude,

    required this.accuracyMeters,
  });

  // minimum: -90
  // maximum: 90
  @JsonKey(name: r'latitude', required: true, includeIfNull: false)
  final double latitude;

  // minimum: -180
  // maximum: 180
  @JsonKey(name: r'longitude', required: true, includeIfNull: false)
  final double longitude;

  // minimum: 0
  @JsonKey(name: r'accuracyMeters', required: true, includeIfNull: false)
  final double accuracyMeters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationValue &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.accuracyMeters == accuracyMeters;

  @override
  int get hashCode =>
      latitude.hashCode + longitude.hashCode + accuracyMeters.hashCode;

  factory LocationValue.fromJson(Map<String, dynamic> json) =>
      _$LocationValueFromJson(json);

  Map<String, dynamic> toJson() => _$LocationValueToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
