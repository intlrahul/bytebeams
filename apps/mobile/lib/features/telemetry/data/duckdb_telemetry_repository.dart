import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/core/data/database/database_failure.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_repository.dart';
import 'package:bytebeams/features/telemetry/data/telemetry_queries.dart';

final class DuckDbTelemetryRepository implements TelemetryRepository {
  const DuckDbTelemetryRepository(this._database);
  final AppDatabase _database;

  @override
  Future<Result<bool, TelemetryFailure>> store(
    ClassifiedTelemetryPacket packet,
  ) async {
    try {
      final value = packet.value;
      final rows = await _database.query(
        insertTelemetryEvent,
        parameters: [
          packet.packetId,
          packet.vehicleId,
          packet.eventTimestampUtc.toIso8601String(),
          packet.serverReceivedAtUtc?.toIso8601String(),
          packet.clientReceivedAtUtc.toIso8601String(),
          packet.signalName,
          packet.classification.name,
          packet.rawValueJson,
          packet.validationError,
          value is TelemetryNumberValue ? value.value : null,
          value is TelemetryBooleanValue ? value.value : null,
          value is TelemetryLocationValue ? value.latitude : null,
          value is TelemetryLocationValue ? value.longitude : null,
          value is TelemetryLocationValue ? value.accuracyMeters : null,
        ],
      );
      return Result.success(rows.isNotEmpty);
    } on DatabaseFailure {
      return const Result.failure(TelemetryFailure.persistenceUnavailable());
    }
  }

  @override
  Future<Result<List<ClassifiedTelemetryPacket>, TelemetryFailure>>
  diagnosticsForVehicle(String vehicleId) async {
    try {
      final rows = await _database.query(
        selectTelemetryDiagnosticsForVehicle,
        parameters: [vehicleId],
      );
      return Result.success(
        rows
            .map(
              (row) => ClassifiedTelemetryPacket(
                packetId: row[0]! as String,
                vehicleId: row[1]! as String,
                eventTimestampUtc: _utc(row[2]!),
                clientReceivedAtUtc: _utc(row[3]!),
                signalName: row[4]! as String,
                rawValueJson: row[5]! as String,
                classification: TelemetryClassification.values.byName(
                  row[6]! as String,
                ),
                serverReceivedAtUtc: row[7] == null ? null : _utc(row[7]!),
                validationError: row[8] as String?,
              ),
            )
            .toList(),
      );
    } on DatabaseFailure {
      return const Result.failure(TelemetryFailure.persistenceUnavailable());
    }
  }

  DateTime _utc(Object value) => value is DateTime
      ? value.toUtc()
      : DateTime.parse(value as String).toUtc();
}
