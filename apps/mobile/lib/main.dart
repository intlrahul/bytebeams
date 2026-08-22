import 'dart:async';

import 'package:bytebeams/app_dependencies.dart';
import 'package:bytebeams/app_router.dart';
import 'package:bytebeams/app_runtime.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runByteBeamsApp(
    isAndroidEmulator:
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
    openRuntime: ({required isAndroidEmulator}) =>
        AppRuntime.open(isAndroidEmulator: isAndroidEmulator),
    appRunner: runApp,
  );
}

Future<void> runByteBeamsApp({
  required bool isAndroidEmulator,
  required Future<AppRuntime> Function({required bool isAndroidEmulator})
  openRuntime,
  required void Function(Widget app) appRunner,
}) async {
  final runtime = await openRuntime(isAndroidEmulator: isAndroidEmulator);
  appRunner(ByteBeamsApp(dependencies: AppDependencies(runtime)));
  unawaited(runtime.startBackgroundSync());
}

final class ByteBeamsApp extends StatelessWidget {
  ByteBeamsApp({required AppDependencies dependencies, super.key})
    : _router = AppRouter.create(dependencies);

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ByteBeams',
      theme: SparkeeTheme.light(),
      routerConfig: _router,
    );
  }
}
