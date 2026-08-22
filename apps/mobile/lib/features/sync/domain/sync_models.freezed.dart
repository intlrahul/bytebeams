// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncFailure()';
}


}

/// @nodoc
class $SyncFailureCopyWith<$Res>  {
$SyncFailureCopyWith(SyncFailure _, $Res Function(SyncFailure) __);
}


/// Adds pattern-matching-related methods to [SyncFailure].
extension SyncFailurePatterns on SyncFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SyncBootstrapUnavailable value)?  bootstrapUnavailable,TResult Function( SyncReplayGap value)?  replayGap,TResult Function( SyncPersistenceUnavailable value)?  persistenceUnavailable,TResult Function( SyncTransportUnavailable value)?  transportUnavailable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SyncBootstrapUnavailable() when bootstrapUnavailable != null:
return bootstrapUnavailable(_that);case SyncReplayGap() when replayGap != null:
return replayGap(_that);case SyncPersistenceUnavailable() when persistenceUnavailable != null:
return persistenceUnavailable(_that);case SyncTransportUnavailable() when transportUnavailable != null:
return transportUnavailable(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SyncBootstrapUnavailable value)  bootstrapUnavailable,required TResult Function( SyncReplayGap value)  replayGap,required TResult Function( SyncPersistenceUnavailable value)  persistenceUnavailable,required TResult Function( SyncTransportUnavailable value)  transportUnavailable,}){
final _that = this;
switch (_that) {
case SyncBootstrapUnavailable():
return bootstrapUnavailable(_that);case SyncReplayGap():
return replayGap(_that);case SyncPersistenceUnavailable():
return persistenceUnavailable(_that);case SyncTransportUnavailable():
return transportUnavailable(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SyncBootstrapUnavailable value)?  bootstrapUnavailable,TResult? Function( SyncReplayGap value)?  replayGap,TResult? Function( SyncPersistenceUnavailable value)?  persistenceUnavailable,TResult? Function( SyncTransportUnavailable value)?  transportUnavailable,}){
final _that = this;
switch (_that) {
case SyncBootstrapUnavailable() when bootstrapUnavailable != null:
return bootstrapUnavailable(_that);case SyncReplayGap() when replayGap != null:
return replayGap(_that);case SyncPersistenceUnavailable() when persistenceUnavailable != null:
return persistenceUnavailable(_that);case SyncTransportUnavailable() when transportUnavailable != null:
return transportUnavailable(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  bootstrapUnavailable,TResult Function( String requestedCursor,  String oldestAvailableCursor)?  replayGap,TResult Function()?  persistenceUnavailable,TResult Function()?  transportUnavailable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SyncBootstrapUnavailable() when bootstrapUnavailable != null:
return bootstrapUnavailable();case SyncReplayGap() when replayGap != null:
return replayGap(_that.requestedCursor,_that.oldestAvailableCursor);case SyncPersistenceUnavailable() when persistenceUnavailable != null:
return persistenceUnavailable();case SyncTransportUnavailable() when transportUnavailable != null:
return transportUnavailable();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  bootstrapUnavailable,required TResult Function( String requestedCursor,  String oldestAvailableCursor)  replayGap,required TResult Function()  persistenceUnavailable,required TResult Function()  transportUnavailable,}) {final _that = this;
switch (_that) {
case SyncBootstrapUnavailable():
return bootstrapUnavailable();case SyncReplayGap():
return replayGap(_that.requestedCursor,_that.oldestAvailableCursor);case SyncPersistenceUnavailable():
return persistenceUnavailable();case SyncTransportUnavailable():
return transportUnavailable();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  bootstrapUnavailable,TResult? Function( String requestedCursor,  String oldestAvailableCursor)?  replayGap,TResult? Function()?  persistenceUnavailable,TResult? Function()?  transportUnavailable,}) {final _that = this;
switch (_that) {
case SyncBootstrapUnavailable() when bootstrapUnavailable != null:
return bootstrapUnavailable();case SyncReplayGap() when replayGap != null:
return replayGap(_that.requestedCursor,_that.oldestAvailableCursor);case SyncPersistenceUnavailable() when persistenceUnavailable != null:
return persistenceUnavailable();case SyncTransportUnavailable() when transportUnavailable != null:
return transportUnavailable();case _:
  return null;

}
}

}

