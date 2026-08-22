import 'package:bytebeams/features/sync/domain/app_event_bus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given_published_event_when_listener_runs_then_delivery_is_asynchronous',
    () async {
      final bus = AsyncAppEventBus();
      var delivered = false;
      final subscription = bus.events.listen((_) => delivered = true);

      bus.publish(const FleetDataCommitted());

      expect(delivered, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(delivered, isTrue);

      await subscription.cancel();
      await bus.close();
    },
  );
}
