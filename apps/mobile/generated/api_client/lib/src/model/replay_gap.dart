//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'replay_gap.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReplayGap {
  /// Returns a new [ReplayGap] instance.
  ReplayGap({
    required this.code,

    required this.requestedCursor,

    required this.oldestAvailableCursor,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final ReplayGapCodeEnum code;

  @JsonKey(name: r'requestedCursor', required: true, includeIfNull: false)
  final String requestedCursor;

  @JsonKey(name: r'oldestAvailableCursor', required: true, includeIfNull: false)
  final String oldestAvailableCursor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReplayGap &&
          other.code == code &&
          other.requestedCursor == requestedCursor &&
          other.oldestAvailableCursor == oldestAvailableCursor;

  @override
  int get hashCode =>
      code.hashCode + requestedCursor.hashCode + oldestAvailableCursor.hashCode;

  factory ReplayGap.fromJson(Map<String, dynamic> json) =>
      _$ReplayGapFromJson(json);

  Map<String, dynamic> toJson() => _$ReplayGapToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReplayGapCodeEnum {
  @JsonValue(r'replay_gap')
  replayGap(r'replay_gap');

  const ReplayGapCodeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
