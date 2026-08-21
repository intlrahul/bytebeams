import 'package:bytebeams/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given_app_started_when_first_frame_rendered_then_shows_product_name',
    (tester) async {
      // Given / When
      app.main();
      await tester.pump();

      // Then
      expect(find.text('ByteBeams'), findsOneWidget);
    },
  );
}
