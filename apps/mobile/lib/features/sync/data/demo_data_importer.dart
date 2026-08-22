import 'dart:convert';

import 'package:bytebeams/features/sync/data/sync_dto_mapper.dart';
import 'package:bytebeams_api/bytebeams_api.dart' as api;
import 'package:flutter/services.dart';

abstract interface class DemoDataImporter {
  Future<SyncBootstrapDto> load();
}

final class AssetDemoDataImporter implements DemoDataImporter {
  const AssetDemoDataImporter({
    this.assetPath = 'assets/demo/bootstrap.json',
    this.mapper = const SyncDtoMapper(),
    this.assetBundle,
  });

  final String assetPath;
  final SyncDtoMapper mapper;
  final AssetBundle? assetBundle;

  @override
  Future<SyncBootstrapDto> load() async {
    final contents = await (assetBundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(contents) as Map<String, dynamic>;
    return mapper.bootstrap(api.BootstrapResponse.fromJson(decoded));
  }
}
