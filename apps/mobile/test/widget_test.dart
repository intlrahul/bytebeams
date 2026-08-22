import 'package:bytebeams/main.dart' as app;
import 'package:bytebeams/core/design/sparkee/sparkee_color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given_app_started_when_first_frame_rendered_then_shows_sparkee_catalogue',
    (tester) async {
      // Given / When
      await tester.pumpWidget(const app.ByteBeamsApp());

      // Then
      expect(find.text('Sparkee catalogue'), findsOneWidget);
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.light);
      expect(materialApp.theme?.colorScheme.primary, SparkeeColors.primary);
    },
  );
}