/// @nodoc


class SyncBootstrapUnavailable implements SyncFailure {
  const SyncBootstrapUnavailable();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncBootstrapUnavailable);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncFailure.bootstrapUnavailable()';
}


}




/// @nodoc


class SyncReplayGap implements SyncFailure {
  const SyncReplayGap({required this.requestedCursor, required this.oldestAvailableCursor});
  

 final  String requestedCursor;
 final  String oldestAvailableCursor;

/// Create a copy of SyncFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncReplayGapCopyWith<SyncReplayGap> get copyWith => _$SyncReplayGapCopyWithImpl<SyncReplayGap>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncReplayGap&&(identical(other.requestedCursor, requestedCursor) || other.requestedCursor == requestedCursor)&&(identical(other.oldestAvailableCursor, oldestAvailableCursor) || other.oldestAvailableCursor == oldestAvailableCursor));
}


@override
int get hashCode => Object.hash(runtimeType,requestedCursor,oldestAvailableCursor);

@override
String toString() {
  return 'SyncFailure.replayGap(requestedCursor: $requestedCursor, oldestAvailableCursor: $oldestAvailableCursor)';
}


}

/// @nodoc
abstract mixin class $SyncReplayGapCopyWith<$Res> implements $SyncFailureCopyWith<$Res> {
  factory $SyncReplayGapCopyWith(SyncReplayGap value, $Res Function(SyncReplayGap) _then) = _$SyncReplayGapCopyWithImpl;
@useResult
$Res call({
 String requestedCursor, String oldestAvailableCursor
});




}
/// @nodoc
class _$SyncReplayGapCopyWithImpl<$Res>
    implements $SyncReplayGapCopyWith<$Res> {
  _$SyncReplayGapCopyWithImpl(this._self, this._then);

  final SyncReplayGap _self;
  final $Res Function(SyncReplayGap) _then;

/// Create a copy of SyncFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? requestedCursor = null,Object? oldestAvailableCursor = null,}) {
  return _then(SyncReplayGap(
requestedCursor: null == requestedCursor ? _self.requestedCursor : requestedCursor // ignore: cast_nullable_to_non_nullable
as String,oldestAvailableCursor: null == oldestAvailableCursor ? _self.oldestAvailableCursor : oldestAvailableCursor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SyncPersistenceUnavailable implements SyncFailure {
  const SyncPersistenceUnavailable();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncPersistenceUnavailable);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncFailure.persistenceUnavailable()';
}


}




/// @nodoc


class SyncTransportUnavailable implements SyncFailure {
  const SyncTransportUnavailable();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncTransportUnavailable);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncFailure.transportUnavailable()';
}


}




/// @nodoc
mixin _$SyncState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncState()';
}


}

/// @nodoc
class $SyncStateCopyWith<$Res>  {
$SyncStateCopyWith(SyncState _, $Res Function(SyncState) __);
}


