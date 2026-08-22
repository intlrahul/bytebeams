import 'package:bytebeams/core/design/sparkee/sparkee_theme.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/geofences/domain/geofence_models.dart';
import 'package:bytebeams/features/geofences/domain/geofence_repository.dart';
import 'package:bytebeams/features/geofences/domain/geofence_use_cases.dart';
import 'package:bytebeams/features/geofences/presentation/geofence_bloc.dart';
import 'package:bytebeams/features/geofences/presentation/geofence_page.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given_persisted_geofence_when_rendered_then_supports_edit_and_deactivate',
    (tester) async {
      final repository = _Repository();
      final events = AsyncAppEventBus();
      addTearDown(events.close);
      await tester.pumpWidget(
        MaterialApp(
          theme: SparkeeTheme.light(),
          home: GeofencePage(createBloc: () => _bloc(repository, events)),
        ),
      );
      await tester.pump();
      expect(find.text('Demo'), findsOneWidget);
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Edit geofence'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(repository.edits, 1);
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deactivate'));
      await tester.pump();
      expect(repository.deactivations, 1);
    },
  );

  testWidgets('given_empty_geofences_when_rendered_then_opens_add_form', (
    tester,
  ) async {
    final repository = _Repository()..items = [];
    final events = AsyncAppEventBus();
    addTearDown(events.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: SparkeeTheme.light(),
        home: GeofencePage(createBloc: () => _bloc(repository, events)),
      ),
    );
    await tester.pump();
    expect(find.text('No geofences'), findsOneWidget);
    await tester.tap(find.text('Add geofence'));
    await tester.pumpAndSettle();
    expect(find.text('Add geofence'), findsAtLeastNWidgets(1));
  });
}

GeofenceBloc _bloc(_Repository repository, AppEventBus events) => GeofenceBloc(
  GetGeofences(repository: repository, clock: const _Clock()),
  SaveGeofence(repository: repository, clock: const _Clock()),
  DeactivateGeofence(repository: repository, clock: const _Clock()),
  eventBus: events,
);

final class _Clock implements Clock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 22, 12);
}

final class _Repository implements GeofenceRepository {
  var items = <Geofence>[_geofence];
  var edits = 0;
  var deactivations = 0;
  @override
  Future<GeofencesResult> getAll({required DateTime nowUtc}) async =>
      Result.success(items);
  @override
  Future<GeofenceActionResult> create(
    GeofenceDraft draft, {
    required DateTime nowUtc,
  }) async {
    items = [_geofence];
    return const Result.success(null);
  }

  @override
  Future<GeofenceActionResult> edit(
    String id,
    GeofenceDraft draft, {
    required DateTime nowUtc,
  }) async {
    edits += 1;
    return const Result.success(null);
  }

  @override
  Future<GeofenceActionResult> deactivate(
    String id, {
    required DateTime nowUtc,
  }) async {
    deactivations += 1;
    return const Result.success(null);
  }

  @override
  Future<VehicleGeofenceMembership?> membershipForVehicle(
    String vehicleId,
  ) async => null;
}

final _geofence = Geofence(
  id: 'geo-1',
  version: 1,
  displayName: 'Demo',
  latitude: 12.9,
  longitude: 77.6,
  radiusMeters: 100,
  isActive: true,
  effectiveFromUtc: DateTime.utc(2026),
  vehicleCount: 1,
);
