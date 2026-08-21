// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VehicleCWProxy {
  Vehicle vehicleId(String vehicleId);

  Vehicle registrationNumber(String registrationNumber);

  Vehicle model(String model);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Vehicle(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Vehicle(...).copyWith(id: 12, name: "My name")
  /// ````
  Vehicle call({String vehicleId, String registrationNumber, String model});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVehicle.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVehicle.copyWith.fieldName(...)`
class _$VehicleCWProxyImpl implements _$VehicleCWProxy {
  const _$VehicleCWProxyImpl(this._value);

  final Vehicle _value;

  @override
  Vehicle vehicleId(String vehicleId) => this(vehicleId: vehicleId);

  @override
  Vehicle registrationNumber(String registrationNumber) =>
      this(registrationNumber: registrationNumber);

  @override
  Vehicle model(String model) => this(model: model);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Vehicle(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Vehicle(...).copyWith(id: 12, name: "My name")
  /// ````
  Vehicle call({
    Object? vehicleId = const $CopyWithPlaceholder(),
    Object? registrationNumber = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
  }) {
    return Vehicle(
      vehicleId: vehicleId == const $CopyWithPlaceholder()
          ? _value.vehicleId
          // ignore: cast_nullable_to_non_nullable
          : vehicleId as String,
      registrationNumber: registrationNumber == const $CopyWithPlaceholder()
          ? _value.registrationNumber
          // ignore: cast_nullable_to_non_nullable
          : registrationNumber as String,
      model: model == const $CopyWithPlaceholder()
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
    );
  }
}

extension $VehicleCopyWith on Vehicle {
  /// Returns a callable class that can be used as follows: `instanceOfVehicle.copyWith(...)` or like so:`instanceOfVehicle.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VehicleCWProxy get copyWith => _$VehicleCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Vehicle', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['vehicleId', 'registrationNumber', 'model'],
      );
      final val = Vehicle(
        vehicleId: $checkedConvert('vehicleId', (v) => v as String),
        registrationNumber: $checkedConvert(
          'registrationNumber',
          (v) => v as String,
        ),
        model: $checkedConvert('model', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
  'vehicleId': instance.vehicleId,
  'registrationNumber': instance.registrationNumber,
  'model': instance.model,
};
