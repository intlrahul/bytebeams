import 'package:bytebeams/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'given_app_installed_when_launched_then_renders_the_product_name',
    (tester) async {
      // Given / When
      app.main();
      await tester.pumpAndSettle();

      // Then
      expect(find.text('ByteBeams'), findsOneWidget);
    },
  );
}
