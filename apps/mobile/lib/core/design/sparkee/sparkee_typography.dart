import 'package:flutter/material.dart';

abstract final class SparkeeTypography {
  static const _fontFamily = 'Roboto';

  static TextTheme textTheme = const TextTheme(
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, height: 1.4),
    bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, height: 1.4),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  static TextStyle metric(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!
          .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}
