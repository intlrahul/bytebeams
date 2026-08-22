import 'package:flutter/material.dart';

enum SparkeeStatus { normal, warning, critical, offline, stale }

extension SparkeeStatusPresentation on SparkeeStatus {
  String get label => switch (this) {
    SparkeeStatus.normal => 'Normal',
    SparkeeStatus.warning => 'Warning',
    SparkeeStatus.critical => 'Critical',
    SparkeeStatus.offline => 'Offline',
    SparkeeStatus.stale => 'Stale',
  };

  IconData get icon => switch (this) {
    SparkeeStatus.normal => Icons.check_circle_outline,
    SparkeeStatus.warning => Icons.warning_amber_rounded,
    SparkeeStatus.critical => Icons.error_outline,
    SparkeeStatus.offline => Icons.cloud_off_outlined,
    SparkeeStatus.stale => Icons.schedule_outlined,
  };
}
