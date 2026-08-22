import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

abstract interface class DatabasePathProvider {
  Future<String> databasePath();
}

typedef ApplicationSupportDirectoryResolver = Future<Directory> Function();

final class ApplicationSupportDatabasePathProvider
    implements DatabasePathProvider {
  const ApplicationSupportDatabasePathProvider({
    this.fileName = 'bytebeams.duckdb',
    this.directoryResolver,
  });

  final String fileName;
  final ApplicationSupportDirectoryResolver? directoryResolver;

  @override
  Future<String> databasePath() async {
    final directory =
        await (directoryResolver ?? getApplicationSupportDirectory).call();
    await directory.create(recursive: true);
    return path.join(directory.path, fileName);
  }
}
