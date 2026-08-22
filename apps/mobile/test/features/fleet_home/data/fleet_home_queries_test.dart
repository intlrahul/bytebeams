import 'package:bytebeams/features/fleet_home/data/fleet_home_queries.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given_fleet_home_queries_when_reviewed_then_encode_authoritative_sql_rules', () {
    expect(
      FleetHomeQueries.selectRows,
      contains("classification = 'supportedValid'"),
    );
    expect(FleetHomeQueries.selectRows, contains("signal_name = 'last_ping'"));
    expect(FleetHomeQueries.selectRows, contains("s.last_ping_at < ?"));
    expect(
      FleetHomeQueries.selectRows,
      contains("WHEN s.speed > 0 THEN 'moving'"),
    );
    expect(
      FleetHomeQueries.selectRows,
      contains("WHEN s.ignition IS TRUE THEN 'idle'"),
    );
    expect(FleetHomeQueries.selectRows, contains("ELSE 'stopped'"));
    expect(
      FleetHomeQueries.selectRows,
      contains('ORDER BY registration_number ASC, vehicle_id ASC'),
    );
    expect(FleetHomeQueries.selectCounts, contains('COUNT(*) FILTER'));
  });
}