/// Adds pattern-matching-related methods to [SyncState].
extension SyncStatePatterns on SyncState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SyncIdle value)?  idle,TResult Function( SyncSyncing value)?  syncing,TResult Function( SyncDegraded value)?  degraded,TResult Function( SyncDemoDataAvailable value)?  demoDataAvailable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SyncIdle() when idle != null:
return idle(_that);case SyncSyncing() when syncing != null:
return syncing(_that);case SyncDegraded() when degraded != null:
return degraded(_that);case SyncDemoDataAvailable() when demoDataAvailable != null:
return demoDataAvailable(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SyncIdle value)  idle,required TResult Function( SyncSyncing value)  syncing,required TResult Function( SyncDegraded value)  degraded,required TResult Function( SyncDemoDataAvailable value)  demoDataAvailable,}){
final _that = this;
switch (_that) {
case SyncIdle():
return idle(_that);case SyncSyncing():
return syncing(_that);case SyncDegraded():
return degraded(_that);case SyncDemoDataAvailable():
return demoDataAvailable(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SyncIdle value)?  idle,TResult? Function( SyncSyncing value)?  syncing,TResult? Function( SyncDegraded value)?  degraded,TResult? Function( SyncDemoDataAvailable value)?  demoDataAvailable,}){
final _that = this;
switch (_that) {
case SyncIdle() when idle != null:
return idle(_that);case SyncSyncing() when syncing != null:
return syncing(_that);case SyncDegraded() when degraded != null:
return degraded(_that);case SyncDemoDataAvailable() when demoDataAvailable != null:
return demoDataAvailable(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  syncing,TResult Function( SyncFailure failure)?  degraded,TResult Function( SyncFailure failure)?  demoDataAvailable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SyncIdle() when idle != null:
return idle();case SyncSyncing() when syncing != null:
return syncing();case SyncDegraded() when degraded != null:
return degraded(_that.failure);case SyncDemoDataAvailable() when demoDataAvailable != null:
return demoDataAvailable(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  syncing,required TResult Function( SyncFailure failure)  degraded,required TResult Function( SyncFailure failure)  demoDataAvailable,}) {final _that = this;
switch (_that) {
case SyncIdle():
return idle();case SyncSyncing():
return syncing();case SyncDegraded():
return degraded(_that.failure);case SyncDemoDataAvailable():
return demoDataAvailable(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  syncing,TResult? Function( SyncFailure failure)?  degraded,TResult? Function( SyncFailure failure)?  demoDataAvailable,}) {final _that = this;
switch (_that) {
case SyncIdle() when idle != null:
return idle();case SyncSyncing() when syncing != null:
return syncing();case SyncDegraded() when degraded != null:
return degraded(_that.failure);case SyncDemoDataAvailable() when demoDataAvailable != null:
return demoDataAvailable(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class SyncIdle implements SyncState {
  const SyncIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncState.idle()';
}


}




/// @nodoc


class SyncSyncing implements SyncState {
  const SyncSyncing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncSyncing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SyncState.syncing()';
}


}




/// @nodoc


class SyncDegraded implements SyncState {
  const SyncDegraded(this.failure);
  

 final  SyncFailure failure;

/// Create a copy of SyncState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncDegradedCopyWith<SyncDegraded> get copyWith => _$SyncDegradedCopyWithImpl<SyncDegraded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncDegraded&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'SyncState.degraded(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SyncDegradedCopyWith<$Res> implements $SyncStateCopyWith<$Res> {
  factory $SyncDegradedCopyWith(SyncDegraded value, $Res Function(SyncDegraded) _then) = _$SyncDegradedCopyWithImpl;
@useResult
$Res call({
 SyncFailure failure
});


$SyncFailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$SyncDegradedCopyWithImpl<$Res>
    implements $SyncDegradedCopyWith<$Res> {
  _$SyncDegradedCopyWithImpl(this._self, this._then);

  final SyncDegraded _self;
  final $Res Function(SyncDegraded) _then;

/// Create a copy of SyncState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(SyncDegraded(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as SyncFailure,
  ));
}

/// Create a copy of SyncState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SyncFailureCopyWith<$Res> get failure {
  
  return $SyncFailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

/// @nodoc


class SyncDemoDataAvailable implements SyncState {
  const SyncDemoDataAvailable(this.failure);
  

 final  SyncFailure failure;

/// Create a copy of SyncState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncDemoDataAvailableCopyWith<SyncDemoDataAvailable> get copyWith => _$SyncDemoDataAvailableCopyWithImpl<SyncDemoDataAvailable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncDemoDataAvailable&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'SyncState.demoDataAvailable(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SyncDemoDataAvailableCopyWith<$Res> implements $SyncStateCopyWith<$Res> {
  factory $SyncDemoDataAvailableCopyWith(SyncDemoDataAvailable value, $Res Function(SyncDemoDataAvailable) _then) = _$SyncDemoDataAvailableCopyWithImpl;
@useResult
$Res call({
 SyncFailure failure
});


$SyncFailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$SyncDemoDataAvailableCopyWithImpl<$Res>
    implements $SyncDemoDataAvailableCopyWith<$Res> {
  _$SyncDemoDataAvailableCopyWithImpl(this._self, this._then);

  final SyncDemoDataAvailable _self;
  final $Res Function(SyncDemoDataAvailable) _then;

/// Create a copy of SyncState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(SyncDemoDataAvailable(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as SyncFailure,
  ));
}

/// Create a copy of SyncState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SyncFailureCopyWith<$Res> get failure {
  
  return $SyncFailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
