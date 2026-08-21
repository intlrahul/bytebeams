//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:bytebeams_api/src/model/location_value.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'signal_value.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SignalValue {
  /// Returns a new [SignalValue] instance.
  SignalValue({
    required this.kind,

    this.numberValue,

    this.booleanValue,

    this.stringValue,

    this.locationValue,

    this.jsonValue,
  });

  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final SignalValueKindEnum kind;

  @JsonKey(name: r'numberValue', required: false, includeIfNull: false)
  final double? numberValue;

  @JsonKey(name: r'booleanValue', required: false, includeIfNull: false)
  final bool? booleanValue;

  @JsonKey(name: r'stringValue', required: false, includeIfNull: false)
  final String? stringValue;

  @JsonKey(name: r'locationValue', required: false, includeIfNull: false)
  final LocationValue? locationValue;

  @JsonKey(name: r'jsonValue', required: false, includeIfNull: false)
  final Map<String, Object>? jsonValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignalValue &&
          other.kind == kind &&
          other.numberValue == numberValue &&
          other.booleanValue == booleanValue &&
          other.stringValue == stringValue &&
          other.locationValue == locationValue &&
          other.jsonValue == jsonValue;

  @override
  int get hashCode =>
      kind.hashCode +
      (numberValue == null ? 0 : numberValue.hashCode) +
      (booleanValue == null ? 0 : booleanValue.hashCode) +
      (stringValue == null ? 0 : stringValue.hashCode) +
      locationValue.hashCode +
      (jsonValue == null ? 0 : jsonValue.hashCode);

  factory SignalValue.fromJson(Map<String, dynamic> json) =>
      _$SignalValueFromJson(json);

  Map<String, dynamic> toJson() => _$SignalValueToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum SignalValueKindEnum {
  @JsonValue(r'number')
  number(r'number'),
  @JsonValue(r'boolean')
  boolean(r'boolean'),
  @JsonValue(r'string')
  string(r'string'),
  @JsonValue(r'location')
  location(r'location'),
  @JsonValue(r'null')
  null_(r'null'),
  @JsonValue(r'json')
  json(r'json');

  const SignalValueKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
