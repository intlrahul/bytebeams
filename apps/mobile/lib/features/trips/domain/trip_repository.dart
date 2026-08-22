import 'package:bytebeams/features/trips/domain/trip_models.dart';

abstract interface class TripRepository {
  Future<TripResult> getTrips({String? vehicleId, TripStatus? status});
}
