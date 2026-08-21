import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_models.freezed.dart';

enum TelemetryClassification {
  supportedValid,
  supportedInvalid,
  unsupported,
  quarantined,
}

@freezed
sealed class TelemetrySignalValue with _$TelemetrySignalValue {
  const factory TelemetrySignalValue.number(double value) =
      TelemetryNumberValue;
  const factory TelemetrySignalValue.boolean(bool value) =
      TelemetryBooleanValue;
  const factory TelemetrySignalValue.location({
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) = TelemetryLocationValue;
}

@freezed
sealed class Vehicle with _$Vehicle {
  const factory Vehicle({
    required String vehicleId,
    required String registrationNumber,
    required String model,
  }) = _Vehicle;
}

@freezed
sealed class ClassifiedTelemetryPacket with _$ClassifiedTelemetryPacket {
  const factory ClassifiedTelemetryPacket({
    required String packetId,
    required String vehicleId,
    required DateTime eventTimestampUtc,
    required DateTime clientReceivedAtUtc,
    required String signalName,
    required String rawValueJson,
    required TelemetryClassification classification,
    DateTime? serverReceivedAtUtc,
    TelemetrySignalValue? value,
    String? validationError,
  }) = _ClassifiedTelemetryPacket;
}

@freezed
sealed class TelemetryFailure with _$TelemetryFailure {
  const factory TelemetryFailure.invalidIdentity(String safeReason) =
      TelemetryInvalidIdentity;
  const factory TelemetryFailure.persistenceUnavailable() =
      TelemetryPersistenceUnavailable;
}

@freezed
sealed class Result<S, F> with _$Result<S, F> {
  const factory Result.success(S value) = Success<S, F>;
  const factory Result.failure(F failure) = Failure<S, F>;
}
