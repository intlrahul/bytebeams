import 'package:bytebeams/core/data/database/app_database.dart';
import 'package:bytebeams/features/geofences/data/geofence_policy.dart';

abstract interface class GeofenceProjector {
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  );
}

final class DuckDbGeofenceProjector implements GeofenceProjector {
  const DuckDbGeofenceProjector();

  @override
  Future<void> rebuild(
    DatabaseTransaction database,
    Iterable<String> vehicleIds,
  ) async {
    final ids = vehicleIds.toSet().toList(growable: false);
    if (ids.isEmpty) return;
    final versions = (await database.query(_versionsQuery))
        .map(_version)
        .toList(growable: false);
    final locations = await database.query(
      _locationsQuery(ids.length),
      parameters: ids,
    );
    final byVehicle = <String, List<_Location>>{};
    for (final row in locations) {
      final location = _Location(
        vehicleId: row[0]! as String,
        packetId: row[1]! as String,
        eventTimestampUtc: row[2]! as DateTime,
        latitude: (row[3]! as num).toDouble(),
        longitude: (row[4]! as num).toDouble(),
        accuracyMeters: (row[5]! as num).toDouble(),
      );
      (byVehicle[location.vehicleId] ??= []).add(location);
    }
    final checkpointRows = await database.query(
      _checkpointsQuery(ids.length),
      parameters: ids,
    );
    final checkpoints = <String, _ReplayCheckpoint>{
      for (final row in checkpointRows)
        row[0]! as String: _ReplayCheckpoint.fromRow(row.sublist(1), versions),
    };
    await database.execute(
      _deleteReplayableTransitions(ids.length),
      parameters: ids,
    );
    await database.execute(
      'DELETE FROM vehicle_geofence_memberships WHERE vehicle_id IN (${List.filled(ids.length, '?').join(', ')})',
      parameters: ids,
    );
    await database.execute(
      'DELETE FROM geofence_transition_candidates WHERE vehicle_id IN (${List.filled(ids.length, '?').join(', ')})',
      parameters: ids,
    );
    final writes = _GeofenceWrites();
    for (final id in ids) {
      final checkpoint = checkpoints[id];
      _rebuildVehicle(
        id,
        byVehicle[id] ?? const [],
        versions,
        initialTarget: checkpoint?.target,
        hasInitialBaseline: checkpoint != null,
        writes: writes,
      );
    }
    await writes.persist(database);
  }

  void _rebuildVehicle(
    String vehicleId,
    List<_Location> locations,
    List<GeofenceVersionRecord> versions, {
    required _Target? initialTarget,
    required bool hasInitialBaseline,
    required _GeofenceWrites writes,
  }) {
    var confirmed = initialTarget;
    _Candidate? candidate;
    var hasBaseline = hasInitialBaseline;
    _Location? lastDecisive;
    for (final location in locations) {
      final target = _targetFor(location, versions);
      if (target == null) continue;
      lastDecisive = location;
      if (_sameTarget(target, confirmed)) {
        confirmed = target;
        candidate = null;
        continue;
      }
      if (candidate == null || !_sameTarget(target, candidate.target)) {
        candidate = _Candidate(target, location);
        continue;
      }
      if (!hasBaseline) {
        hasBaseline = true;
      } else {
        _writeTransitions(
          vehicleId,
          confirmed,
          target,
          candidate.location,
          writes,
        );
      }
      confirmed = target;
      candidate = null;
    }
    if (candidate != null) {
      writes.candidates.add([
        vehicleId,
        candidate.target?.geofence?.id,
        candidate.target?.geofence?.version,
        candidate.location.eventTimestampUtc.toIso8601String(),
        candidate.location.packetId,
        1,
      ]);
    }
    if (hasBaseline && lastDecisive != null) {
      writes.memberships.add([
        vehicleId,
        confirmed?.geofence?.id,
        confirmed?.geofence?.version,
        lastDecisive.eventTimestampUtc.toIso8601String(),
        lastDecisive.packetId,
      ]);
    }
  }

  void _writeTransitions(
    String vehicleId,
    _Target? previous,
    _Target? next,
    _Location firstSupport,
    _GeofenceWrites writes,
  ) {
    if (previous?.geofence != null) {
      _insertTransition(
        vehicleId,
        previous!.geofence!,
        'exit',
        firstSupport,
        writes,
      );
    }
    if (next?.geofence != null) {
      _insertTransition(
        vehicleId,
        next!.geofence!,
        'entry',
        firstSupport,
        writes,
      );
    }
  }

  void _insertTransition(
    String vehicleId,
    GeofenceVersionRecord geofence,
    String type,
    _Location location,
    _GeofenceWrites writes,
  ) => writes.transitions.add([
    '$vehicleId:${geofence.id}:${geofence.version}:$type:${location.eventTimestampUtc.toIso8601String()}:${location.packetId}',
    vehicleId,
    geofence.id,
    geofence.version,
    type,
    location.eventTimestampUtc.toIso8601String(),
    location.packetId,
  ]);

