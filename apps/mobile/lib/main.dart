import 'dart:async';

import 'package:bytebeams/app_runtime.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_catalogue_page.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  appRunner(const ByteBeamsApp());
  unawaited(runtime.startBackgroundSync());
}

final class ByteBeamsApp extends StatelessWidget {
  const ByteBeamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ByteBeams',
      theme: SparkeeTheme.light(),
      home: const SparkeeCataloguePage(),
    );
  }
}
