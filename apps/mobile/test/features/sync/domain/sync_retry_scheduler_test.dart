import 'package:bytebeams/features/sync/domain/sync_retry_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_retry_attempts_when_delay_selected_then_uses_approved_deterministic_schedule', () {
    const policy = SyncRetryPolicy();

    expect(policy.delayForAttempt(0), const Duration(seconds: 1));
    expect(policy.delayForAttempt(1), const Duration(seconds: 2));
    expect(policy.delayForAttempt(2), const Duration(seconds: 4));
    expect(policy.delayForAttempt(3), const Duration(seconds: 8));
    expect(policy.delayForAttempt(4), const Duration(seconds: 15));
    expect(policy.delayForAttempt(99), const Duration(seconds: 15));
  });
}
