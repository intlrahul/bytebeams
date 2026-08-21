// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_gap.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReplayGapCWProxy {
  ReplayGap code(ReplayGapCodeEnum code);

  ReplayGap requestedCursor(String requestedCursor);

  ReplayGap oldestAvailableCursor(String oldestAvailableCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReplayGap(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReplayGap(...).copyWith(id: 12, name: "My name")
  /// ````
  ReplayGap call({
    ReplayGapCodeEnum code,
    String requestedCursor,
    String oldestAvailableCursor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReplayGap.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReplayGap.copyWith.fieldName(...)`
class _$ReplayGapCWProxyImpl implements _$ReplayGapCWProxy {
  const _$ReplayGapCWProxyImpl(this._value);

  final ReplayGap _value;

  @override
  ReplayGap code(ReplayGapCodeEnum code) => this(code: code);

  @override
  ReplayGap requestedCursor(String requestedCursor) =>
      this(requestedCursor: requestedCursor);

  @override
  ReplayGap oldestAvailableCursor(String oldestAvailableCursor) =>
      this(oldestAvailableCursor: oldestAvailableCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReplayGap(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReplayGap(...).copyWith(id: 12, name: "My name")
  /// ````
  ReplayGap call({
    Object? code = const $CopyWithPlaceholder(),
    Object? requestedCursor = const $CopyWithPlaceholder(),
    Object? oldestAvailableCursor = const $CopyWithPlaceholder(),
  }) {
    return ReplayGap(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as ReplayGapCodeEnum,
      requestedCursor: requestedCursor == const $CopyWithPlaceholder()
          ? _value.requestedCursor
          // ignore: cast_nullable_to_non_nullable
          : requestedCursor as String,
      oldestAvailableCursor:
          oldestAvailableCursor == const $CopyWithPlaceholder()
          ? _value.oldestAvailableCursor
          // ignore: cast_nullable_to_non_nullable
          : oldestAvailableCursor as String,
    );
  }
}

extension $ReplayGapCopyWith on ReplayGap {
  /// Returns a callable class that can be used as follows: `instanceOfReplayGap.copyWith(...)` or like so:`instanceOfReplayGap.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReplayGapCWProxy get copyWith => _$ReplayGapCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplayGap _$ReplayGapFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ReplayGap',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['code', 'requestedCursor', 'oldestAvailableCursor'],
    );
    final val = ReplayGap(
      code: $checkedConvert(
        'code',
        (v) => $enumDecode(_$ReplayGapCodeEnumEnumMap, v),
      ),
      requestedCursor: $checkedConvert('requestedCursor', (v) => v as String),
      oldestAvailableCursor: $checkedConvert(
        'oldestAvailableCursor',
        (v) => v as String,
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$ReplayGapToJson(ReplayGap instance) => <String, dynamic>{
  'code': _$ReplayGapCodeEnumEnumMap[instance.code]!,
  'requestedCursor': instance.requestedCursor,
  'oldestAvailableCursor': instance.oldestAvailableCursor,
};

const _$ReplayGapCodeEnumEnumMap = {ReplayGapCodeEnum.replayGap: 'replay_gap'};
