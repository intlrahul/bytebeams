// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telemetry_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TelemetrySignalValue {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetrySignalValue);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TelemetrySignalValue()';
}


}

/// @nodoc
class $TelemetrySignalValueCopyWith<$Res>  {
$TelemetrySignalValueCopyWith(TelemetrySignalValue _, $Res Function(TelemetrySignalValue) __);
}


/// Adds pattern-matching-related methods to [TelemetrySignalValue].
extension TelemetrySignalValuePatterns on TelemetrySignalValue {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TelemetryNumberValue value)?  number,TResult Function( TelemetryBooleanValue value)?  boolean,TResult Function( TelemetryLocationValue value)?  location,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TelemetryNumberValue() when number != null:
return number(_that);case TelemetryBooleanValue() when boolean != null:
return boolean(_that);case TelemetryLocationValue() when location != null:
return location(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TelemetryNumberValue value)  number,required TResult Function( TelemetryBooleanValue value)  boolean,required TResult Function( TelemetryLocationValue value)  location,}){
final _that = this;
switch (_that) {
case TelemetryNumberValue():
return number(_that);case TelemetryBooleanValue():
return boolean(_that);case TelemetryLocationValue():
return location(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TelemetryNumberValue value)?  number,TResult? Function( TelemetryBooleanValue value)?  boolean,TResult? Function( TelemetryLocationValue value)?  location,}){
final _that = this;
switch (_that) {
case TelemetryNumberValue() when number != null:
return number(_that);case TelemetryBooleanValue() when boolean != null:
return boolean(_that);case TelemetryLocationValue() when location != null:
return location(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( double value)?  number,TResult Function( bool value)?  boolean,TResult Function( double latitude,  double longitude,  double accuracyMeters)?  location,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TelemetryNumberValue() when number != null:
return number(_that.value);case TelemetryBooleanValue() when boolean != null:
return boolean(_that.value);case TelemetryLocationValue() when location != null:
return location(_that.latitude,_that.longitude,_that.accuracyMeters);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( double value)  number,required TResult Function( bool value)  boolean,required TResult Function( double latitude,  double longitude,  double accuracyMeters)  location,}) {final _that = this;
switch (_that) {
case TelemetryNumberValue():
return number(_that.value);case TelemetryBooleanValue():
return boolean(_that.value);case TelemetryLocationValue():
return location(_that.latitude,_that.longitude,_that.accuracyMeters);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( double value)?  number,TResult? Function( bool value)?  boolean,TResult? Function( double latitude,  double longitude,  double accuracyMeters)?  location,}) {final _that = this;
switch (_that) {
case TelemetryNumberValue() when number != null:
return number(_that.value);case TelemetryBooleanValue() when boolean != null:
return boolean(_that.value);case TelemetryLocationValue() when location != null:
return location(_that.latitude,_that.longitude,_that.accuracyMeters);case _:
  return null;

}
}

}

/// @nodoc


class TelemetryNumberValue implements TelemetrySignalValue {
  const TelemetryNumberValue(this.value);
  

 final  double value;

/// Create a copy of TelemetrySignalValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelemetryNumberValueCopyWith<TelemetryNumberValue> get copyWith => _$TelemetryNumberValueCopyWithImpl<TelemetryNumberValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryNumberValue&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'TelemetrySignalValue.number(value: $value)';
}


}

/// @nodoc
abstract mixin class $TelemetryNumberValueCopyWith<$Res> implements $TelemetrySignalValueCopyWith<$Res> {
  factory $TelemetryNumberValueCopyWith(TelemetryNumberValue value, $Res Function(TelemetryNumberValue) _then) = _$TelemetryNumberValueCopyWithImpl;
@useResult
$Res call({
 double value
});




}
/// @nodoc
class _$TelemetryNumberValueCopyWithImpl<$Res>
    implements $TelemetryNumberValueCopyWith<$Res> {
  _$TelemetryNumberValueCopyWithImpl(this._self, this._then);

  final TelemetryNumberValue _self;
  final $Res Function(TelemetryNumberValue) _then;

/// Create a copy of TelemetrySignalValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(TelemetryNumberValue(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class TelemetryBooleanValue implements TelemetrySignalValue {
  const TelemetryBooleanValue(this.value);
  

 final  bool value;

/// Create a copy of TelemetrySignalValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelemetryBooleanValueCopyWith<TelemetryBooleanValue> get copyWith => _$TelemetryBooleanValueCopyWithImpl<TelemetryBooleanValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryBooleanValue&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'TelemetrySignalValue.boolean(value: $value)';
}


}

