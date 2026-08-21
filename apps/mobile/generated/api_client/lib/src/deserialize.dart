import 'package:bytebeams_api/src/model/api_error.dart';
import 'package:bytebeams_api/src/model/bootstrap_response.dart';
import 'package:bytebeams_api/src/model/health_response.dart';
import 'package:bytebeams_api/src/model/location_value.dart';
import 'package:bytebeams_api/src/model/replay_gap.dart';
import 'package:bytebeams_api/src/model/signal_value.dart';
import 'package:bytebeams_api/src/model/telemetry_delivery.dart';
import 'package:bytebeams_api/src/model/telemetry_packet.dart';
import 'package:bytebeams_api/src/model/vehicle.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'ApiError':
      return ApiError.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'BootstrapResponse':
      return BootstrapResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'HealthResponse':
      return HealthResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LocationValue':
      return LocationValue.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReplayGap':
      return ReplayGap.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SignalValue':
      return SignalValue.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'TelemetryDelivery':
      return TelemetryDelivery.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TelemetryPacket':
      return TelemetryPacket.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Vehicle':
      return Vehicle.fromJson(value as Map<String, dynamic>) as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
          value.keys as Iterable<String>,
          value.values.map(
            (dynamic v) => deserialize<BaseType, BaseType>(
              v,
              targetType,
              growable: growable,
            ),
          ),
        ) as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
