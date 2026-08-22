import 'package:bytebeams/features/sync/data/api_endpoint_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_android_emulator_when_base_uri_requested_then_uses_host_loopback_bridge', () {
    expect(
      const DefaultApiEndpointProvider(isAndroidEmulator: true).baseUri(),
      Uri.parse('http://10.0.2.2:3000'),
    );
  });

  test(
    'given_non_android_emulator_when_base_uri_requested_then_uses_localhost',
    () {
      expect(
        const DefaultApiEndpointProvider(isAndroidEmulator: false).baseUri(),
        Uri.parse('http://localhost:3000'),
      );
    },
  );
}