/// @nodoc
abstract mixin class $TelemetryBooleanValueCopyWith<$Res> implements $TelemetrySignalValueCopyWith<$Res> {
  factory $TelemetryBooleanValueCopyWith(TelemetryBooleanValue value, $Res Function(TelemetryBooleanValue) _then) = _$TelemetryBooleanValueCopyWithImpl;
@useResult
$Res call({
 bool value
});




}
/// @nodoc
class _$TelemetryBooleanValueCopyWithImpl<$Res>
    implements $TelemetryBooleanValueCopyWith<$Res> {
  _$TelemetryBooleanValueCopyWithImpl(this._self, this._then);

  final TelemetryBooleanValue _self;
  final $Res Function(TelemetryBooleanValue) _then;

/// Create a copy of TelemetrySignalValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(TelemetryBooleanValue(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class TelemetryLocationValue implements TelemetrySignalValue {
  const TelemetryLocationValue({required this.latitude, required this.longitude, required this.accuracyMeters});
  

 final  double latitude;
 final  double longitude;
 final  double accuracyMeters;

/// Create a copy of TelemetrySignalValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelemetryLocationValueCopyWith<TelemetryLocationValue> get copyWith => _$TelemetryLocationValueCopyWithImpl<TelemetryLocationValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryLocationValue&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracyMeters, accuracyMeters) || other.accuracyMeters == accuracyMeters));
}


@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracyMeters);

@override
String toString() {
  return 'TelemetrySignalValue.location(latitude: $latitude, longitude: $longitude, accuracyMeters: $accuracyMeters)';
}


}

/// @nodoc
abstract mixin class $TelemetryLocationValueCopyWith<$Res> implements $TelemetrySignalValueCopyWith<$Res> {
  factory $TelemetryLocationValueCopyWith(TelemetryLocationValue value, $Res Function(TelemetryLocationValue) _then) = _$TelemetryLocationValueCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double accuracyMeters
});




}
/// @nodoc
class _$TelemetryLocationValueCopyWithImpl<$Res>
    implements $TelemetryLocationValueCopyWith<$Res> {
  _$TelemetryLocationValueCopyWithImpl(this._self, this._then);

  final TelemetryLocationValue _self;
  final $Res Function(TelemetryLocationValue) _then;

/// Create a copy of TelemetrySignalValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? accuracyMeters = null,}) {
  return _then(TelemetryLocationValue(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracyMeters: null == accuracyMeters ? _self.accuracyMeters : accuracyMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$Vehicle {

 String get vehicleId; String get registrationNumber; String get model;
/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleCopyWith<Vehicle> get copyWith => _$VehicleCopyWithImpl<Vehicle>(this as Vehicle, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vehicle&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.model, model) || other.model == model));
}


@override
int get hashCode => Object.hash(runtimeType,vehicleId,registrationNumber,model);

@override
String toString() {
  return 'Vehicle(vehicleId: $vehicleId, registrationNumber: $registrationNumber, model: $model)';
}


}

/// @nodoc
abstract mixin class $VehicleCopyWith<$Res>  {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) _then) = _$VehicleCopyWithImpl;
@useResult
$Res call({
 String vehicleId, String registrationNumber, String model
});




}
/// @nodoc
class _$VehicleCopyWithImpl<$Res>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._self, this._then);

  final Vehicle _self;
  final $Res Function(Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vehicleId = null,Object? registrationNumber = null,Object? model = null,}) {
  return _then(_self.copyWith(
vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String,registrationNumber: null == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Vehicle].
extension VehiclePatterns on Vehicle {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vehicle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vehicle value)  $default,){
final _that = this;
switch (_that) {
case _Vehicle():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vehicle value)?  $default,){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String vehicleId,  String registrationNumber,  String model)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.vehicleId,_that.registrationNumber,_that.model);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String vehicleId,  String registrationNumber,  String model)  $default,) {final _that = this;
switch (_that) {
case _Vehicle():
return $default(_that.vehicleId,_that.registrationNumber,_that.model);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String vehicleId,  String registrationNumber,  String model)?  $default,) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.vehicleId,_that.registrationNumber,_that.model);case _:
  return null;

}
}

}

