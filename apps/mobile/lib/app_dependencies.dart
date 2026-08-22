import 'package:bytebeams/app_runtime.dart';
import 'package:bytebeams/core/time/clock.dart';
import 'package:bytebeams/features/fleet_home/data/duckdb_fleet_home_repository.dart';
import 'package:bytebeams/features/fleet_home/domain/fleet_home_repository.dart';
import 'package:bytebeams/features/fleet_home/domain/get_fleet_home.dart';
import 'package:bytebeams/features/fleet_home/presentation/fleet_home_bloc.dart';
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
      ..registerFactory(
        () => FleetHomeBloc(
          getFleetHome: _services<GetFleetHome>(),
          eventBus: runtime.eventBus,
          syncRepository: runtime.syncRepository,
        ),
      );
  }

  final GetIt _services;

  FleetHomeBloc createFleetHomeBloc() => _services<FleetHomeBloc>();
}
