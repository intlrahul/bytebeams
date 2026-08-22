import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/vehicle_detail/data/vehicle_detail_queries.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_repository.dart';

final class DuckDbVehicleDetailRepository implements VehicleDetailRepository {
  const DuckDbVehicleDetailRepository(this._database);

  final AppDatabase _database;

  @override
  Future<VehicleDetailResult> getVehicleDetail({
    required String vehicleId,
    required DateTime asOfUtc,
  }) async {
    try {
      final vehicle = await _database.query(
        VehicleDetailQueries.selectVehicle,
        parameters: [vehicleId],
      );
      if (vehicle.isEmpty) {
        return const Result.failure(VehicleDetailFailure.notFound());
      }
      final readings = await _database.query(
        VehicleDetailQueries.selectLatestReadings,
        parameters: [vehicleId],
      );
      final history = await _database.query(
        VehicleDetailQueries.selectSocHistory,
        parameters: [
          vehicleId,
          asOfUtc.subtract(const Duration(hours: 24)).toIso8601String(),
        ],
      );
      final row = vehicle.single;
      return Result.success(
        VehicleDetail(
          vehicleId: row[0]! as String,
          registrationNumber: row[1]! as String,
          model: row[2]! as String,
          geofenceName: row[3] as String?,
          asOfUtc: asOfUtc,
          readings: _readings(readings, asOfUtc),
          socHistory: history
              .map(
                (point) => SocHistoryPoint(
                  eventTimestampUtc: point[0]! as DateTime,
                  soc: (point[1]! as num).toDouble(),
                ),
              )
              .toList(growable: false),
        ),
      );
    } on DatabaseFailure {
      return const Result.failure(
        VehicleDetailFailure.persistenceUnavailable(),
      );
    }
  }

  List<VehicleReading> _readings(List<List<Object?>> rows, DateTime asOfUtc) {
    final bySignal = <String, List<Object?>>{
      for (final row in rows) row[0]! as String: row,
    };
    return VehicleReadingSignal.values
        .map((signal) {
          final row = bySignal[_name(signal)];
          if (row == null) {
            return VehicleReading(
              signal: signal,
              value: null,
              reportedAtUtc: null,
              verdict: null,
            );
          }
          final value = (row[1] as num?)?.toDouble();
          final reportedAtUtc = row[2]! as DateTime;
          return VehicleReading(
            signal: signal,
            value: value,
            reportedAtUtc: reportedAtUtc,
            verdict: _verdict(signal, value, reportedAtUtc, asOfUtc),
          );
        })
        .toList(growable: false);
  }

  VehicleReadingVerdict _verdict(
    VehicleReadingSignal signal,
    double? value,
    DateTime reportedAtUtc,
    DateTime asOfUtc,
  ) {
    if (reportedAtUtc.isBefore(asOfUtc.subtract(const Duration(minutes: 10)))) {
      return VehicleReadingVerdict.stale;
    }
    if ((signal == VehicleReadingSignal.soc && value! < 20) ||
        (signal == VehicleReadingSignal.batteryTemp && value! > 45)) {
      return VehicleReadingVerdict.alert;
    }
    return VehicleReadingVerdict.normal;
  }

  String _name(VehicleReadingSignal signal) => switch (signal) {
    VehicleReadingSignal.soc => 'soc',
    VehicleReadingSignal.range => 'range',
    VehicleReadingSignal.speed => 'speed',
    VehicleReadingSignal.batteryTemp => 'battery_temp',
    VehicleReadingSignal.odometer => 'odometer',
    VehicleReadingSignal.lastPing => 'last_ping',
  };
}