/// @nodoc


class _Vehicle implements Vehicle {
  const _Vehicle({required this.vehicleId, required this.registrationNumber, required this.model});
  

@override final  String vehicleId;
@override final  String registrationNumber;
@override final  String model;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleCopyWith<_Vehicle> get copyWith => __$VehicleCopyWithImpl<_Vehicle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vehicle&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.model, model) || other.model == model));
}


@override
int get hashCode => Object.hash(runtimeType,vehicleId,registrationNumber,model);

@override
String toString() {
  return 'Vehicle(vehicleId: $vehicleId, registrationNumber: $registrationNumber, model: $model)';
}


}

/// @nodoc
abstract mixin class _$VehicleCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$VehicleCopyWith(_Vehicle value, $Res Function(_Vehicle) _then) = __$VehicleCopyWithImpl;
@override @useResult
$Res call({
 String vehicleId, String registrationNumber, String model
});




}
/// @nodoc
class __$VehicleCopyWithImpl<$Res>
    implements _$VehicleCopyWith<$Res> {
  __$VehicleCopyWithImpl(this._self, this._then);

  final _Vehicle _self;
  final $Res Function(_Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleId = null,Object? registrationNumber = null,Object? model = null,}) {
  return _then(_Vehicle(
vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String,registrationNumber: null == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ClassifiedTelemetryPacket {

 String get packetId; String get vehicleId; DateTime get eventTimestampUtc; DateTime get clientReceivedAtUtc; String get signalName; String get rawValueJson; TelemetryClassification get classification; DateTime? get serverReceivedAtUtc; TelemetrySignalValue? get value; String? get validationError;
/// Create a copy of ClassifiedTelemetryPacket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassifiedTelemetryPacketCopyWith<ClassifiedTelemetryPacket> get copyWith => _$ClassifiedTelemetryPacketCopyWithImpl<ClassifiedTelemetryPacket>(this as ClassifiedTelemetryPacket, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassifiedTelemetryPacket&&(identical(other.packetId, packetId) || other.packetId == packetId)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.eventTimestampUtc, eventTimestampUtc) || other.eventTimestampUtc == eventTimestampUtc)&&(identical(other.clientReceivedAtUtc, clientReceivedAtUtc) || other.clientReceivedAtUtc == clientReceivedAtUtc)&&(identical(other.signalName, signalName) || other.signalName == signalName)&&(identical(other.rawValueJson, rawValueJson) || other.rawValueJson == rawValueJson)&&(identical(other.classification, classification) || other.classification == classification)&&(identical(other.serverReceivedAtUtc, serverReceivedAtUtc) || other.serverReceivedAtUtc == serverReceivedAtUtc)&&(identical(other.value, value) || other.value == value)&&(identical(other.validationError, validationError) || other.validationError == validationError));
}


@override
int get hashCode => Object.hash(runtimeType,packetId,vehicleId,eventTimestampUtc,clientReceivedAtUtc,signalName,rawValueJson,classification,serverReceivedAtUtc,value,validationError);

@override
String toString() {
  return 'ClassifiedTelemetryPacket(packetId: $packetId, vehicleId: $vehicleId, eventTimestampUtc: $eventTimestampUtc, clientReceivedAtUtc: $clientReceivedAtUtc, signalName: $signalName, rawValueJson: $rawValueJson, classification: $classification, serverReceivedAtUtc: $serverReceivedAtUtc, value: $value, validationError: $validationError)';
}


}

/// @nodoc
abstract mixin class $ClassifiedTelemetryPacketCopyWith<$Res>  {
  factory $ClassifiedTelemetryPacketCopyWith(ClassifiedTelemetryPacket value, $Res Function(ClassifiedTelemetryPacket) _then) = _$ClassifiedTelemetryPacketCopyWithImpl;
@useResult
$Res call({
 String packetId, String vehicleId, DateTime eventTimestampUtc, DateTime clientReceivedAtUtc, String signalName, String rawValueJson, TelemetryClassification classification, DateTime? serverReceivedAtUtc, TelemetrySignalValue? value, String? validationError
});


$TelemetrySignalValueCopyWith<$Res>? get value;

}
/// @nodoc
class _$ClassifiedTelemetryPacketCopyWithImpl<$Res>
    implements $ClassifiedTelemetryPacketCopyWith<$Res> {
  _$ClassifiedTelemetryPacketCopyWithImpl(this._self, this._then);

  final ClassifiedTelemetryPacket _self;
  final $Res Function(ClassifiedTelemetryPacket) _then;

/// Create a copy of ClassifiedTelemetryPacket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packetId = null,Object? vehicleId = null,Object? eventTimestampUtc = null,Object? clientReceivedAtUtc = null,Object? signalName = null,Object? rawValueJson = null,Object? classification = null,Object? serverReceivedAtUtc = freezed,Object? value = freezed,Object? validationError = freezed,}) {
  return _then(_self.copyWith(
packetId: null == packetId ? _self.packetId : packetId // ignore: cast_nullable_to_non_nullable
as String,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String,eventTimestampUtc: null == eventTimestampUtc ? _self.eventTimestampUtc : eventTimestampUtc // ignore: cast_nullable_to_non_nullable
as DateTime,clientReceivedAtUtc: null == clientReceivedAtUtc ? _self.clientReceivedAtUtc : clientReceivedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,signalName: null == signalName ? _self.signalName : signalName // ignore: cast_nullable_to_non_nullable
as String,rawValueJson: null == rawValueJson ? _self.rawValueJson : rawValueJson // ignore: cast_nullable_to_non_nullable
as String,classification: null == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as TelemetryClassification,serverReceivedAtUtc: freezed == serverReceivedAtUtc ? _self.serverReceivedAtUtc : serverReceivedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as TelemetrySignalValue?,validationError: freezed == validationError ? _self.validationError : validationError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ClassifiedTelemetryPacket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TelemetrySignalValueCopyWith<$Res>? get value {
    if (_self.value == null) {
    return null;
  }

  return $TelemetrySignalValueCopyWith<$Res>(_self.value!, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClassifiedTelemetryPacket].
extension ClassifiedTelemetryPacketPatterns on ClassifiedTelemetryPacket {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassifiedTelemetryPacket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassifiedTelemetryPacket() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassifiedTelemetryPacket value)  $default,){
final _that = this;
switch (_that) {
case _ClassifiedTelemetryPacket():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassifiedTelemetryPacket value)?  $default,){
final _that = this;
switch (_that) {
case _ClassifiedTelemetryPacket() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packetId,  String vehicleId,  DateTime eventTimestampUtc,  DateTime clientReceivedAtUtc,  String signalName,  String rawValueJson,  TelemetryClassification classification,  DateTime? serverReceivedAtUtc,  TelemetrySignalValue? value,  String? validationError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassifiedTelemetryPacket() when $default != null:
return $default(_that.packetId,_that.vehicleId,_that.eventTimestampUtc,_that.clientReceivedAtUtc,_that.signalName,_that.rawValueJson,_that.classification,_that.serverReceivedAtUtc,_that.value,_that.validationError);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packetId,  String vehicleId,  DateTime eventTimestampUtc,  DateTime clientReceivedAtUtc,  String signalName,  String rawValueJson,  TelemetryClassification classification,  DateTime? serverReceivedAtUtc,  TelemetrySignalValue? value,  String? validationError)  $default,) {final _that = this;
switch (_that) {
case _ClassifiedTelemetryPacket():
return $default(_that.packetId,_that.vehicleId,_that.eventTimestampUtc,_that.clientReceivedAtUtc,_that.signalName,_that.rawValueJson,_that.classification,_that.serverReceivedAtUtc,_that.value,_that.validationError);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packetId,  String vehicleId,  DateTime eventTimestampUtc,  DateTime clientReceivedAtUtc,  String signalName,  String rawValueJson,  TelemetryClassification classification,  DateTime? serverReceivedAtUtc,  TelemetrySignalValue? value,  String? validationError)?  $default,) {final _that = this;
switch (_that) {
case _ClassifiedTelemetryPacket() when $default != null:
return $default(_that.packetId,_that.vehicleId,_that.eventTimestampUtc,_that.clientReceivedAtUtc,_that.signalName,_that.rawValueJson,_that.classification,_that.serverReceivedAtUtc,_that.value,_that.validationError);case _:
  return null;

}
}

}

/// @nodoc


class _ClassifiedTelemetryPacket implements ClassifiedTelemetryPacket {
  const _ClassifiedTelemetryPacket({required this.packetId, required this.vehicleId, required this.eventTimestampUtc, required this.clientReceivedAtUtc, required this.signalName, required this.rawValueJson, required this.classification, this.serverReceivedAtUtc, this.value, this.validationError});
  

@override final  String packetId;
@override final  String vehicleId;
@override final  DateTime eventTimestampUtc;
@override final  DateTime clientReceivedAtUtc;
@override final  String signalName;
@override final  String rawValueJson;
@override final  TelemetryClassification classification;
@override final  DateTime? serverReceivedAtUtc;
@override final  TelemetrySignalValue? value;
@override final  String? validationError;

/// Create a copy of ClassifiedTelemetryPacket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassifiedTelemetryPacketCopyWith<_ClassifiedTelemetryPacket> get copyWith => __$ClassifiedTelemetryPacketCopyWithImpl<_ClassifiedTelemetryPacket>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassifiedTelemetryPacket&&(identical(other.packetId, packetId) || other.packetId == packetId)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.eventTimestampUtc, eventTimestampUtc) || other.eventTimestampUtc == eventTimestampUtc)&&(identical(other.clientReceivedAtUtc, clientReceivedAtUtc) || other.clientReceivedAtUtc == clientReceivedAtUtc)&&(identical(other.signalName, signalName) || other.signalName == signalName)&&(identical(other.rawValueJson, rawValueJson) || other.rawValueJson == rawValueJson)&&(identical(other.classification, classification) || other.classification == classification)&&(identical(other.serverReceivedAtUtc, serverReceivedAtUtc) || other.serverReceivedAtUtc == serverReceivedAtUtc)&&(identical(other.value, value) || other.value == value)&&(identical(other.validationError, validationError) || other.validationError == validationError));
}


@override
int get hashCode => Object.hash(runtimeType,packetId,vehicleId,eventTimestampUtc,clientReceivedAtUtc,signalName,rawValueJson,classification,serverReceivedAtUtc,value,validationError);

@override
String toString() {
  return 'ClassifiedTelemetryPacket(packetId: $packetId, vehicleId: $vehicleId, eventTimestampUtc: $eventTimestampUtc, clientReceivedAtUtc: $clientReceivedAtUtc, signalName: $signalName, rawValueJson: $rawValueJson, classification: $classification, serverReceivedAtUtc: $serverReceivedAtUtc, value: $value, validationError: $validationError)';
}


}

/// @nodoc
abstract mixin class _$ClassifiedTelemetryPacketCopyWith<$Res> implements $ClassifiedTelemetryPacketCopyWith<$Res> {
  factory _$ClassifiedTelemetryPacketCopyWith(_ClassifiedTelemetryPacket value, $Res Function(_ClassifiedTelemetryPacket) _then) = __$ClassifiedTelemetryPacketCopyWithImpl;
@override @useResult
$Res call({
 String packetId, String vehicleId, DateTime eventTimestampUtc, DateTime clientReceivedAtUtc, String signalName, String rawValueJson, TelemetryClassification classification, DateTime? serverReceivedAtUtc, TelemetrySignalValue? value, String? validationError
});


@override $TelemetrySignalValueCopyWith<$Res>? get value;

}
/// @nodoc
class __$ClassifiedTelemetryPacketCopyWithImpl<$Res>
    implements _$ClassifiedTelemetryPacketCopyWith<$Res> {
  __$ClassifiedTelemetryPacketCopyWithImpl(this._self, this._then);

  final _ClassifiedTelemetryPacket _self;
  final $Res Function(_ClassifiedTelemetryPacket) _then;

/// Create a copy of ClassifiedTelemetryPacket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packetId = null,Object? vehicleId = null,Object? eventTimestampUtc = null,Object? clientReceivedAtUtc = null,Object? signalName = null,Object? rawValueJson = null,Object? classification = null,Object? serverReceivedAtUtc = freezed,Object? value = freezed,Object? validationError = freezed,}) {
  return _then(_ClassifiedTelemetryPacket(
packetId: null == packetId ? _self.packetId : packetId // ignore: cast_nullable_to_non_nullable
as String,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String,eventTimestampUtc: null == eventTimestampUtc ? _self.eventTimestampUtc : eventTimestampUtc // ignore: cast_nullable_to_non_nullable
as DateTime,clientReceivedAtUtc: null == clientReceivedAtUtc ? _self.clientReceivedAtUtc : clientReceivedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,signalName: null == signalName ? _self.signalName : signalName // ignore: cast_nullable_to_non_nullable
as String,rawValueJson: null == rawValueJson ? _self.rawValueJson : rawValueJson // ignore: cast_nullable_to_non_nullable
as String,classification: null == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as TelemetryClassification,serverReceivedAtUtc: freezed == serverReceivedAtUtc ? _self.serverReceivedAtUtc : serverReceivedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as TelemetrySignalValue?,validationError: freezed == validationError ? _self.validationError : validationError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ClassifiedTelemetryPacket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TelemetrySignalValueCopyWith<$Res>? get value {
    if (_self.value == null) {
    return null;
  }

  return $TelemetrySignalValueCopyWith<$Res>(_self.value!, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}

/// @nodoc
mixin _$TelemetryFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TelemetryFailure()';
}


}

/// @nodoc
class $TelemetryFailureCopyWith<$Res>  {
$TelemetryFailureCopyWith(TelemetryFailure _, $Res Function(TelemetryFailure) __);
}


/// Adds pattern-matching-related methods to [TelemetryFailure].
extension TelemetryFailurePatterns on TelemetryFailure {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TelemetryInvalidIdentity value)?  invalidIdentity,TResult Function( TelemetryPersistenceUnavailable value)?  persistenceUnavailable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TelemetryInvalidIdentity() when invalidIdentity != null:
return invalidIdentity(_that);case TelemetryPersistenceUnavailable() when persistenceUnavailable != null:
return persistenceUnavailable(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TelemetryInvalidIdentity value)  invalidIdentity,required TResult Function( TelemetryPersistenceUnavailable value)  persistenceUnavailable,}){
final _that = this;
switch (_that) {
case TelemetryInvalidIdentity():
return invalidIdentity(_that);case TelemetryPersistenceUnavailable():
return persistenceUnavailable(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TelemetryInvalidIdentity value)?  invalidIdentity,TResult? Function( TelemetryPersistenceUnavailable value)?  persistenceUnavailable,}){
final _that = this;
switch (_that) {
case TelemetryInvalidIdentity() when invalidIdentity != null:
return invalidIdentity(_that);case TelemetryPersistenceUnavailable() when persistenceUnavailable != null:
return persistenceUnavailable(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String safeReason)?  invalidIdentity,TResult Function()?  persistenceUnavailable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TelemetryInvalidIdentity() when invalidIdentity != null:
return invalidIdentity(_that.safeReason);case TelemetryPersistenceUnavailable() when persistenceUnavailable != null:
return persistenceUnavailable();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String safeReason)  invalidIdentity,required TResult Function()  persistenceUnavailable,}) {final _that = this;
switch (_that) {
case TelemetryInvalidIdentity():
return invalidIdentity(_that.safeReason);case TelemetryPersistenceUnavailable():
return persistenceUnavailable();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String safeReason)?  invalidIdentity,TResult? Function()?  persistenceUnavailable,}) {final _that = this;
switch (_that) {
case TelemetryInvalidIdentity() when invalidIdentity != null:
return invalidIdentity(_that.safeReason);case TelemetryPersistenceUnavailable() when persistenceUnavailable != null:
return persistenceUnavailable();case _:
  return null;

}
}

}

