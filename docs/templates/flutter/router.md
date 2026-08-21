# Router Template

## Use when

Adding or changing an application route in the owned `go_router` configuration.

```dart
abstract final class AppRoutes {
  static const fleetName = 'fleet';
  static const fleetPath = '/fleet';
  static const vehicleName = 'vehicle';
  static const vehiclePath = 'vehicles/:vehicleId';
}

GoRouter createRouter({required AppDependencies dependencies}) {
  return GoRouter(
    initialLocation: AppRoutes.fleetPath,
    routes: [
      GoRoute(
        name: AppRoutes.fleetName,
        path: AppRoutes.fleetPath,
        builder: (_, __) => dependencies.createFleetPage(),
        routes: [
          GoRoute(
            name: AppRoutes.vehicleName,
            path: AppRoutes.vehiclePath,
            builder: (_, state) {
              final id = VehicleId.tryParse(
                state.pathParameters['vehicleId'],
              );
              return id == null
                  ? const InvalidRoutePage()
                  : dependencies.createVehiclePage(id);
            },
          ),
        ],
      ),
    ],
  );
}
```

## Rules

- Keep names and paths centralized and stable.
- Validate path/query parameters before page creation.
- Redirect logic performs no direct network, database, or storage work.
- Route-level composition may use approved dependency factories; feature code does not service-locate.
- Test valid routes, malformed parameters, deep links, and redirects.
- Adding typed-route code generation requires a separate dependency decision.
