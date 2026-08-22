import 'package:flutter/material.dart';

enum SparkeeStatus { normal, warning, critical, offline, stale }

enum SparkeeFleetStatus { moving, idle, stopped, offline }

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

extension SparkeeFleetStatusPresentation on SparkeeFleetStatus {
  String get label => switch (this) {
    SparkeeFleetStatus.moving => 'Moving',
    SparkeeFleetStatus.idle => 'Idle',
    SparkeeFleetStatus.stopped => 'Stopped',
    SparkeeFleetStatus.offline => 'Offline',
  };

  IconData get icon => switch (this) {
    SparkeeFleetStatus.moving => Icons.route_outlined,
    SparkeeFleetStatus.idle => Icons.pause_circle_outline,
    SparkeeFleetStatus.stopped => Icons.stop_circle_outlined,
    SparkeeFleetStatus.offline => Icons.cloud_off_outlined,
  };
}