/// @nodoc


class TelemetryInvalidIdentity implements TelemetryFailure {
  const TelemetryInvalidIdentity(this.safeReason);
  

 final  String safeReason;

/// Create a copy of TelemetryFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TelemetryInvalidIdentityCopyWith<TelemetryInvalidIdentity> get copyWith => _$TelemetryInvalidIdentityCopyWithImpl<TelemetryInvalidIdentity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryInvalidIdentity&&(identical(other.safeReason, safeReason) || other.safeReason == safeReason));
}


@override
int get hashCode => Object.hash(runtimeType,safeReason);

@override
String toString() {
  return 'TelemetryFailure.invalidIdentity(safeReason: $safeReason)';
}


}

/// @nodoc
abstract mixin class $TelemetryInvalidIdentityCopyWith<$Res> implements $TelemetryFailureCopyWith<$Res> {
  factory $TelemetryInvalidIdentityCopyWith(TelemetryInvalidIdentity value, $Res Function(TelemetryInvalidIdentity) _then) = _$TelemetryInvalidIdentityCopyWithImpl;
@useResult
$Res call({
 String safeReason
});




}
/// @nodoc
class _$TelemetryInvalidIdentityCopyWithImpl<$Res>
    implements $TelemetryInvalidIdentityCopyWith<$Res> {
  _$TelemetryInvalidIdentityCopyWithImpl(this._self, this._then);

  final TelemetryInvalidIdentity _self;
  final $Res Function(TelemetryInvalidIdentity) _then;

/// Create a copy of TelemetryFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? safeReason = null,}) {
  return _then(TelemetryInvalidIdentity(
null == safeReason ? _self.safeReason : safeReason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TelemetryPersistenceUnavailable implements TelemetryFailure {
  const TelemetryPersistenceUnavailable();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TelemetryPersistenceUnavailable);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TelemetryFailure.persistenceUnavailable()';
}


}




/// @nodoc
mixin _$Result<S,F> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result<S, F>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Result<$S, $F>()';
}


}

