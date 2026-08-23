import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';

enum TripStatus { inProgress, completed }

extension TripStatusPresentation on TripStatus {
  String get label => switch (this) {
    TripStatus.inProgress => 'In progress',
    TripStatus.completed => 'Completed',
  };
}

final class Trip {
  const Trip({
    required this.id,
    required this.vehicleId,
    required this.registrationNumber,
    required this.origin,
    this.destination,
    required this.startedAtUtc,
    this.completedAtUtc,
    required this.status,
  });
  final String id;
  final String vehicleId;
  final String registrationNumber;
  final String origin;
  final String? destination;
  final DateTime startedAtUtc;
  final DateTime? completedAtUtc;
  final TripStatus status;
}

sealed class TripFailure {
  const TripFailure();
}

final class TripPersistenceUnavailable extends TripFailure {
  const TripPersistenceUnavailable();
}

typedef TripResult = Result<List<Trip>, TripFailure>;