  _Target? _targetFor(
    _Location location,
    List<GeofenceVersionRecord> allVersions,
  ) {
    if (location.accuracyMeters > 100) return null;
    final versions = allVersions.where(
      (version) =>
          version.isActive && version.appliesAt(location.eventTimestampUtc),
    );
    final inside = <({GeofenceVersionRecord geofence, double distance})>[];
    var hasIndeterminate = false;
    for (final version in versions) {
      final state = classifyGeofenceReading(
        geofence: version,
        latitude: location.latitude,
        longitude: location.longitude,
        accuracyMeters: location.accuracyMeters,
      );
      if (state == GeofenceReadingState.inside) {
        inside.add((
          geofence: version,
          distance: distanceMeters(
            location.latitude,
            location.longitude,
            version.latitude,
            version.longitude,
          ),
        ));
      } else if (state == GeofenceReadingState.indeterminate) {
        hasIndeterminate = true;
      }
    }
    if (inside.isNotEmpty) {
      inside.sort((a, b) {
        final radius = a.geofence.radiusMeters.compareTo(
          b.geofence.radiusMeters,
        );
        if (radius != 0) return radius;
        final distance = a.distance.compareTo(b.distance);
        if (distance != 0) return distance;
        return a.geofence.id.compareTo(b.geofence.id);
      });
      return _Target(inside.first.geofence);
    }
    return hasIndeterminate ? null : const _Target.outside();
  }

  bool _sameTarget(_Target? left, _Target? right) {
    if (left == null || right == null) return left == right;
    return left.geofence?.id == right.geofence?.id;
  }

  GeofenceVersionRecord _version(List<Object?> row) => GeofenceVersionRecord(
    id: row[0]! as String,
    version: row[1]! as int,
    latitude: (row[2]! as num).toDouble(),
    longitude: (row[3]! as num).toDouble(),
    radiusMeters: (row[4]! as num).toDouble(),
    isActive: row[5]! as bool,
    effectiveFromUtc: row[6]! as DateTime,
    effectiveUntilUtc: row[7] as DateTime?,
  );

  static const _versionsQuery = '''
SELECT geofence_id, version, latitude, longitude, radius_meters, is_active,
       effective_from_utc, effective_until_utc
FROM geofence_versions
ORDER BY geofence_id ASC, version ASC
''';

  String _locationsQuery(int vehicleCount) =>
      '''
SELECT vehicle_id, packet_id, event_timestamp_utc, latitude, longitude, accuracy_meters
FROM telemetry_events
WHERE vehicle_id IN (${List.filled(vehicleCount, '?').join(', ')})
  AND classification = 'supportedValid'
  AND signal_name = 'location'
ORDER BY vehicle_id ASC, event_timestamp_utc ASC,
         server_received_at_utc ASC NULLS LAST, packet_id ASC
''';

  String _checkpointsQuery(int vehicleCount) =>
      '''
SELECT vehicle_id, geofence_id, geofence_version, checkpoint_at_utc
FROM geofence_replay_checkpoints
WHERE vehicle_id IN (${List.filled(vehicleCount, '?').join(', ')})
''';

  String _deleteReplayableTransitions(int vehicleCount) =>
      '''
DELETE FROM geofence_transitions AS transition
WHERE transition.vehicle_id IN (${List.filled(vehicleCount, '?').join(', ')})
  AND (
    NOT EXISTS (
      SELECT 1 FROM geofence_replay_checkpoints AS checkpoint
      WHERE checkpoint.vehicle_id = transition.vehicle_id
    )
    OR transition.event_timestamp_utc >= (
      SELECT checkpoint_at_utc FROM geofence_replay_checkpoints AS checkpoint
      WHERE checkpoint.vehicle_id = transition.vehicle_id
    )
  )
''';
}

final class _GeofenceWrites {
  final memberships = <List<Object?>>[];
  final candidates = <List<Object?>>[];
  final transitions = <List<Object?>>[];

  Future<void> persist(DatabaseTransaction database) async {
    await _insertAll(
      database,
      'vehicle_geofence_memberships',
      '(vehicle_id, geofence_id, geofence_version, observed_at_utc, packet_id)',
      memberships,
    );
    await _insertAll(
      database,
      'geofence_transition_candidates',
      '(vehicle_id, candidate_geofence_id, candidate_version, first_event_timestamp_utc, first_packet_id, supporting_reading_count)',
      candidates,
    );
    await _insertAll(
      database,
      'geofence_transitions',
      '(transition_id, vehicle_id, geofence_id, geofence_version, transition_type, event_timestamp_utc, packet_id)',
      transitions,
    );
  }

  Future<void> _insertAll(
    DatabaseTransaction database,
    String table,
    String columns,
    List<List<Object?>> values,
  ) async {
    const chunkSize = 100;
    for (var start = 0; start < values.length; start += chunkSize) {
      final end = (start + chunkSize).clamp(0, values.length);
      final chunk = values.sublist(start, end);
      final placeholders = List.filled(
        chunk.length,
        '(${List.filled(chunk.first.length, '?').join(', ')})',
      ).join(', ');
      await database.execute(
        'INSERT INTO $table $columns VALUES $placeholders',
        parameters: [for (final row in chunk) ...row],
      );
    }
  }
}

final class _ReplayCheckpoint {
  const _ReplayCheckpoint(this.target, this.atUtc);

  factory _ReplayCheckpoint.fromRow(
    List<Object?> row,
    List<GeofenceVersionRecord> versions,
  ) {
    final geofenceId = row[0] as String?;
    final version = row[1] as int?;
    final target = geofenceId == null
        ? const _Target.outside()
        : _Target(
            versions.singleWhere(
              (item) => item.id == geofenceId && item.version == version,
            ),
          );
    return _ReplayCheckpoint(target, row[2]! as DateTime);
  }

  final _Target target;
  final DateTime atUtc;
}

final class _Target {
  const _Target(this.geofence);
  const _Target.outside() : geofence = null;
  final GeofenceVersionRecord? geofence;
}

final class _Candidate {
  const _Candidate(this.target, this.location);
  final _Target? target;
  final _Location location;
}

final class _Location {
  const _Location({
    required this.vehicleId,
    required this.packetId,
    required this.eventTimestampUtc,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });
  final String vehicleId;
  final String packetId;
  final DateTime eventTimestampUtc;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
}