/// @nodoc
class $ResultCopyWith<S,F,$Res>  {
$ResultCopyWith(Result<S, F> _, $Res Function(Result<S, F>) __);
}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<S,F> on Result<S, F> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Success<S, F> value)?  success,TResult Function( Failure<S, F> value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that);case Failure() when failure != null:
return failure(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Success<S, F> value)  success,required TResult Function( Failure<S, F> value)  failure,}){
final _that = this;
switch (_that) {
case Success():
return success(_that);case Failure():
return failure(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Success<S, F> value)?  success,TResult? Function( Failure<S, F> value)?  failure,}){
final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that);case Failure() when failure != null:
return failure(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( S value)?  success,TResult Function( F failure)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that.value);case Failure() when failure != null:
return failure(_that.failure);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( S value)  success,required TResult Function( F failure)  failure,}) {final _that = this;
switch (_that) {
case Success():
return success(_that.value);case Failure():
return failure(_that.failure);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( S value)?  success,TResult? Function( F failure)?  failure,}) {final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that.value);case Failure() when failure != null:
return failure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class Success<S,F> implements Result<S, F> {
  const Success(this.value);
  

 final  S value;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuccessCopyWith<S, F, Success<S, F>> get copyWith => _$SuccessCopyWithImpl<S, F, Success<S, F>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Success<S, F>&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'Result<$S, $F>.success(value: $value)';
}


}

