import 'package:bytebeams/features/sync/domain/sync_repository.dart';

final class UseDemoData {
  const UseDemoData({required this.repository});

  final SyncRepository repository;

  Future<void> call() => repository.useDemoData();
}
