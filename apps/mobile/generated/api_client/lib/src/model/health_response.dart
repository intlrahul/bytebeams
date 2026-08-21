//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthResponse {
  /// Returns a new [HealthResponse] instance.
  HealthResponse({required this.status});

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final HealthResponseStatusEnum status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthResponse && other.status == status;

  @override
  int get hashCode => status.hashCode;

  factory HealthResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HealthResponseStatusEnum {
  @JsonValue(r'ok')
  ok(r'ok');

  const HealthResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
