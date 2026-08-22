import 'package:bytebeams/app_runtime.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/alerts/data/duckdb_alert_repository.dart';
import 'package:bytebeams/features/alerts/domain/alert_repository.dart';
import 'package:bytebeams/features/alerts/domain/alert_use_cases.dart';
import 'package:bytebeams/features/fleet_home/data/duckdb_fleet_home_repository.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_repository.dart';
import 'package:bytebeams/features/fleet_home/domain/get_fleet_home.dart';
import 'package:bytebeams/features/fleet_home/presentation/fleet_home_bloc.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_projector.dart';
import 'package:bytebeams/features/geofences/data/duckdb_geofence_repository.dart';
import 'package:bytebeams/features/geofences/domain/geofence_repository.dart';
import 'package:bytebeams/features/geofences/domain/geofence_use_cases.dart';
import 'package:bytebeams/features/geofences/presentation/geofence_bloc.dart';
import 'package:bytebeams/features/sync/domain/use_demo_data.dart';
import 'package:bytebeams/features/trips/data/duckdb_trip_repository.dart';
import 'package:bytebeams/features/trips/data/duckdb_trip_projector.dart';
import 'package:bytebeams/features/trips/domain/trip_repository.dart';
import 'package:bytebeams/features/trips/presentation/trips_bloc.dart';
import 'package:bytebeams/features/vehicle_detail/data/duckdb_vehicle_detail_repository.dart';
import 'package:bytebeams/features/vehicle_detail/domain/get_vehicle_detail.dart';
import 'package:bytebeams/features/vehicle_detail/domain/vehicle_detail_repository.dart';
import 'package:bytebeams/features/vehicle_detail/presentation/vehicle_detail_bloc.dart';
import 'package:get_it/get_it.dart';

/// Composition-root-only service registration for application adapters.
final class AppDependencies {
  AppDependencies(AppRuntime runtime) : _services = GetIt.asNewInstance() {
    _services
      ..registerSingleton<AppRuntime>(runtime)
      ..registerSingleton<FleetHomeRepository>(
        DuckDbFleetHomeRepository(runtime.database),
      )
      ..registerSingleton(
        GetFleetHome(
          repository: _services<FleetHomeRepository>(),
          clock: const SystemClock(),
        ),
      )
      ..registerSingleton(UseDemoData(repository: runtime.syncRepository))
      ..registerSingleton<AlertRepository>(
        DuckDbAlertRepository(runtime.database),
      )
      ..registerSingleton<GeofenceRepository>(
        DuckDbGeofenceRepository(
          runtime.database,
          const DuckDbGeofenceProjector(),
          tripProjector: const DuckDbTripProjector(),
        ),
      )
      ..registerSingleton(
        GetGeofences(
          repository: _services<GeofenceRepository>(),
          clock: const SystemClock(),
        ),
      )
      ..registerSingleton(
        SaveGeofence(
          repository: _services<GeofenceRepository>(),
          clock: const SystemClock(),
        ),
      )
      ..registerSingleton(
        DeactivateGeofence(
          repository: _services<GeofenceRepository>(),
          clock: const SystemClock(),
        ),
      )
      ..registerSingleton(
        GetVehicleAlerts(
          repository: _services<AlertRepository>(),
          clock: const SystemClock(),
        ),
      )
      ..registerSingleton(
        DismissAlert(
          repository: _services<AlertRepository>(),
          clock: const SystemClock(),
        ),
      )
      ..registerSingleton(
        UndoAlertDismissal(
          repository: _services<AlertRepository>(),
          clock: const SystemClock(),
        ),
      )
      ..registerSingleton<VehicleDetailRepository>(
        DuckDbVehicleDetailRepository(runtime.database),
      )
      ..registerSingleton<TripRepository>(
        DuckDbTripRepository(runtime.database),
      )
      ..registerFactoryParam<TripsBloc, String?, void>(
        (vehicleId, _) => TripsBloc(
          repository: _services<TripRepository>(),
          eventBus: runtime.eventBus,
          vehicleId: vehicleId,
        ),
      )
      ..registerSingleton(
        GetVehicleDetail(
          repository: _services<VehicleDetailRepository>(),
          clock: const SystemClock(),
        ),
      )
      ..registerFactory(
        () => FleetHomeBloc(
          getFleetHome: _services<GetFleetHome>(),
          useDemoData: _services<UseDemoData>(),
          eventBus: runtime.eventBus,
          syncRepository: runtime.syncRepository,
        ),
      );
  }

  final GetIt _services;

  FleetHomeBloc createFleetHomeBloc() => _services<FleetHomeBloc>();

  GeofenceBloc createGeofenceBloc() => GeofenceBloc(
    _services<GetGeofences>(),
    _services<SaveGeofence>(),
    _services<DeactivateGeofence>(),
    eventBus: _services<AppRuntime>().eventBus,
  );

  VehicleDetailBloc createVehicleDetailBloc(String vehicleId) =>
      VehicleDetailBloc(
        vehicleId: vehicleId,
        getVehicleDetail: _services<GetVehicleDetail>(),
        getVehicleAlerts: _services<GetVehicleAlerts>(),
        dismissAlert: _services<DismissAlert>(),
        undoAlertDismissal: _services<UndoAlertDismissal>(),
        eventBus: _services<AppRuntime>().eventBus,
      );

  TripRepository get tripRepository => _services<TripRepository>();
  TripsBloc createTripsBloc(String? vehicleId) =>
      _services<TripsBloc>(param1: vehicleId);
}
