import 'package:bytebeams/app_dependencies.dart';
import 'package:bytebeams/features/fleet_home/presentation/fleet_home_page.dart';
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
    ],
  );
}
