import 'package:bytebeams/core/design/sparkee/sparkee_theme.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/get_vehicle_detail.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_models.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_repository.dart';
import 'package:bytebeams/features/vehicle_detail/presentation/vehicle_detail_bloc.dart';
import 'package:bytebeams/features/vehicle_detail/presentation/vehicle_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given_detail_when_rendered_then_shows_readings_verdicts_and_history',
    (tester) async {
      final events = AsyncAppEventBus();
      await tester.pumpWidget(
        MaterialApp(
          theme: SparkeeTheme.light(),
          home: VehicleDetailPage(
            createBloc: () => VehicleDetailBloc(
              vehicleId: 'vehicle-1',
              getVehicleDetail: GetVehicleDetail(
                repository: const _Repository(),
                clock: const _Clock(),
              ),
              eventBus: events,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BB-001'), findsOneWidget);
      expect(find.text('SOC'), findsOneWidget);
      expect(find.text('ALERT'), findsOneWidget);
      expect(find.text('Range'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(find.text('SOC history — last 24 hours'), findsOneWidget);
      await events.close();
    },
  );
}

final class _Clock implements Clock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 22, 12);
}

final class _Repository implements VehicleDetailRepository {
  const _Repository();
  @override
  Future<VehicleDetailResult> getVehicleDetail({
    required String vehicleId,
    required DateTime asOfUtc,
  }) async => Result.success(
    VehicleDetail(
      vehicleId: vehicleId,
      registrationNumber: 'BB-001',
      model: 'E-Truck',
      asOfUtc: asOfUtc,
      readings: [
        VehicleReading(
          signal: VehicleReadingSignal.soc,
          value: 10,
          reportedAtUtc: DateTime.utc(2026, 8, 22, 11, 59),
          verdict: VehicleReadingVerdict.alert,
        ),
        const VehicleReading(
          signal: VehicleReadingSignal.range,
          value: null,
          reportedAtUtc: null,
          verdict: null,
        ),
      ],
      socHistory: [
        SocHistoryPoint(
          eventTimestampUtc: DateTime.utc(2026, 8, 22, 11),
          soc: 10,
        ),
      ],
    ),
  );
}
