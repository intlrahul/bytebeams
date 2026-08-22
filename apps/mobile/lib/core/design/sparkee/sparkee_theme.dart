import 'package:bytebeams/core/design/sparkee/sparkee_color_tokens.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_radius.dart';
import 'package:bytebeams/core/design/sparkee/sparkee_typography.dart';
import 'package:flutter/material.dart';

/// The only source for app-wide visual defaults. Feature UI consumes this
/// theme and Sparkee components rather than declaring local visual tokens.
abstract final class SparkeeTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: SparkeeColors.primary,
      onPrimary: SparkeeColors.onPrimary,
      surface: SparkeeColors.surface,
      onSurface: SparkeeColors.textPrimary,
      error: SparkeeColors.critical,
      onError: SparkeeColors.onPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: SparkeeColors.background,
      textTheme: SparkeeTypography.textTheme.apply(
        bodyColor: SparkeeColors.textPrimary,
        displayColor: SparkeeColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SparkeeColors.surface,
        foregroundColor: SparkeeColors.textPrimary,
      ),
      dividerColor: SparkeeColors.border,
      cardTheme: const CardThemeData(
        color: SparkeeColors.surface,
        shape: RoundedRectangleBorder(borderRadius: SparkeeRadius.medium),
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: SparkeeRadius.small),
        side: BorderSide(color: SparkeeColors.border),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