/// @nodoc
abstract mixin class $SuccessCopyWith<S,F,$Res> implements $ResultCopyWith<S, F, $Res> {
  factory $SuccessCopyWith(Success<S, F> value, $Res Function(Success<S, F>) _then) = _$SuccessCopyWithImpl;
@useResult
$Res call({
 S value
});




}
/// @nodoc
class _$SuccessCopyWithImpl<S,F,$Res>
    implements $SuccessCopyWith<S, F, $Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success<S, F> _self;
  final $Res Function(Success<S, F>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = freezed,}) {
  return _then(Success<S, F>(
freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as S,
  ));
}


}

/// @nodoc


class Failure<S,F> implements Result<S, F> {
  const Failure(this.failure);
  

 final  F failure;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailureCopyWith<S, F, Failure<S, F>> get copyWith => _$FailureCopyWithImpl<S, F, Failure<S, F>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure<S, F>&&const DeepCollectionEquality().equals(other.failure, failure));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(failure));

@override
String toString() {
  return 'Result<$S, $F>.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $FailureCopyWith<S,F,$Res> implements $ResultCopyWith<S, F, $Res> {
  factory $FailureCopyWith(Failure<S, F> value, $Res Function(Failure<S, F>) _then) = _$FailureCopyWithImpl;
@useResult
$Res call({
 F failure
});




}
/// @nodoc
class _$FailureCopyWithImpl<S,F,$Res>
    implements $FailureCopyWith<S, F, $Res> {
  _$FailureCopyWithImpl(this._self, this._then);

  final Failure<S, F> _self;
  final $Res Function(Failure<S, F>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = freezed,}) {
  return _then(Failure<S, F>(
freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as F,
  ));
}


}

// dart format on
