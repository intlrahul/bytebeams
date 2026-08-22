import 'package:bytebeams/app_dependencies.dart';
import 'package:bytebeams/features/fleet_home/presentation/fleet_home_page.dart';
import 'package:bytebeams/features/geofences/presentation/geofence_page.dart';
import 'package:bytebeams/features/vehicle_detail/presentation/vehicle_detail_page.dart';
import 'package:bytebeams/features/trips/presentation/trips_page.dart';
import 'package:bytebeams/features/trips/presentation/trip_detail_page.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRouter {
  static GoRouter create(AppDependencies dependencies) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            FleetHomePage(createBloc: dependencies.createFleetHomeBloc),
      ),
      GoRoute(
        path: '/geofences',
        builder: (_, _) =>
            GeofencePage(createBloc: dependencies.createGeofenceBloc),
      ),
      GoRoute(
        path: '/trips',
        builder: (_, state) => TripsPage(
          createBloc: () => dependencies.createTripsBloc(
            state.uri.queryParameters['vehicleId'],
          ),
          vehicleId: state.uri.queryParameters['vehicleId'],
        ),
      ),
      GoRoute(
        path: '/trips/:tripId',
        builder: (_, state) => TripDetailPage(
          repository: dependencies.tripRepository,
          tripId: state.pathParameters['tripId']!,
        ),
      ),
      GoRoute(
        path: '/vehicles/:vehicleId',
        builder: (_, state) => VehicleDetailPage(
          createBloc: () => dependencies.createVehicleDetailBloc(
            state.pathParameters['vehicleId']!,
          ),
        ),
      ),
    ],
  );
}
