import 'package:bytebeams/features/sync/domain/sync_batch_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given_scheduled_batch_when_delay_elapses_then_invokes_callback_once',
    (tester) async {
      var calls = 0;
      const SystemSyncBatchScheduler().schedule(
        const Duration(seconds: 1),
        () => calls++,
      );

      await tester.pump(const Duration(seconds: 1));

      expect(calls, 1);
    },
  );

  testWidgets(
    'given_cancelled_batch_when_delay_elapses_then_does_not_invoke_callback',
    (tester) async {
      var calls = 0;
      final timer = const SystemSyncBatchScheduler().schedule(
        const Duration(seconds: 1),
        () => calls++,
      );
      timer.cancel();

      await tester.pump(const Duration(seconds: 1));

      expect(calls, 0);
    },
  );
}
