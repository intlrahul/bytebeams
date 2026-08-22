import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';

enum FleetStatus { moving, idle, stopped, offline }

enum FleetFilter { all, moving, idle, stopped, offline }

extension FleetFilterPresentation on FleetFilter {
  String get label => switch (this) {
    FleetFilter.all => 'All',
    FleetFilter.moving => 'Moving',
    FleetFilter.idle => 'Idle',
    FleetFilter.stopped => 'Stopped',
    FleetFilter.offline => 'Offline',
  };

  FleetStatus? get status => switch (this) {
    FleetFilter.all => null,
    FleetFilter.moving => FleetStatus.moving,
    FleetFilter.idle => FleetStatus.idle,
    FleetFilter.stopped => FleetStatus.stopped,
    FleetFilter.offline => FleetStatus.offline,
  };
}

final class FleetVehicleRow {
  const FleetVehicleRow({
    required this.vehicleId,
    required this.registrationNumber,
    required this.model,
    required this.status,
    required this.soc,
    required this.rangeKm,
    required this.attentionCount,
  });

  final String vehicleId;
  final String registrationNumber;
  final String model;
  final FleetStatus status;
  final double? soc;
  final double? rangeKm;
  final int attentionCount;

  @override
  bool operator ==(Object other) =>
      other is FleetVehicleRow &&
      other.vehicleId == vehicleId &&
      other.registrationNumber == registrationNumber &&
      other.model == model &&
      other.status == status &&
      other.soc == soc &&
      other.rangeKm == rangeKm &&
      other.attentionCount == attentionCount;

  @override
  int get hashCode => Object.hash(
    vehicleId,
    registrationNumber,
    model,
    status,
    soc,
    rangeKm,
    attentionCount,
  );
}

final class FleetFilterCounts {
  const FleetFilterCounts({
    required this.all,
    required this.moving,
    required this.idle,
    required this.stopped,
    required this.offline,
  });

  final int all;
  final int moving;
  final int idle;
  final int stopped;
  final int offline;

  int forFilter(FleetFilter filter) => switch (filter) {
    FleetFilter.all => all,
    FleetFilter.moving => moving,
    FleetFilter.idle => idle,
    FleetFilter.stopped => stopped,
    FleetFilter.offline => offline,
  };
}

final class FleetHomeSnapshot {
  const FleetHomeSnapshot({required this.rows, required this.counts});

  final List<FleetVehicleRow> rows;
  final FleetFilterCounts counts;
}

sealed class FleetHomeFailure {
  const FleetHomeFailure();

  const factory FleetHomeFailure.persistenceUnavailable() =
      FleetHomePersistenceUnavailable;
}

final class FleetHomePersistenceUnavailable extends FleetHomeFailure {
  const FleetHomePersistenceUnavailable();
}

typedef FleetHomeResult = Result<FleetHomeSnapshot, FleetHomeFailure>;
