import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

abstract interface class DatabasePathProvider {
  Future<String> databasePath();
}

final class ApplicationSupportDatabasePathProvider
    implements DatabasePathProvider {
  const ApplicationSupportDatabasePathProvider({
    this.fileName = 'bytebeams.duckdb',
  });

  final String fileName;

  @override
  Future<String> databasePath() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return path.join(directory.path, fileName);
  }
}
