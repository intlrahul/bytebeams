//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_error.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiError {
  /// Returns a new [ApiError] instance.
  ApiError({required this.code, required this.message, this.diagnosticId});

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'diagnosticId', required: false, includeIfNull: false)
  final String? diagnosticId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiError &&
          other.code == code &&
          other.message == message &&
          other.diagnosticId == diagnosticId;

  @override
  int get hashCode =>
      code.hashCode +
      message.hashCode +
      (diagnosticId == null ? 0 : diagnosticId.hashCode);

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
