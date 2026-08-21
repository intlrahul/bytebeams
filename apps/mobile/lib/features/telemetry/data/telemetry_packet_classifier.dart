import 'dart:convert';

import 'package:bytebeams/features/telemetry/domain/telemetry_models.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams_api/bytebeams_api.dart' as api;

final class TelemetryPacketClassifier {
  const TelemetryPacketClassifier({required this._clock});

  static const _futureTolerance = Duration(minutes: 5);
  static const _retention = Duration(days: 30);
  final Clock _clock;

  Result<ClassifiedTelemetryPacket, TelemetryFailure> classify(
    api.TelemetryPacket packet,
  ) {
    if (packet.packetId.trim().isEmpty || packet.vehicleId.trim().isEmpty) {
      return const Result.failure(
        TelemetryFailure.invalidIdentity('Identifier is blank'),
      );
    }
    final receivedAt = _clock.nowUtc();
    final eventAt = packet.eventTimestamp.toUtc();
    final rawValueJson = jsonEncode(packet.value.toJson());
    if (eventAt.isAfter(receivedAt.add(_futureTolerance))) {
      return Result.success(
        _classified(
          packet,
          eventAt,
          receivedAt,
          rawValueJson,
          TelemetryClassification.supportedInvalid,
          error: 'Event timestamp exceeds future tolerance',
        ),
      );
    }
    if (eventAt.isBefore(receivedAt.subtract(_retention))) {
      return Result.success(
        _classified(
          packet,
          eventAt,
          receivedAt,
          rawValueJson,
          TelemetryClassification.quarantined,
        ),
      );
    }
    final value = _validate(packet.signalName, packet.value);
    return switch (value) {
      _Unsupported() => Result.success(
        _classified(
          packet,
          eventAt,
          receivedAt,
          rawValueJson,
          TelemetryClassification.unsupported,
        ),
      ),
      _Invalid(:final reason) => Result.success(
        _classified(
          packet,
          eventAt,
          receivedAt,
          rawValueJson,
          TelemetryClassification.supportedInvalid,
          error: reason,
        ),
      ),
      _Valid(:final value) => Result.success(
        _classified(
          packet,
          eventAt,
          receivedAt,
          rawValueJson,
          TelemetryClassification.supportedValid,
          value: value,
        ),
      ),
    };
  }

  ClassifiedTelemetryPacket _classified(
    api.TelemetryPacket packet,
    DateTime eventAt,
    DateTime receivedAt,
    String raw,
    TelemetryClassification classification, {
    TelemetrySignalValue? value,
    String? error,
  }) => ClassifiedTelemetryPacket(
    packetId: packet.packetId,
    vehicleId: packet.vehicleId,
    eventTimestampUtc: eventAt,
    clientReceivedAtUtc: receivedAt,
    signalName: packet.signalName,
    rawValueJson: raw,
    classification: classification,
    serverReceivedAtUtc: packet.serverReceivedAt?.toUtc(),
    value: value,
    validationError: error,
  );

  _Validation _validate(String name, api.SignalValue input) {
    final number = input.numberValue;
    bool validNumber(double min, [double? max]) =>
        input.kind == api.SignalValueKindEnum.number &&
        number != null &&
        number.isFinite &&
        number >= min &&
        (max == null || number <= max);
    if ({'soc', 'range', 'speed', 'battery_temp', 'odometer'}.contains(name)) {
      final bounds = switch (name) {
        'soc' => (0.0, 100.0),
        'battery_temp' => (-40.0, 100.0),
        _ => (0.0, double.infinity),
      };
      return validNumber(bounds.$1, bounds.$2)
          ? _Valid(TelemetrySignalValue.number(number!))
          : const _Invalid('Signal value is invalid');
    }
    if (name == 'ignition') {
      return input.kind == api.SignalValueKindEnum.boolean &&
              input.booleanValue != null
          ? _Valid(TelemetrySignalValue.boolean(input.booleanValue!))
          : const _Invalid('Signal value is invalid');
    }
    if (name == 'last_ping') {
      return input.kind == api.SignalValueKindEnum.boolean &&
              input.booleanValue == true
          ? const _Valid(TelemetrySignalValue.boolean(true))
          : const _Invalid('last_ping must be true');
    }
    if (name == 'location') {
      final v = input.locationValue;
      return input.kind == api.SignalValueKindEnum.location &&
              v != null &&
              v.latitude >= -90 &&
              v.latitude <= 90 &&
              v.longitude >= -180 &&
              v.longitude <= 180 &&
              v.accuracyMeters >= 0
          ? _Valid(
              TelemetrySignalValue.location(
                latitude: v.latitude,
                longitude: v.longitude,
                accuracyMeters: v.accuracyMeters,
              ),
            )
          : const _Invalid('Location value is invalid');
    }
    return const _Unsupported();
  }
}

sealed class _Validation {
  const _Validation();
}

final class _Valid extends _Validation {
  const _Valid(this.value);
  final TelemetrySignalValue value;
}

final class _Invalid extends _Validation {
  const _Invalid(this.reason);
  final String reason;
}

final class _Unsupported extends _Validation {
  const _Unsupported();
}
