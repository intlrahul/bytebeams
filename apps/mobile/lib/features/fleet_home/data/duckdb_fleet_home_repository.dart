import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/fleet_home/data/fleet_home_queries.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_models.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_repository.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';

final class DuckDbFleetHomeRepository implements FleetHomeRepository {
  const DuckDbFleetHomeRepository(this._database);

  final AppDatabase _database;

  @override
  Future<FleetHomeResult> getFleet({
    required FleetFilter filter,
    required DateTime asOfUtc,
  }) async {
    try {
      final freshnessBoundary = asOfUtc
          .subtract(const Duration(minutes: 10))
          .toIso8601String();
      final rows = await _database.query(
        FleetHomeQueries.selectRows,
        parameters: [
          freshnessBoundary,
          freshnessBoundary,
          freshnessBoundary,
          filter.name,
          filter.name,
        ],
      );
      final counts = await _database.query(
        FleetHomeQueries.selectCounts,
        parameters: [freshnessBoundary],
      );
      return Result.success(
        FleetHomeSnapshot(
          rows: rows.map(_toRow).toList(growable: false),
          counts: _toCounts(counts.single),
        ),
      );
    } on DatabaseFailure {
      return const Result.failure(FleetHomeFailure.persistenceUnavailable());
    }
  }

  FleetVehicleRow _toRow(List<Object?> row) => FleetVehicleRow(
    vehicleId: row[0]! as String,
    registrationNumber: row[1]! as String,
    model: row[2]! as String,
    soc: (row[3] as num?)?.toDouble(),
    rangeKm: (row[4] as num?)?.toDouble(),
    status: FleetStatus.values.byName(row[5]! as String),
    attentionCount: (row[6]! as num).toInt(),
  );

  FleetFilterCounts _toCounts(List<Object?> row) => FleetFilterCounts(
    all: (row[0]! as num).toInt(),
    moving: (row[1]! as num).toInt(),
    idle: (row[2]! as num).toInt(),
    stopped: (row[3]! as num).toInt(),
    offline: (row[4]! as num).toInt(),
  );
}
