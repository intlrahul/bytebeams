import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';

enum VehicleReadingSignal { soc, range, speed, batteryTemp, odometer, lastPing }

enum VehicleReadingVerdict { normal, alert, stale }

final class VehicleReading {
  const VehicleReading({
    required this.signal,
    required this.value,
    required this.reportedAtUtc,
    required this.verdict,
  });

  final VehicleReadingSignal signal;
  final double? value;
  final DateTime? reportedAtUtc;
  final VehicleReadingVerdict? verdict;

  bool get hasReported => reportedAtUtc != null;
}

final class SocHistoryPoint {
  const SocHistoryPoint({required this.eventTimestampUtc, required this.soc});

  final DateTime eventTimestampUtc;
  final double soc;
}

final class VehicleDetail {
  const VehicleDetail({
    required this.vehicleId,
    required this.registrationNumber,
    required this.model,
    required this.asOfUtc,
    required this.readings,
    required this.socHistory,
    this.recentTrips = const [],
    this.hasMoreTrips = false,
    this.geofenceName,
  });

  final String vehicleId;
  final String registrationNumber;
  final String model;
  final DateTime asOfUtc;
  final List<VehicleReading> readings;
  final List<SocHistoryPoint> socHistory;
  final List<VehicleRecentTrip> recentTrips;
  final bool hasMoreTrips;
  final String? geofenceName;
}

final class VehicleRecentTrip {
  const VehicleRecentTrip({
    required this.origin,
    this.destination,
    required this.startedAtUtc,
  });
  final String origin;
  final String? destination;
  final DateTime startedAtUtc;
}

sealed class VehicleDetailFailure {
  const VehicleDetailFailure();

  const factory VehicleDetailFailure.notFound() = VehicleDetailNotFound;
  const factory VehicleDetailFailure.persistenceUnavailable() =
      VehicleDetailPersistenceUnavailable;
}

final class VehicleDetailNotFound extends VehicleDetailFailure {
  const VehicleDetailNotFound();
}

final class VehicleDetailPersistenceUnavailable extends VehicleDetailFailure {
  const VehicleDetailPersistenceUnavailable();
}

typedef VehicleDetailResult = Result<VehicleDetail, VehicleDetailFailure>;
