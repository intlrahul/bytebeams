import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/telemetry/data/telemetry_packet_classifier.dart';
import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams_api/bytebeams_api.dart' as api;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final classifier = TelemetryPacketClassifier(clock: _Clock());
  test('given_valid_soc_boundary_when_classified_then_is_supported_valid', () {
    final result = classifier.classify(
      _packet(
        'soc',
        api.SignalValue(kind: api.SignalValueKindEnum.number, numberValue: 100),
      ),
    );
    expect(result, isA<Success<ClassifiedTelemetryPacket, TelemetryFailure>>());
  });
  test('given_unknown_signal_when_classified_then_is_unsupported', () {
    final result = classifier.classify(
      _packet(
        'future_signal',
        api.SignalValue(kind: api.SignalValueKindEnum.string, stringValue: 'x'),
      ),
    );
    expect(
      (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
          .value
          .classification,
      TelemetryClassification.unsupported,
    );
  });
  test('given_too_old_packet_when_classified_then_is_quarantined', () {
    final result = classifier.classify(
      _packet(
        'speed',
        api.SignalValue(kind: api.SignalValueKindEnum.number, numberValue: 1),
        at: DateTime.utc(2026, 7, 22),
      ),
    );
    expect(
      (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
          .value
          .classification,
      TelemetryClassification.quarantined,
    );
  });
  test('given_far_future_packet_when_classified_then_is_invalid', () {
    final result = classifier.classify(
      _packet(
        'speed',
        api.SignalValue(kind: api.SignalValueKindEnum.number, numberValue: 1),
        at: DateTime.utc(2026, 8, 21, 12, 6),
      ),
    );
    expect(
      (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
          .value
          .classification,
      TelemetryClassification.supportedInvalid,
    );
  });
  test('given_false_last_ping_when_classified_then_is_invalid', () {
    final result = classifier.classify(
      _packet(
        'last_ping',
        api.SignalValue(
          kind: api.SignalValueKindEnum.boolean,
          booleanValue: false,
        ),
      ),
    );
    expect(
      (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
          .value
          .classification,
      TelemetryClassification.supportedInvalid,
    );
  });
  for (final signal in ['range', 'speed', 'battery_temp', 'odometer']) {
    test('given_valid_${signal}_when_classified_then_is_supported_valid', () {
      final result = classifier.classify(
        _packet(
          signal,
          api.SignalValue(kind: api.SignalValueKindEnum.number, numberValue: 1),
        ),
      );
      expect(
        (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
            .value
            .classification,
        TelemetryClassification.supportedValid,
      );
    });
  }
  test('given_invalid_soc_when_classified_then_is_invalid', () {
    final result = classifier.classify(
      _packet(
        'soc',
        api.SignalValue(kind: api.SignalValueKindEnum.number, numberValue: -1),
      ),
    );
    expect(
      (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
          .value
          .classification,
      TelemetryClassification.supportedInvalid,
    );
  });
  test('given_blank_identity_when_classified_then_returns_failure', () {
    final packet = api.TelemetryPacket(
      packetId: ' ',
      vehicleId: 'v',
      eventTimestamp: DateTime.utc(2026, 8, 21, 12),
      signalName: 'soc',
      value: api.SignalValue(
        kind: api.SignalValueKindEnum.number,
        numberValue: 1,
      ),
    );
    expect(
      classifier.classify(packet),
      isA<Failure<ClassifiedTelemetryPacket, TelemetryFailure>>(),
    );
  });
  test('given_valid_ignition_when_classified_then_is_supported_valid', () {
    final result = classifier.classify(
      _packet(
        'ignition',
        api.SignalValue(
          kind: api.SignalValueKindEnum.boolean,
          booleanValue: true,
        ),
      ),
    );
    expect(
      (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
          .value
          .classification,
      TelemetryClassification.supportedValid,
    );
  });
  test('given_invalid_battery_temp_when_classified_then_is_invalid', () {
    final result = classifier.classify(
      _packet(
        'battery_temp',
        api.SignalValue(kind: api.SignalValueKindEnum.number, numberValue: 101),
      ),
    );
    expect(
      (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
          .value
          .classification,
      TelemetryClassification.supportedInvalid,
    );
  });
  test('given_valid_location_when_classified_then_is_supported_valid', () {
    final result = classifier.classify(
      _packet(
        'location',
        api.SignalValue(
          kind: api.SignalValueKindEnum.location,
          locationValue: api.LocationValue(
            latitude: 12.9,
            longitude: 77.6,
            accuracyMeters: 20,
          ),
        ),
      ),
    );
    expect(
      (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
          .value
          .classification,
      TelemetryClassification.supportedValid,
    );
  });
  test('given_true_last_ping_when_classified_then_is_supported_valid', () {
    final result = classifier.classify(
      _packet(
        'last_ping',
        api.SignalValue(
          kind: api.SignalValueKindEnum.boolean,
          booleanValue: true,
        ),
      ),
    );
    expect(
      (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
          .value
          .classification,
      TelemetryClassification.supportedValid,
    );
  });
  test('given_negative_location_accuracy_when_classified_then_is_invalid', () {
    final result = classifier.classify(
      _packet(
        'location',
        api.SignalValue(
          kind: api.SignalValueKindEnum.location,
          locationValue: api.LocationValue(
            latitude: 0,
            longitude: 0,
            accuracyMeters: -1,
          ),
        ),
      ),
    );
    expect(
      (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
          .value
          .classification,
      TelemetryClassification.supportedInvalid,
    );
  });
  test(
    'given_exact_future_tolerance_when_classified_then_is_supported_valid',
    () {
      final result = classifier.classify(
        _packet(
          'speed',
          api.SignalValue(kind: api.SignalValueKindEnum.number, numberValue: 1),
          at: DateTime.utc(2026, 8, 21, 12, 5),
        ),
      );
      expect(
        (result as Success<ClassifiedTelemetryPacket, TelemetryFailure>)
            .value
            .classification,
        TelemetryClassification.supportedValid,
      );
    },
  );
}

api.TelemetryPacket _packet(
  String signal,
  api.SignalValue value, {
  DateTime? at,
}) => api.TelemetryPacket(
  packetId: 'p-$signal',
  vehicleId: 'v-1',
  eventTimestamp: at ?? DateTime.utc(2026, 8, 21, 12),
  signalName: signal,
  value: value,
);

final class _Clock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 21, 12);
}
